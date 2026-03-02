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
    Sources/Localization.swift \
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

echo "==> 產生 App Icon..."
# Scale icon to 82% of canvas (Chrome-like padding) using a temporary Swift script
ICON_TMP=$(mktemp /tmp/App_Icon_padded_XXXX.png)
swift - "$ICON_TMP" <<'SWIFT'
import AppKit
let dstPath = CommandLine.arguments[1]
let srcPath = "Sources/App_Icon.png"
guard let srcImage = NSImage(contentsOfFile: srcPath) else {
    fputs("Error: cannot load \(srcPath)\n", stderr); exit(1)
}
let canvas = 1024
let scale  = 0.82
let size   = Int(Double(canvas) * scale)
let offset = (canvas - size) / 2
let result = NSImage(size: NSSize(width: canvas, height: canvas))
result.lockFocus()
NSColor.clear.set()
NSRect(x: 0, y: 0, width: canvas, height: canvas).fill()
srcImage.draw(in: NSRect(x: offset, y: offset, width: size, height: size),
              from: .zero, operation: .copy, fraction: 1.0)
result.unlockFocus()
guard let tiff   = result.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png    = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Error: cannot encode PNG\n", stderr); exit(1)
}
try! png.write(to: URL(fileURLWithPath: dstPath))
SWIFT

ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
mkdir -p "${ICONSET_DIR}"
sips -z 16   16   "${ICON_TMP}" --out "${ICONSET_DIR}/icon_16x16.png"      > /dev/null
sips -z 32   32   "${ICON_TMP}" --out "${ICONSET_DIR}/icon_16x16@2x.png"   > /dev/null
sips -z 32   32   "${ICON_TMP}" --out "${ICONSET_DIR}/icon_32x32.png"      > /dev/null
sips -z 64   64   "${ICON_TMP}" --out "${ICONSET_DIR}/icon_32x32@2x.png"   > /dev/null
sips -z 128  128  "${ICON_TMP}" --out "${ICONSET_DIR}/icon_128x128.png"    > /dev/null
sips -z 256  256  "${ICON_TMP}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
sips -z 256  256  "${ICON_TMP}" --out "${ICONSET_DIR}/icon_256x256.png"    > /dev/null
sips -z 512  512  "${ICON_TMP}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
sips -z 512  512  "${ICON_TMP}" --out "${ICONSET_DIR}/icon_512x512.png"    > /dev/null
sips -z 1024 1024 "${ICON_TMP}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null
iconutil -c icns "${ICONSET_DIR}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
rm -f "${ICON_TMP}"
rm -rf "$(dirname "${ICONSET_DIR}")"

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
