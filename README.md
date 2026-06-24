# KeepAwake ☕

[![License: MIT](https://img.shields.io/badge/License-MIT-e8a34c.svg)](LICENSE)
[![Platform: macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://github.com/Abhinav-ranish/KeepAwake/releases/latest)
[![Download](https://img.shields.io/github/v/release/Abhinav-ranish/KeepAwake?label=download&color=3fb950)](https://github.com/Abhinav-ranish/KeepAwake/releases/latest)

A tiny macOS menu-bar app that keeps your Mac awake — including **running with the
lid closed** (no external display needed), which is what Amphetamine's "closed-display
mode" does. No App Store, no Apple ID, no third-party apps.

**🌐 Website:** https://keepawake.aranish.uk · **📦 [Download](https://github.com/Abhinav-ranish/KeepAwake/releases/latest)** · **📝 [Changelog](CHANGELOG.md)**

> **Why this exists:** I wanted [Amphetamine](https://apps.apple.com/us/app/amphetamine/id937984704),
> but it's Mac App Store–only and I couldn't get it installed on my work laptop
> (no Apple ID sign-in allowed). So I built this — same core feature (keep awake +
> closed-display mode), installable without the App Store or an Apple ID. Full credit
> to Amphetamine for the idea.

## What you get
- A menu-bar coffee-cup icon. Click it and pick: **15 min / 30 min / 1 hour /
  Indefinitely / Custom…**
- A **"Keep running with lid closed"** checkbox (on by default). When on, it flips
  the macOS `disablesleep` power setting so the machine keeps running with the lid shut.
- While active, the menu shows time remaining and a **Stop** button.
- Stopping (or the timer expiring, or quitting) **reverts everything to defaults** —
  it never leaves your Mac unable to sleep.

## Install
Requires Xcode Command Line Tools (`xcode-select --install` — no Apple ID needed).

```bash
bash install.sh
```

That builds the app into `~/Applications/KeepAwake.app` and sets it to auto-start at login.

### Optional: silent lid-closed mode (no password prompt)
Lid-closed mode needs admin (`pmset`). By default macOS shows a Touch ID / password
dialog each time. To make it completely silent, install a tightly-scoped sudo rule
that allows *only* the two `pmset disablesleep` commands:

```bash
sudo bash grant-admin.sh
```

### Optional: Touch ID for all sudo
```bash
sudo bash enable-touchid-sudo.sh
```

## Notes / cautions
- 🔥 Running with the lid closed traps heat — fine for downloads/builds/keeping a
  connection alive; be cautious with sustained heavy CPU/GPU load.
- 🔋 On battery, a closed-lid session runs until the battery dies. Best plugged in.
- 🏢 On a Jamf/MDM-managed work Mac, `sudo` may be restricted, and IT policy syncs can
  revert `/etc/sudoers.d/` and `/etc/pam.d/` changes. If silent mode ever starts
  prompting again, just re-run `grant-admin.sh`. The app itself still works regardless —
  it falls back to the Touch ID / password dialog.

## Uninstall
```bash
launchctl bootout "gui/$(id -u)/local.keepawake" 2>/dev/null
rm -f ~/Library/LaunchAgents/local.keepawake.plist
rm -rf ~/Applications/KeepAwake.app
sudo rm -f /etc/sudoers.d/keepawake          # if you installed the sudo rule
```

## Files
- `src/main.swift` — the whole app (AppKit, ~200 lines)
- `build.sh` — compiles + bundles into `~/Applications`
- `install.sh` — build + auto-start setup
- `grant-admin.sh` — scoped passwordless sudo rule for `pmset`
- `enable-touchid-sudo.sh` — Touch ID for sudo
