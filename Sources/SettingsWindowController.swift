import AppKit
import SwiftUI
import Combine

/// Shared layout constants for the settings window.
enum SettingsLayout {
    static let windowSize = NSSize(width: 420, height: 560)
}

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private var languageCancellable: AnyCancellable?

    init(settingsView: SettingsView) {
        let hc = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hc)
        let loc = Loc(AppSettings.shared.language)
        window.title = "DyWallpaper — \(loc.menuPreferences.replacingOccurrences(of: "…", with: ""))"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setFrameAutosaveName("DyWallpaperSettings")
        window.isReleasedWhenClosed = false
        window.contentMinSize = SettingsLayout.windowSize
        window.contentMaxSize = SettingsLayout.windowSize

        super.init(window: window)
        window.delegate = self
        window.center()

        // Update window title when language changes
        languageCancellable = AppSettings.shared.$language
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] lang in
                let loc = Loc(lang)
                self?.window?.title = "DyWallpaper — \(loc.menuPreferences.replacingOccurrences(of: "…", with: ""))"
            }
    }

    required init?(coder: NSCoder) { fatalError() }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    // The window closes normally when the user clicks the close button.
    // The controller stays alive because isReleasedWhenClosed = false and
    // AppDelegate holds the settingsWindowController reference, preserving
    // the window's autosaved position for next open.
    func windowWillClose(_ notification: Notification) {}
}
