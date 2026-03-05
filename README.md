# DyWallpaper

A macOS menu-bar app that plays a local video file as your desktop wallpaper.

---

[繁體中文](#繁體中文) | [简体中文](#简体中文) | [日本語](#日本語) | [한국어](#한국어)

---

## Screenshots

> **Coming soon** — screenshots and a demo GIF will be added here.

## Features

- Play any local video file (MP4, MOV, AVI, etc.) as your desktop wallpaper
- Multi-display support — wallpaper plays on all connected screens
- Adjustable fill modes: Fill (crop), Fit (letterbox), or Stretch
- Frame rate cap (24/30/60 fps or unlimited) for battery and GPU savings
- Resolution optimisation — automatically scales to screen size for 4K videos
- Adjustable playback speed (0.25x to 2x)
- Volume control with mute toggle
- Power-aware — pauses on sleep, screen lock, and screensaver
- Launch at login support
- Multi-language UI: English, 繁體中文, 简体中文, 日本語, 한국어
- Lightweight — no external dependencies, uses only system frameworks

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon (arm64)

## Install

Clone the repo and run the build script:

```bash
git clone https://github.com/ycwei23/DyWallpaper.git
cd DyWallpaper
bash build.sh
```

The app will be installed to `/Applications/DyWallpaper.app` and launched automatically.

For a debug build (no compiler optimisation, faster compilation):

```bash
bash build.sh debug
```

> **Note:** Because the app is not signed with an Apple Developer ID, macOS may block it on first launch. To open it, right-click the app → **Open**, then click **Open** in the security dialog. Or go to **System Settings → Privacy & Security** and click **Open Anyway**.

## Usage

1. Click the `⊡` icon in the menu bar
2. Select **Select Video…** and pick a video file
3. The video starts playing as your desktop wallpaper on all connected displays
4. Open **Preferences…** to adjust fill mode, frame rate, resolution, and audio settings

## Finding Wallpaper Videos

Looking for live wallpaper videos? Here are some good sources:

- [MoeWalls](https://moewalls.com/) — Anime-style live wallpapers
- [MotionBGS](https://motionbgs.com/) — A wide variety of animated backgrounds

Download a video from either site, then use **Select Video…** in DyWallpaper to set it as your wallpaper.

## Contributing

Contributions are welcome! To get started:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Test by running `bash build.sh` and verifying the app works
5. Commit your changes (`git commit -m 'feat: add my feature'`)
6. Push to the branch (`git push origin feature/my-feature`)
7. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

## License

MIT

---

## 繁體中文

將本機影片播放為 macOS 桌面動態桌布的選單列 App。

### 功能特色

- 播放任何本機影片（MP4、MOV、AVI 等）作為桌面桌布
- 多螢幕支援 — 桌布在所有已連接的螢幕上同步播放
- 可調整填充方式：填滿（裁切）、等比縮放（黑邊）、拉伸
- 幀率上限（24/30/60 fps 或不限制）以節省電力和 GPU
- 解析度最佳化 — 自動縮放至螢幕大小，適合 4K 影片
- 可調整播放速度（0.25x 至 2x）
- 音量控制與靜音切換
- 電源感知 — 睡眠、螢幕鎖定、螢幕保護程式時自動暫停
- 開機自動啟動
- 多語言介面：English、繁體中文、简体中文、日本語、한국어
- 輕量 — 無外部依賴，僅使用系統框架

### 系統需求

- macOS 13.0（Ventura）或更新版本
- Apple Silicon（arm64）

### 安裝

Clone 此專案並執行建置腳本：

```bash
git clone https://github.com/ycwei23/DyWallpaper.git
cd DyWallpaper
bash build.sh
```

App 會自動安裝至 `/Applications/DyWallpaper.app` 並啟動。

> **注意：** 由於此 App 未使用 Apple Developer ID 簽署，首次開啟時 macOS 可能會阻擋。請在 Finder 中對 App 按右鍵 → **打開**，再於安全性對話框中點擊**打開**。或前往**系統設定 → 隱私權與安全性**，點擊**仍要打開**。

### 使用方式

1. 點擊選單列中的 `⊡` 圖示
2. 選擇**選擇影片…**，挑選一個影片檔案
3. 影片會立即在所有已連接的螢幕上播放為桌布
4. 開啟**偏好設定…**，可調整填充方式、幀率、解析度及音訊設定

### 尋找動態桌布影片

以下網站提供豐富的動態桌布影片素材：

- [MoeWalls](https://moewalls.com/) — 動漫風格動態桌布
- [MotionBGS](https://motionbgs.com/) — 多種風格的動態背景

下載喜歡的影片後，透過 DyWallpaper 的**選擇影片…**即可設定為桌布。

---

## 简体中文

将本地视频播放为 macOS 桌面动态壁纸的菜单栏 App。

### 功能特色

- 播放任何本地视频（MP4、MOV、AVI 等）作为桌面壁纸
- 多显示器支持 — 壁纸在所有已连接的显示器上同步播放
- 可调整填充方式：填满（裁剪）、等比缩放（黑边）、拉伸
- 帧率上限（24/30/60 fps 或不限制）以节省电量和 GPU
- 分辨率优化 — 自动缩放至屏幕大小，适合 4K 视频
- 可调整播放速度（0.25x 至 2x）
- 音量控制与静音切换
- 电源感知 — 睡眠、锁屏、屏保时自动暂停
- 开机自动启动
- 多语言界面：English、繁體中文、简体中文、日本語、한국어
- 轻量 — 无外部依赖，仅使用系统框架

### 系统要求

- macOS 13.0（Ventura）或更高版本
- Apple Silicon（arm64）

### 安装

克隆此项目并运行构建脚本：

```bash
git clone https://github.com/ycwei23/DyWallpaper.git
cd DyWallpaper
bash build.sh
```

App 将自动安装至 `/Applications/DyWallpaper.app` 并启动。

> **注意：** 由于此 App 未使用 Apple Developer ID 签名，首次启动时 macOS 可能会阻止运行。请在 Finder 中右键点击 App → **打开**，然后在安全对话框中点击**打开**。或前往**系统设置 → 隐私与安全性**，点击**仍要打开**。

### 使用方法

1. 点击菜单栏中的 `⊡` 图标
2. 选择**选择视频…**，选取一个视频文件
3. 视频将立即在所有已连接的显示器上作为壁纸播放
4. 打开**偏好设置…**，可调整填充方式、帧率、分辨率及音频设置

### 寻找动态壁纸视频

以下网站提供丰富的动态壁纸视频素材：

- [MoeWalls](https://moewalls.com/) — 动漫风格动态壁纸
- [MotionBGS](https://motionbgs.com/) — 多种风格的动态背景

下载喜欢的视频后，通过 DyWallpaper 的**选择视频…**即可设置为壁纸。

---

## 日本語

ローカルの動画ファイルを macOS のデスクトップ壁紙として再生するメニューバー App です。

### 主な機能

- あらゆるローカル動画（MP4、MOV、AVI など）をデスクトップ壁紙として再生
- マルチディスプレイ対応 — 接続中のすべてのディスプレイで壁紙を同期再生
- フィルモード調整：塗りつぶし（クリップ）、フィット（レターボックス）、引き伸ばし
- フレームレート制限（24/30/60 fps または無制限）で省電力・GPU 負荷軽減
- 解像度最適化 — 4K 動画を画面サイズに自動スケーリング
- 再生速度調整（0.25x～2x）
- 音量コントロールとミュート切替
- 省電力対応 — スリープ、画面ロック、スクリーンセーバー時に自動一時停止
- ログイン時に自動起動
- 多言語 UI：English、繁體中文、简体中文、日本語、한국어
- 軽量 — 外部依存なし、システムフレームワークのみ使用

### 動作環境

- macOS 13.0（Ventura）以降
- Apple Silicon（arm64）

### インストール

リポジトリをクローンし、ビルドスクリプトを実行してください：

```bash
git clone https://github.com/ycwei23/DyWallpaper.git
cd DyWallpaper
bash build.sh
```

App は自動的に `/Applications/DyWallpaper.app` にインストールされ、起動します。

> **注意：** この App は Apple Developer ID で署名されていないため、初回起動時に macOS がブロックする場合があります。Finder で App を右クリック → **開く** を選択し、セキュリティダイアログで**開く**をクリックしてください。または**システム設定 → プライバシーとセキュリティ**から**このまま開く**をクリックしてください。

### 使い方

1. メニューバーの `⊡` アイコンをクリック
2. **動画を選択…** から動画ファイルを選ぶ
3. 選択した動画が接続中のすべてのディスプレイで壁紙として再生される
4. **環境設定…** を開き、フィルモード・フレームレート・解像度・音声を調整できる

### 壁紙動画の探し方

ライブ壁紙動画を探すなら、以下のサイトがおすすめです：

- [MoeWalls](https://moewalls.com/) — アニメ風ライブ壁紙
- [MotionBGS](https://motionbgs.com/) — さまざまなジャンルのアニメーション背景

お気に入りの動画をダウンロードしたら、DyWallpaper の**動画を選択…**で壁紙として設定できます。

---

## 한국어

로컬 동영상 파일을 macOS 데스크탑 배경화면으로 재생하는 메뉴바 App입니다.

### 주요 기능

- 모든 로컬 동영상(MP4, MOV, AVI 등)을 데스크탑 배경화면으로 재생
- 멀티 디스플레이 지원 — 연결된 모든 디스플레이에서 배경화면 동기 재생
- 채우기 방식 조정: 채우기(자르기), 맞춤(레터박스), 늘이기
- 프레임 레이트 제한(24/30/60 fps 또는 무제한)으로 전력 및 GPU 절약
- 해상도 최적화 — 4K 동영상을 화면 크기에 자동 스케일링
- 재생 속도 조절(0.25x~2x)
- 볼륨 조절 및 음소거 전환
- 전원 감지 — 잠자기, 화면 잠금, 화면보호기 시 자동 일시정지
- 로그인 시 자동 시작
- 다국어 UI: English, 繁體中文, 简体中文, 日本語, 한국어
- 경량 — 외부 의존성 없이 시스템 프레임워크만 사용

### 시스템 요구사항

- macOS 13.0（Ventura）이상
- Apple Silicon（arm64）

### 설치

저장소를 클론한 후 빌드 스크립트를 실행하세요：

```bash
git clone https://github.com/ycwei23/DyWallpaper.git
cd DyWallpaper
bash build.sh
```

App은 `/Applications/DyWallpaper.app`에 자동으로 설치되고 실행됩니다.

> **참고：** 이 App은 Apple Developer ID로 서명되지 않았기 때문에 처음 실행 시 macOS가 차단할 수 있습니다. Finder에서 App을 오른쪽 클릭 → **열기**를 선택한 후, 보안 대화상자에서 **열기**를 클릭하세요. 또는 **시스템 설정 → 개인 정보 보호 및 보안**에서 **그래도 열기**를 클릭하세요.

### 사용 방법

1. 메뉴바의 `⊡` 아이콘 클릭
2. **동영상 선택…** 에서 동영상 파일 선택
3. 연결된 모든 디스플레이에서 동영상이 배경화면으로 재생됨
4. **환경설정…** 을 열어 채우기 방식, 프레임레이트, 해상도, 오디오 설정 조절 가능

### 배경화면 동영상 찾기

라이브 배경화면 동영상을 찾고 있다면 아래 사이트를 추천합니다：

- [MoeWalls](https://moewalls.com/) — 애니메이션 스타일 라이브 배경화면
- [MotionBGS](https://motionbgs.com/) — 다양한 장르의 움직이는 배경

마음에 드는 동영상을 다운로드한 후, DyWallpaper의 **동영상 선택…** 으로 배경화면으로 설정하세요.
