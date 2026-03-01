#!/usr/bin/env bash
set -euo pipefail

APP_NAME="DyWallpaper"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
BINARY="${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
INSTALL_PATH="/Applications/${APP_NAME}.app"
SDK=$(xcrun --show-sdk-path)

echo "==> 清除舊的建置..."
rm -rf "${BUILD_DIR}"

echo "==> 建立 App Bundle 結構..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

echo "==> 編譯 Swift 原始碼..."
swiftc \
    Sources/main.swift \
    Sources/AppSettings.swift \
    Sources/AppDelegate.swift \
    Sources/WallpaperWindow.swift \
    Sources/SettingsView.swift \
    Sources/SettingsWindowController.swift \
    -o "${BINARY}" \
    -sdk "${SDK}" \
    -target arm64-apple-macosx13.0 \
    -swift-version 5 \
    -framework AppKit \
    -framework AVFoundation \
    -framework CoreMedia \
    -framework QuartzCore \
    -framework ServiceManagement \
    -framework SwiftUI \
    -framework Combine \
    -Onone

echo "==> 複製 Info.plist..."
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"

echo "==> 簽署 App（ad-hoc）..."
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null || true

echo "==> 安裝到 /Applications..."
rm -rf "${INSTALL_PATH}"
cp -R "${APP_BUNDLE}" "${INSTALL_PATH}"

# Restart if already running
if pgrep -x "${APP_NAME}" > /dev/null; then
    echo "==> 重新啟動 App..."
    pkill -x "${APP_NAME}" || true
    sleep 0.5
fi
open "${INSTALL_PATH}"

echo ""
echo "✅ 安裝完成：${INSTALL_PATH}"
echo "   App 已在選單列啟動。"
