import AppKit
import AVFoundation

// MARK: - PlayerView

/// Custom NSView that keeps the AVPlayerLayer filling the entire view bounds.
final class PlayerView: NSView {
    private(set) var playerLayer: AVPlayerLayer?

    func setup(player: AVPlayer) {
        wantsLayer = true
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = AppSettings.shared.videoGravity
        layer.frame = bounds
        self.layer?.addSublayer(layer)
        self.playerLayer = layer
    }

    override func layout() {
        super.layout()
        playerLayer?.frame = bounds
    }
}

// MARK: - WallpaperWindow

/// A borderless window positioned at the desktop level that plays a looping video.
final class WallpaperWindow: NSWindow {
    private var player: AVPlayer?
    private var loopObserver: NSObjectProtocol?
    private(set) var currentURL: URL?
    private let targetScreen: NSScreen

    var isMuted: Bool {
        get { player?.isMuted ?? true }
        set { player?.isMuted = newValue }
    }

    var volume: Float {
        get { player?.volume ?? 1 }
        set { player?.volume = newValue }
    }

    private var currentSpeed: Float = 1.0
    var playbackSpeed: Float {
        get { currentSpeed }
        set {
            currentSpeed = newValue
            if let player, player.rate > 0 { player.rate = newValue }
        }
    }

    // MARK: Init

    init(screen: NSScreen) {
        self.targetScreen = screen
        // Must use the designated initializer (the version with screen: is a convenience init)
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        configure()
    }

    private func configure() {
        // NSWindow defaults to isReleasedWhenClosed = true, which sends an extra ObjC
        // release on close(). With ARC also managing the lifetime, this causes a
        // double-free crash when the wallpaperWindows array releases its reference.
        isReleasedWhenClosed = false
        // Place window at desktop level — below all app windows but above the system wallpaper
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        backgroundColor = .black
        isOpaque = true
        hasShadow = false
        ignoresMouseEvents = true
        isMovable = false
        // Show on all Spaces and don't appear in Mission Control
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    }

    // MARK: Playback

    func play(url: URL) {
        currentURL = url
        stop()

        let s = AppSettings.shared
        currentSpeed = Float(s.playbackSpeed)
        let item = AVPlayerItem(url: url)
        // Hint to AVFoundation: don't decode above screen resolution (helps for HLS/adaptive)
        item.preferredMaximumResolution = targetScreen.frame.size

        let p = AVPlayer(playerItem: item)
        p.isMuted = s.isMuted
        p.volume  = Float(s.volume)
        p.allowsExternalPlayback = false  // skip AirPlay/HDMI routing overhead
        self.player = p

        // Apply frame-rate cap + resolution reduction in the background.
        // Video starts immediately at full settings; composition kicks in after track info loads.
        let screenSize = targetScreen.frame.size
        Task { [weak self, weak item, weak p] in
            guard let self, let item, let p else { return }
            await self.applyPowerOptimizations(to: item, player: p, screenSize: screenSize)
        }

        // Loop on end
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.player?.seek(to: .zero)
            self.player?.rate = self.currentSpeed
        }

        let playerView = PlayerView(frame: frame)
        playerView.setup(player: p)
        contentView = playerView

        orderFront(nil)
        p.rate = currentSpeed
    }

    /// Updates the videoGravity of the running player layer immediately.
    func updateVideoGravity() {
        (contentView as? PlayerView)?.playerLayer?.videoGravity = AppSettings.shared.videoGravity
    }

    /// Loads video track metadata then applies two GPU optimisations via AVMutableVideoComposition:
    ///   1. Frame rate capped (per AppSettings.frameRateCap)
    ///   2. Render size capped at screen point resolution (when optimizeResolution is enabled)
    private func applyPowerOptimizations(to item: AVPlayerItem,
                                         player: AVPlayer,
                                         screenSize: CGSize) async {
        let s = AppSettings.shared

        guard let track = try? await item.asset.loadTracks(withMediaType: .video).first else { return }

        async let sizeTask    = track.load(.naturalSize)
        async let tfmTask     = track.load(.preferredTransform)
        async let fpsTask     = track.load(.nominalFrameRate)
        let naturalSize = (try? await sizeTask) ?? CGSize(width: 1920, height: 1080)
        let transform   = (try? await tfmTask)  ?? .identity
        let nativeFPS   = (try? await fpsTask)  ?? 30

        // Account for 90° / 270° rotation (portrait videos shot on iPhone etc.)
        let isRotated = (transform.a == 0 && transform.d == 0)
        let videoSize = isRotated
            ? CGSize(width: naturalSize.height, height: naturalSize.width)
            : naturalSize

        // Determine render size
        let scale: CGFloat
        if s.optimizeResolution {
            scale = min(screenSize.width  / videoSize.width,
                        screenSize.height / videoSize.height,
                        1.0)
        } else {
            scale = 1.0
        }
        let renderSize = CGSize(width:  (videoSize.width  * scale).rounded(),
                                height: (videoSize.height * scale).rounded())

        // Determine frame rate cap
        let capFPS = s.frameRateCap > 0 ? Float(s.frameRateCap) : nativeFPS
        let timescale = CMTimeScale(capFPS.rounded())

        // Skip composition entirely if no optimisation is needed
        let noResChange = scale >= 1.0
        let noFPSChange = capFPS >= nativeFPS
        if noResChange && noFPSChange { return }

        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        // Must concatenate the scale so video coordinates map into the smaller renderSize.
        // Without this, a 4K video drawn into a 1080p canvas shows only the top-left quadrant.
        let scaleDown = CGAffineTransform(scaleX: scale, y: scale)
        layerInstruction.setTransform(transform.concatenating(scaleDown), at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: .positiveInfinity)
        instruction.layerInstructions = [layerInstruction]

        let composition = AVMutableVideoComposition()
        composition.frameDuration = CMTime(value: 1, timescale: timescale)
        composition.renderSize    = (renderSize.width > 0 && renderSize.height > 0)
                                        ? renderSize : videoSize
        composition.instructions  = [instruction]

        await MainActor.run {
            guard item == player.currentItem else { return }
            item.videoComposition = composition
        }
    }

    func pause() { player?.pause() }
    func resume() { player?.rate = currentSpeed }

    func toggleMute() {
        player?.isMuted = !(player?.isMuted ?? true)
    }

    func stop() {
        if let obs = loopObserver {
            NotificationCenter.default.removeObserver(obs)
            loopObserver = nil
        }
        player?.pause()
        player = nil
    }

    func stopAndClose() {
        stop()
        close()
    }

    // MARK: Overrides

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
