import AppKit
import UniformTypeIdentifiers
import ServiceManagement
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var wallpaperWindows: [WallpaperWindow] = []
    private var settingsWindowController: SettingsWindowController?

    /// Counts overlapping system-pause events (sleep, lock, screensaver…).
    /// Playback resumes only when it reaches zero again.
    private var systemPauseCount = 0
    private var cancellables = Set<AnyCancellable>()

    private var settings: AppSettings { .shared }

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()

        NotificationCenter.default.addObserver(
            self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)

        registerPowerNotifications()
        observeSettings()
        autoResumeLastVideo()
    }

    // MARK: - Settings observation (Combine)

    private func observeSettings() {
        // Language — rebuild menu with new strings
        settings.$language
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.rebuildMenu() }
            .store(in: &cancellables)

        // Mute — apply immediately to all running players
        settings.$isMuted
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] muted in
                self?.wallpaperWindows.forEach { $0.isMuted = muted }
                self?.rebuildMenu()
            }
            .store(in: &cancellables)

        // Volume — apply immediately
        settings.$volume
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] vol in
                self?.wallpaperWindows.forEach { $0.volume = Float(vol) }
            }
            .store(in: &cancellables)

        // Video gravity — apply immediately to all player layers
        settings.$videoGravityRaw
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.wallpaperWindows.forEach { $0.updateVideoGravity() }
            }
            .store(in: &cancellables)

        // Playback speed — apply immediately to all running players
        settings.$playbackSpeed
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                self?.wallpaperWindows.forEach { $0.playbackSpeed = Float(speed) }
            }
            .store(in: &cancellables)

        // Frame rate / resolution cap — re-apply composition if playing
        Publishers.Merge(
            settings.$frameRateCap.dropFirst().map { _ in () },
            settings.$optimizeResolution.dropFirst().map { _ in () }
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            guard let self, let url = self.settings.currentVideoURL else { return }
            self.apply(url: url)
        }
        .store(in: &cancellables)
    }

    // MARK: - Power Management

    private func registerPowerNotifications() {
        let ws = NSWorkspace.shared.notificationCenter
        let dn = DistributedNotificationCenter.default()

        ws.addObserver(self, selector: #selector(handleSystemPause),
                       name: NSWorkspace.willSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleSystemResume),
                       name: NSWorkspace.didWakeNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleSystemPause),
                       name: NSWorkspace.screensDidSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(handleSystemResume),
                       name: NSWorkspace.screensDidWakeNotification, object: nil)
        dn.addObserver(self, selector: #selector(handleScreenLocked),
                       name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        dn.addObserver(self, selector: #selector(handleScreenUnlocked),
                       name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
        dn.addObserver(self, selector: #selector(handleScreensaverStart),
                       name: NSNotification.Name("com.apple.screensaver.didstart"), object: nil)
        dn.addObserver(self, selector: #selector(handleScreensaverStop),
                       name: NSNotification.Name("com.apple.screensaver.didstop"), object: nil)
    }

    @objc private func handleSystemPause() {
        systemPauseCount += 1
        if systemPauseCount == 1 { wallpaperWindows.forEach { $0.pause() } }
    }

    @objc private func handleSystemResume() {
        systemPauseCount = max(0, systemPauseCount - 1)
        if systemPauseCount == 0 { wallpaperWindows.forEach { $0.resume() } }
    }

    @objc private func handleScreenLocked() { handleSystemPause() }
    @objc private func handleScreenUnlocked() { handleSystemResume() }
    @objc private func handleScreensaverStart() { handleSystemPause() }
    @objc private func handleScreensaverStop() { handleSystemResume() }

    // MARK: - Status Bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let img = NSImage(systemSymbolName: "play.display",
                              accessibilityDescription: "DyWallpaper")
            img?.isTemplate = true
            button.image = img
            button.toolTip = "DyWallpaper"
        }
        rebuildMenu()
    }

    private func rebuildMenu() {
        let loc = Loc(settings.language)
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "DyWallpaper", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        // Playing indicator
        if let url = settings.currentVideoURL, !wallpaperWindows.isEmpty {
            let playing = NSMenuItem(title: "▶  \(url.lastPathComponent)",
                                     action: nil, keyEquivalent: "")
            playing.isEnabled = false
            menu.addItem(playing)
            menu.addItem(.separator())
        }

        menu.addItem(NSMenuItem(title: loc.menuSelectVideo,
                                action: #selector(selectVideo), keyEquivalent: "o"))

        // Resume when stopped but a last-played file exists
        if wallpaperWindows.isEmpty, let url = settings.currentVideoURL {
            let item = NSMenuItem(title: "\(loc.menuResumePrefix)\(url.lastPathComponent)",
                                  action: #selector(resumeLastVideo), keyEquivalent: "r")
            menu.addItem(item)
        }

        if !wallpaperWindows.isEmpty {
            let muteTitle = settings.isMuted ? loc.menuUnmute : loc.menuMute
            menu.addItem(NSMenuItem(title: muteTitle,
                                    action: #selector(toggleMute), keyEquivalent: "m"))
            menu.addItem(NSMenuItem(title: loc.menuStopPlayback,
                                    action: #selector(stopWallpaper), keyEquivalent: "s"))
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: loc.menuPreferences,
                                action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: loc.menuQuit,
                                action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items { item.target = self }
        statusItem.menu = menu
    }

    // MARK: - Actions

    @objc func selectVideo() {
        let loc = Loc(settings.language)
        let panel = NSOpenPanel()
        panel.title = loc.panelTitle
        panel.prompt = loc.panelPrompt
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        var types: [UTType] = [.movie, .video, .mpeg4Movie, .quickTimeMovie]
        if let avi = UTType("public.avi") { types.append(avi) }
        panel.allowedContentTypes = types

        NSApp.activate(ignoringOtherApps: true)
        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.apply(url: url)
        }
    }

    @objc func resumeLastVideo() {
        guard let url = settings.currentVideoURL,
              FileManager.default.fileExists(atPath: url.path) else { return }
        apply(url: url)
    }

    @objc func stopWallpaper() {
        clearWindows()
        settings.isPlaying = false
        rebuildMenu()
    }

    @objc func toggleMute() {
        settings.isMuted.toggle()
    }

    @objc func toggleLoginItem() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            let loc = Loc(settings.language)
            let alert = NSAlert()
            alert.messageText = loc.alertLoginItemTitle
            alert.informativeText = loc.alertLoginItemMessage + loc.alertLoginItemErrorPrefix + error.localizedDescription
            alert.alertStyle = .warning
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc func openSettings() {
        if settingsWindowController == nil {
            let view = SettingsView(
                settings: settings,
                onSelectVideo:    { [weak self] in self?.selectVideo() },
                onStopPlayback:   { [weak self] in self?.stopWallpaper() },
                onResumePlayback: { [weak self] in self?.resumeLastVideo() },
                onToggleLogin:    { [weak self] in self?.toggleLoginItem() }
            )
            settingsWindowController = SettingsWindowController(settingsView: view)
        }
        settingsWindowController?.show()
    }

    @objc private func screensChanged() {
        guard let url = settings.currentVideoURL else { return }
        apply(url: url)
    }

    @objc private func quit() { NSApp.terminate(nil) }

    // MARK: - Playback

    func apply(url: URL) {
        settings.lastVideoPath = url.path
        settings.currentVideoURL = url
        clearWindows()
        for screen in NSScreen.screens {
            let win = WallpaperWindow(screen: screen)
            win.play(url: url)
            wallpaperWindows.append(win)
        }
        settings.isPlaying = true
        rebuildMenu()
    }

    private func autoResumeLastVideo() {
        let path = settings.lastVideoPath
        guard !path.isEmpty else { return }
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        settings.currentVideoURL = url
        apply(url: url)
    }

    private func clearWindows() {
        wallpaperWindows.forEach { $0.stopAndClose() }
        wallpaperWindows.removeAll()
    }
}
