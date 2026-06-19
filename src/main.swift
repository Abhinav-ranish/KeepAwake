import Cocoa

// KeepAwake — a tiny menu-bar app.
// • Pick a duration (15m / 30m / 1h / indefinite / custom) to keep the Mac awake.
// • "Keep running with lid closed" (on by default) flips pmset disablesleep so the
//   machine keeps running with the lid shut, no external display needed.
// • Stopping (or quitting) reverts EVERYTHING to system defaults.

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    var caffeinate: Process?       // the running caffeinate child, if active
    var lidClosedEnabled = true    // checkbox state (default ON)
    var didDisableSleep = false    // whether we actually flipped pmset (so we know to revert)
    var endDate: Date?             // nil = indefinite
    var expiryTimer: Timer?

    var isActive: Bool { caffeinate != nil }

    func applicationDidFinishLaunching(_ note: Notification) {
        NSApp.setActivationPolicy(.accessory)   // menu-bar only, no Dock icon
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        updateIcon()
    }

    // MARK: - Icon

    func updateIcon() {
        guard let button = statusItem.button else { return }
        let name = isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
        let img = NSImage(systemSymbolName: name, accessibilityDescription: "KeepAwake")
        img?.isTemplate = true
        button.image = img
        button.toolTip = isActive ? "KeepAwake — active" : "KeepAwake — off"
    }

    // MARK: - Menu (rebuilt each time it opens, based on state)

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        if isActive { buildActiveMenu(menu) } else { buildIdleMenu(menu) }
    }

    func buildIdleMenu(_ menu: NSMenu) {
        let lid = NSMenuItem(title: "Keep running with lid closed",
                             action: #selector(toggleLidPref), keyEquivalent: "")
        lid.state = lidClosedEnabled ? .on : .off
        lid.target = self
        menu.addItem(lid)
        menu.addItem(.separator())

        addDuration(menu, "15 minutes", 15)
        addDuration(menu, "30 minutes", 30)
        addDuration(menu, "1 hour", 60)

        let indef = NSMenuItem(title: "Indefinitely", action: #selector(startIndefinite), keyEquivalent: "")
        indef.target = self
        menu.addItem(indef)

        let custom = NSMenuItem(title: "Custom…", action: #selector(startCustom), keyEquivalent: "")
        custom.target = self
        menu.addItem(custom)

        menu.addItem(.separator())
        addQuit(menu)
    }

    func buildActiveMenu(_ menu: NSMenu) {
        let header: String
        if let end = endDate {
            let secs = max(0, Int(end.timeIntervalSinceNow))
            header = String(format: "Active — %d:%02d left", secs / 60, secs % 60)
        } else {
            header = "Active — no time limit"
        }
        let h = NSMenuItem(title: header, action: nil, keyEquivalent: "")
        h.isEnabled = false
        menu.addItem(h)

        let stop = NSMenuItem(title: "Stop", action: #selector(stop), keyEquivalent: "")
        stop.target = self
        menu.addItem(stop)

        menu.addItem(.separator())

        let lid = NSMenuItem(title: "Keep running with lid closed",
                             action: #selector(toggleLidLive), keyEquivalent: "")
        lid.state = lidClosedEnabled ? .on : .off
        lid.target = self
        menu.addItem(lid)

        menu.addItem(.separator())
        addQuit(menu)
    }

    func addDuration(_ menu: NSMenu, _ title: String, _ minutes: Int) {
        let item = NSMenuItem(title: title, action: #selector(startTimed(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = minutes
        menu.addItem(item)
    }

    func addQuit(_ menu: NSMenu) {
        let q = NSMenuItem(title: "Quit KeepAwake", action: #selector(quit), keyEquivalent: "q")
        q.target = self
        menu.addItem(q)
    }

    // MARK: - Actions

    @objc func toggleLidPref() { lidClosedEnabled.toggle() }   // only changes the default for next start

    @objc func toggleLidLive() {                                // live toggle while active
        lidClosedEnabled.toggle()
        if lidClosedEnabled {
            didDisableSleep = setDisableSleep(true)
        } else if didDisableSleep {
            _ = setDisableSleep(false)
            didDisableSleep = false
        }
    }

    @objc func startTimed(_ sender: NSMenuItem) {
        guard let m = sender.representedObject as? Int else { return }
        start(minutes: m)
    }

    @objc func startIndefinite() { start(minutes: nil) }

    @objc func startCustom() {
        let alert = NSAlert()
        alert.messageText = "Keep awake for how many minutes?"
        alert.informativeText = "Enter a whole number of minutes."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        field.placeholderString = "e.g. 90"
        alert.accessoryView = field
        alert.addButton(withTitle: "Start")
        alert.addButton(withTitle: "Cancel")
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            let mins = Int(field.stringValue.trimmingCharacters(in: .whitespaces))
            if let mins, mins > 0 { start(minutes: mins) }
        }
    }

    @objc func quit() {
        stop()                 // revert everything before exiting
        NSApp.terminate(nil)
    }

    // MARK: - Core start/stop

    func start(minutes: Int?) {
        if isActive { stop() }

        // 1) keep display + system + disk awake
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        p.arguments = ["-dis"]                       // -d display, -i idle system, -s disk
        do { try p.run() } catch {
            notify("Could not start caffeinate", "\(error.localizedDescription)")
            return
        }
        caffeinate = p

        // 2) lid-closed mode (needs admin)
        if lidClosedEnabled {
            didDisableSleep = setDisableSleep(true)
            if !didDisableSleep {
                // user cancelled the password prompt or it's blocked — keep awake, just not lid-closed
                lidClosedEnabled = false
            }
        }

        // 3) expiry timer
        if let minutes {
            endDate = Date().addingTimeInterval(Double(minutes) * 60)
            expiryTimer = Timer.scheduledTimer(withTimeInterval: Double(minutes) * 60,
                                               repeats: false) { [weak self] _ in self?.stop() }
        } else {
            endDate = nil
        }
        updateIcon()
    }

    @objc func stop() {
        expiryTimer?.invalidate(); expiryTimer = nil
        endDate = nil
        caffeinate?.terminate()
        caffeinate = nil
        if didDisableSleep {
            _ = setDisableSleep(false)
            didDisableSleep = false
        }
        updateIcon()
    }

    // MARK: - pmset via admin prompt

    @discardableResult
    func setDisableSleep(_ on: Bool) -> Bool {
        let val = on ? "1" : "0"
        // Preferred: passwordless sudo via the scoped /etc/sudoers.d/keepawake rule.
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        p.arguments = ["-n", "/usr/bin/pmset", "-a", "disablesleep", val]
        p.standardError = FileHandle.nullDevice
        p.standardOutput = FileHandle.nullDevice
        if (try? p.run()) != nil {
            p.waitUntilExit()
            if p.terminationStatus == 0 { return true }
        }
        // Fallback: the macOS admin dialog (offers Touch ID on supported Macs).
        let cmd = "/usr/bin/pmset -a disablesleep \(val)"
        let src = "do shell script \"\(cmd)\" with administrator privileges"
        var err: NSDictionary?
        guard let script = NSAppleScript(source: src) else { return false }
        NSApp.activate(ignoringOtherApps: true)
        script.executeAndReturnError(&err)
        return err == nil
    }

    func notify(_ title: String, _ body: String) {
        let a = NSAlert()
        a.messageText = title
        a.informativeText = body
        a.runModal()
    }

    func applicationWillTerminate(_ note: Notification) {
        // safety net: never leave the system with sleep disabled
        if didDisableSleep { _ = setDisableSleep(false) }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
