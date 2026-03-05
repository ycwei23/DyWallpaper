import Foundation
import CoreMedia

// Tests for the power optimization calculation logic.
// Since applyPowerOptimizations is a private async method on WallpaperWindow,
// we extract and test the pure calculation logic here.

/// Pure function that mirrors the render-size calculation in WallpaperWindow.applyPowerOptimizations.
private func calculateRenderSize(
    videoSize: CGSize,
    screenSize: CGSize,
    optimizeResolution: Bool
) -> (scale: CGFloat, renderSize: CGSize) {
    guard videoSize.width > 0, videoSize.height > 0 else {
        return (1.0, videoSize)
    }

    let scale: CGFloat
    if optimizeResolution {
        scale = min(screenSize.width / videoSize.width,
                    screenSize.height / videoSize.height,
                    1.0)
    } else {
        scale = 1.0
    }
    let renderSize = CGSize(
        width: (videoSize.width * scale).rounded(),
        height: (videoSize.height * scale).rounded()
    )
    return (scale, renderSize)
}

/// Pure function that mirrors the FPS capping logic.
private func calculateFrameRate(
    frameRateCap: Int,
    nativeFPS: Float
) -> (capFPS: Float, timescale: CMTimeScale, shouldApply: Bool) {
    let capFPS = frameRateCap > 0 ? Float(frameRateCap) : nativeFPS
    let clampedFPS = min(capFPS.rounded(), 600)
    let timescale = CMTimeScale(max(clampedFPS, 1))
    let shouldApply = capFPS < nativeFPS
    return (capFPS, timescale, shouldApply)
}

func runPowerOptimizationTests() {
    print("\n--- Power Optimization Tests ---")

    // MARK: Render Size Tests

    test("4K video on 1080p screen scales down to 1080p") {
        let (scale, size) = calculateRenderSize(
            videoSize: CGSize(width: 3840, height: 2160),
            screenSize: CGSize(width: 1920, height: 1080),
            optimizeResolution: true
        )
        try assertTrue(scale < 1.0, "Scale should be less than 1.0")
        try assertTrue(size.width <= 1920, "Width should be <= 1920, got \(size.width)")
        try assertTrue(size.height <= 1080, "Height should be <= 1080, got \(size.height)")
    }

    test("1080p video on 4K screen keeps original resolution") {
        let (scale, size) = calculateRenderSize(
            videoSize: CGSize(width: 1920, height: 1080),
            screenSize: CGSize(width: 3840, height: 2160),
            optimizeResolution: true
        )
        try assertEqual(scale, 1.0)
        try assertEqual(size.width, 1920)
        try assertEqual(size.height, 1080)
    }

    test("optimizeResolution=false keeps original resolution for 4K") {
        let (scale, _) = calculateRenderSize(
            videoSize: CGSize(width: 3840, height: 2160),
            screenSize: CGSize(width: 1920, height: 1080),
            optimizeResolution: false
        )
        try assertEqual(scale, 1.0)
    }

    test("Zero video size returns early without division by zero") {
        let (scale, size) = calculateRenderSize(
            videoSize: CGSize(width: 0, height: 0),
            screenSize: CGSize(width: 1920, height: 1080),
            optimizeResolution: true
        )
        try assertEqual(scale, 1.0)
        try assertEqual(size.width, 0)
    }

    test("Portrait video (rotated) on landscape screen") {
        // Simulating a 1080x1920 portrait video on a 1920x1080 screen
        let (scale, size) = calculateRenderSize(
            videoSize: CGSize(width: 1080, height: 1920),
            screenSize: CGSize(width: 1920, height: 1080),
            optimizeResolution: true
        )
        // The limiting factor is height: 1080/1920 = 0.5625
        try assertTrue(scale < 1.0, "Scale should be < 1.0 for portrait on landscape")
        try assertTrue(size.height <= 1080, "Height should be <= 1080")
    }

    // MARK: Frame Rate Tests

    test("30 fps cap on 60 fps video applies") {
        let (capFPS, timescale, shouldApply) = calculateFrameRate(
            frameRateCap: 30, nativeFPS: 60
        )
        try assertEqual(capFPS, 30)
        try assertEqual(timescale, 30)
        try assertTrue(shouldApply, "Should apply FPS cap")
    }

    test("0 cap (unlimited) uses native FPS") {
        let (capFPS, _, shouldApply) = calculateFrameRate(
            frameRateCap: 0, nativeFPS: 60
        )
        try assertEqual(capFPS, 60)
        try assertFalse(shouldApply, "Should not apply when cap >= native")
    }

    test("Cap higher than native does not apply") {
        let (_, _, shouldApply) = calculateFrameRate(
            frameRateCap: 60, nativeFPS: 30
        )
        try assertFalse(shouldApply, "60 cap on 30 native should not apply")
    }

    test("Timescale is clamped to 600 max") {
        let (_, timescale, _) = calculateFrameRate(
            frameRateCap: 0, nativeFPS: 10000
        )
        try assertTrue(timescale <= 600, "Timescale should be clamped to 600, got \(timescale)")
    }

    test("Timescale is at least 1") {
        let (_, timescale, _) = calculateFrameRate(
            frameRateCap: 0, nativeFPS: 0
        )
        try assertTrue(timescale >= 1, "Timescale should be at least 1, got \(timescale)")
    }
}
