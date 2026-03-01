import Foundation
import AVFoundation

/// Shared, persistent settings model.
/// AppDelegate observes it via Combine to apply changes immediately to running players.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    // MARK: - Live playback state (not persisted — updated by AppDelegate)

    @Published var isPlaying: Bool = false
    @Published var currentVideoURL: URL? = nil

    // MARK: - Audio

    @Published var isMuted: Bool = true {
        didSet { save(isMuted, key: .isMuted) }
    }
    @Published var volume: Double = 0.8 {
        didSet { save(volume, key: .volume) }
    }

    // MARK: - Display

    @Published var videoGravityRaw: String = AVLayerVideoGravity.resizeAspectFill.rawValue {
        didSet { save(videoGravityRaw, key: .videoGravityRaw) }
    }
    var videoGravity: AVLayerVideoGravity { .init(rawValue: videoGravityRaw) }

    // MARK: - Performance

    /// Frames per second cap. 0 = no cap (use video's native frame rate).
    @Published var frameRateCap: Int = 30 {
        didSet { save(frameRateCap, key: .frameRateCap) }
    }
    /// When true, render size is capped to screen point resolution.
    @Published var optimizeResolution: Bool = true {
        didSet { save(optimizeResolution, key: .optimizeResolution) }
    }

    // MARK: - Last video path (plain read/write, not @Published)

    var lastVideoPath: String {
        get { UserDefaults.standard.string(forKey: Key.lastVideoPath.rawValue) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: Key.lastVideoPath.rawValue) }
    }

    // MARK: - Keys

    enum Key: String {
        case lastVideoPath, isMuted, volume, videoGravityRaw, frameRateCap, optimizeResolution
    }

    // MARK: - Helpers

    private func save(_ value: Any, key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    private func load<T>(_ key: Key, default fallback: T) -> T {
        UserDefaults.standard.object(forKey: key.rawValue) as? T ?? fallback
    }

    // MARK: - Init

    private init() {
        isMuted            = load(.isMuted,            default: true)
        volume             = load(.volume,             default: 0.8)
        videoGravityRaw    = load(.videoGravityRaw,    default: AVLayerVideoGravity.resizeAspectFill.rawValue)
        frameRateCap       = load(.frameRateCap,       default: 30)
        optimizeResolution = load(.optimizeResolution, default: true)
    }
}
