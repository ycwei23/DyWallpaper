#!/usr/bin/env bash
set -euo pipefail

SDK=$(xcrun --show-sdk-path)
BUILD_DIR="build/tests"
BINARY="${BUILD_DIR}/DyWallpaperTests"

echo "==> Cleaning test build..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

echo "==> Compiling tests..."
swiftc \
    Sources/AppSettings.swift \
    Sources/Localization.swift \
    Tests/TestRunner.swift \
    Tests/LocalizationTests.swift \
    Tests/AppSettingsTests.swift \
    Tests/PowerOptimizationTests.swift \
    Tests/main.swift \
    -o "${BINARY}" \
    -sdk "${SDK}" \
    -target arm64-apple-macosx13.0 \
    -swift-version 5 \
    -framework Foundation \
    -framework AVFoundation \
    -framework CoreMedia \
    -Onone

echo "==> Running tests..."
echo ""
"${BINARY}"
