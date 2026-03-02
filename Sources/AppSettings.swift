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

    // MARK: - Playback

    /// Playback speed multiplier. 1.0 = normal speed.
    @Published var playbackSpeed: Double = 1.0 {
        didSet { save(playbackSpeed, key: .playbackSpeed) }
    }

    // MARK: - Language

    @Published var language: Language = .english {
        didSet { save(language.rawValue, key: .language) }
    }

    // MARK: - Last video bookmark (persists file reference across relaunches)

    /// Stores the last played video URL as bookmark data, which survives file moves
    /// better than a plain path string.
    func saveLastVideoBookmark(for url: URL) {
        if let data = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
            UserDefaults.standard.set(data, forKey: Key.lastVideoBookmark.rawValue)
        }
        // Keep a plain path as fallback for older persisted data
        UserDefaults.standard.set(url.path, forKey: Key.lastVideoPath.rawValue)
    }

    /// Resolves the last played video URL from bookmark data, falling back to a plain path.
    func resolveLastVideoURL() -> URL? {
        // Try bookmark data first
        if let data = UserDefaults.standard.data(forKey: Key.lastVideoBookmark.rawValue) {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale) {
                if isStale { saveLastVideoBookmark(for: url) }
                if FileManager.default.fileExists(atPath: url.path) { return url }
            }
        }
        // Fall back to plain path (migrates from older versions)
        let path = UserDefaults.standard.string(forKey: Key.lastVideoPath.rawValue) ?? ""
        guard !path.isEmpty else { return nil }
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return url
    }

    // MARK: - Keys

    enum Key: String {
        case lastVideoPath, lastVideoBookmark, isMuted, volume, videoGravityRaw, frameRateCap, optimizeResolution, playbackSpeed, language
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
        playbackSpeed      = load(.playbackSpeed,      default: 1.0)
        language           = Language(rawValue: load(.language, default: Language.english.rawValue)) ?? .english
    }
}
