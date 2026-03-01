# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Install

```bash
bash build.sh
```

This single command compiles all Swift sources, bundles the app, ad-hoc signs it, copies it to `/Applications/DyWallpaper.app`, and relaunches the running instance. There are no separate lint or test commands.

Key compiler flags:
- `-swift-version 5` — required to avoid Swift 6 strict concurrency errors
- `-target arm64-apple-macosx13.0`
- `-Onone` (debug build; no optimisation)
- Frameworks: AppKit, AVFoundation, CoreMedia, QuartzCore, ServiceManagement, SwiftUI, Combine

## Architecture

The app is a macOS status-bar–only app (no Dock icon, `LSUIElement=YES`, `.accessory` activation policy). All source files are compiled as a single `swiftc` invocation — no Xcode project, no SPM manifest.

**Data flow:**

```
AppSettings (ObservableObject, UserDefaults-backed)
    ↑ written by SettingsView (SwiftUI)
    ↓ observed via Combine in AppDelegate → applied to WallpaperWindow instances
```

**Key files:**

| File | Role |
|---|---|
| `Sources/main.swift` | Entry point; sets `.accessory` policy and starts the run loop |
| `Sources/AppSettings.swift` | Singleton (`AppSettings.shared`); all persisted settings as `@Published` properties with `didSet` → `UserDefaults` |
| `Sources/AppDelegate.swift` | Status bar item, menu, power/sleep/lock/screensaver notifications, Combine observers that push setting changes into running `WallpaperWindow`s |
| `Sources/WallpaperWindow.swift` | `NSWindow` at desktop level (`CGWindowLevelForKey(.desktopWindow)`); hosts `AVPlayer` inside a `PlayerView` (custom `NSView` with `AVPlayerLayer`); handles frame-rate cap and resolution optimisation via `AVMutableVideoComposition` |
| `Sources/SettingsView.swift` | SwiftUI `Form` (`grouped` style) rendered in a standard `NSWindow` |
| `Sources/SettingsWindowController.swift` | Wraps `NSHostingController<SettingsView>` in an `NSWindowController`; uses `NSWindow(contentViewController:)` so SwiftUI's `preferredContentSize` drives the window size correctly |

## Important Implementation Details

- **Desktop window level**: use `CGWindowLevelForKey(.desktopWindow)`, not `.desktopWindowLevelKey`
- **WallpaperWindow init**: `NSWindow(screen:)` is a convenience init that should not be used — use the designated `init(contentRect:styleMask:backing:defer:)` directly
- **`isReleasedWhenClosed = false`** is required on `WallpaperWindow`; otherwise ARC + ObjC double-free crash on close
- **Multi-monitor**: one `WallpaperWindow` per `NSScreen`; re-created on `NSApplication.didChangeScreenParametersNotification`
- **Pause counter** (`systemPauseCount`): overlapping sleep/wake and lock/unlock events are ref-counted so playback resumes only after all pause sources have cleared
- **Power optimisations** in `WallpaperWindow.applyPowerOptimizations`: applied asynchronously after track metadata loads; skipped entirely when neither cap applies, to avoid unnecessary composition overhead
- **SMAppService** (login item): requires the app to be installed in `/Applications`; always go through `AppDelegate.toggleLoginItem()` which shows a user-facing alert on failure
- **SettingsWindowController** is lazily created and reused (not re-created on every open) — `settingsWindowController` is nilled only when explicitly discarded
