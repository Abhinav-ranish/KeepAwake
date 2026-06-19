# Changelog

All notable changes to KeepAwake are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-06-19

### Added
- Menu-bar app to keep the Mac awake for **15 minutes, 30 minutes, 1 hour,
  indefinitely, or a custom time**.
- **Closed-display (lid-closed) mode** — keeps the Mac running with the lid shut,
  with no external display, via macOS `disablesleep`. On by default; toggleable
  live while active.
- Clean revert: stopping (or the timer expiring, or quitting) restores all macOS
  defaults — the app never leaves the Mac unable to sleep.
- **Auto-start at login** via a per-user LaunchAgent.
- Optional **scoped passwordless sudo** rule (`grant-admin.sh`) for silent
  lid-closed mode, and **Touch ID for sudo** (`enable-touchid-sudo.sh`).
- Coffee-cup app icon and ad-hoc code signing.
- Distribution: prebuilt app, source-only, and source+app downloads.
- Landing page with full SEO + GEO/AIO (Open Graph, Twitter Card, JSON-LD
  `SoftwareApplication`/`WebSite`/`FAQPage`, `robots.txt`, `sitemap.xml`,
  `llms.txt`, comparison table, and a menu screenshot).

### Notes
- Built as a free, open-source alternative to Amphetamine that installs without
  the Mac App Store or an Apple ID.
- Requires macOS 13 (Ventura) or later. Apple Silicon and Intel.

[1.0.0]: https://github.com/Abhinav-ranish/KeepAwake/releases/tag/v1.0
