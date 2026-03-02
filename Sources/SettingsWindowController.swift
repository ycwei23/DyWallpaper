import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    init(settingsView: SettingsView) {
        // NSHostingController properly reports preferredContentSize to NSWindow.
        // NSWindow(contentViewController:) then sizes itself to match.
        // Using NSHostingView + contentRect:.zero instead causes a 0×0 invisible window.
        let hc = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hc)
        window.title = "DyWallpaper 設定"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setFrameAutosaveName("DyWallpaperSettings")
        window.isReleasedWhenClosed = false
        // Lock content size to match the fixed SwiftUI frame.
        let fixedSize = NSSize(width: 420, height: 560)
        window.contentMinSize = fixedSize
        window.contentMaxSize = fixedSize

        super.init(window: window)
        window.delegate = self
        window.center()
    }

    required init?(coder: NSCoder) { fatalError() }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    // Keep the controller alive; just hide when the user closes the window.
    func windowWillClose(_ notification: Notification) {}
}
