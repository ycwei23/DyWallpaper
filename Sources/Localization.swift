import Foundation

enum Language: String, CaseIterable, Codable {
    case english           = "en"
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese  = "zh-Hans"
    case japanese          = "ja"
    case korean            = "ko"

    var displayName: String {
        switch self {
        case .english:            return "English"
        case .traditionalChinese: return "繁體中文"
        case .simplifiedChinese:  return "简体中文"
        case .japanese:           return "日本語"
        case .korean:             return "한국어"
        }
    }
}

/// Localization helper. Initialise with the current language and read string properties.
struct Loc {
    let lang: Language
    init(_ lang: Language) { self.lang = lang }

    // MARK: - Section Headers

    var sectionVideo: String {
        switch lang {
        case .english:            return "Video"
        case .traditionalChinese: return "影片"
        case .simplifiedChinese:  return "视频"
        case .japanese:           return "ビデオ"
        case .korean:             return "비디오"
        }
    }

    var sectionDisplay: String {
        switch lang {
        case .english:            return "Display"
        case .traditionalChinese: return "顯示"
        case .simplifiedChinese:  return "显示"
        case .japanese:           return "表示"
        case .korean:             return "디스플레이"
        }
    }

    var sectionPerformance: String {
        switch lang {
        case .english:            return "Performance"
        case .traditionalChinese: return "效能"
        case .simplifiedChinese:  return "性能"
        case .japanese:           return "パフォーマンス"
        case .korean:             return "성능"
        }
    }

    var sectionAudio: String {
        switch lang {
        case .english:            return "Audio"
        case .traditionalChinese: return "音訊"
        case .simplifiedChinese:  return "音频"
        case .japanese:           return "オーディオ"
        case .korean:             return "오디오"
        }
    }

    var sectionGeneral: String {
        switch lang {
        case .english:            return "General"
        case .traditionalChinese: return "一般"
        case .simplifiedChinese:  return "通用"
        case .japanese:           return "一般"
        case .korean:             return "일반"
        }
    }

    var sectionLanguage: String {
        switch lang {
        case .english:            return "Language"
        case .traditionalChinese: return "語言"
        case .simplifiedChinese:  return "语言"
        case .japanese:           return "言語"
        case .korean:             return "언어"
        }
    }

    // MARK: - Video Section

    var currentVideo: String {
        switch lang {
        case .english:            return "Current Video"
        case .traditionalChinese: return "目前影片"
        case .simplifiedChinese:  return "当前视频"
        case .japanese:           return "現在のビデオ"
        case .korean:             return "현재 동영상"
        }
    }

    var noVideoSelected: String {
        switch lang {
        case .english:            return "Not Selected"
        case .traditionalChinese: return "尚未選擇"
        case .simplifiedChinese:  return "未选择"
        case .japanese:           return "未選択"
        case .korean:             return "선택 안 됨"
        }
    }

    var selectVideo: String {
        switch lang {
        case .english:            return "Select Video…"
        case .traditionalChinese: return "選擇影片…"
        case .simplifiedChinese:  return "选择视频…"
        case .japanese:           return "ビデオを選択…"
        case .korean:             return "동영상 선택…"
        }
    }

    var stopPlayback: String {
        switch lang {
        case .english:            return "Stop"
        case .traditionalChinese: return "停止播放"
        case .simplifiedChinese:  return "停止播放"
        case .japanese:           return "停止"
        case .korean:             return "재생 중지"
        }
    }

    var resumePlayback: String {
        switch lang {
        case .english:            return "Resume"
        case .traditionalChinese: return "重新播放"
        case .simplifiedChinese:  return "重新播放"
        case .japanese:           return "再開"
        case .korean:             return "다시 재생"
        }
    }

    var playbackSpeed: String {
        switch lang {
        case .english:            return "Playback Speed"
        case .traditionalChinese: return "播放速度"
        case .simplifiedChinese:  return "播放速度"
        case .japanese:           return "再生速度"
        case .korean:             return "재생 속도"
        }
    }

    var playbackSpeedNormal: String {
        switch lang {
        case .english:            return "Normal"
        case .traditionalChinese: return "正常"
        case .simplifiedChinese:  return "正常"
        case .japanese:           return "標準"
        case .korean:             return "기본"
        }
    }

    // MARK: - Display Section

    var fillMode: String {
        switch lang {
        case .english:            return "Fill Mode"
        case .traditionalChinese: return "填充方式"
        case .simplifiedChinese:  return "填充方式"
        case .japanese:           return "塗りつぶし方法"
        case .korean:             return "채우기 방식"
        }
    }

    var fillAspectFill: String {
        switch lang {
        case .english:            return "Fill (Crop Edges)"
        case .traditionalChinese: return "填滿（超出範圍裁切）"
        case .simplifiedChinese:  return "填满（裁剪边缘）"
        case .japanese:           return "塗りつぶし（端をクリップ）"
        case .korean:             return "채우기（가장자리 자름）"
        }
    }

    var fillAspectFit: String {
        switch lang {
        case .english:            return "Fit (Letterbox)"
        case .traditionalChinese: return "等比縮放（邊緣保留黑邊）"
        case .simplifiedChinese:  return "等比例缩放（保留黑边）"
        case .japanese:           return "フィット（レターボックス）"
        case .korean:             return "맞춤（레터박스）"
        }
    }

    var fillStretch: String {
        switch lang {
        case .english:            return "Stretch (Ignore Aspect)"
        case .traditionalChinese: return "拉伸填滿（不保持比例）"
        case .simplifiedChinese:  return "拉伸填满（忽略比例）"
        case .japanese:           return "引き伸ばし（比率無視）"
        case .korean:             return "늘이기（비율 무시）"
        }
    }

    var displayFooter: String {
        switch lang {
        case .english:            return "Takes effect immediately."
        case .traditionalChinese: return "設定後立即生效。"
        case .simplifiedChinese:  return "设置后立即生效。"
        case .japanese:           return "設定後すぐに反映されます。"
        case .korean:             return "설정 후 즉시 적용됩니다."
        }
    }

    // MARK: - Performance Section

    var maxFrameRate: String {
        switch lang {
        case .english:            return "Max Frame Rate"
        case .traditionalChinese: return "最高幀率"
        case .simplifiedChinese:  return "最高帧率"
        case .japanese:           return "最大フレームレート"
        case .korean:             return "최대 프레임 레이트"
        }
    }

    var fps24: String {
        switch lang {
        case .english:            return "24 fps (Power Saving, Cinematic)"
        case .traditionalChinese: return "24 fps（省電，電影風格）"
        case .simplifiedChinese:  return "24 fps（省电，电影风格）"
        case .japanese:           return "24 fps（省電力、映画風）"
        case .korean:             return "24 fps（절전, 영화 스타일）"
        }
    }

    var fps30: String {
        switch lang {
        case .english:            return "30 fps (Balanced)"
        case .traditionalChinese: return "30 fps（平衡）"
        case .simplifiedChinese:  return "30 fps（均衡）"
        case .japanese:           return "30 fps（バランス）"
        case .korean:             return "30 fps（균형）"
        }
    }

    var fps60: String {
        switch lang {
        case .english:            return "60 fps (Smooth)"
        case .traditionalChinese: return "60 fps（流暢）"
        case .simplifiedChinese:  return "60 fps（流畅）"
        case .japanese:           return "60 fps（スムーズ）"
        case .korean:             return "60 fps（부드러움）"
        }
    }

    var fpsUnlimited: String {
        switch lang {
        case .english:            return "Unlimited (Native Frame Rate)"
        case .traditionalChinese: return "不限制（影片原始幀率）"
        case .simplifiedChinese:  return "不限制（视频原始帧率）"
        case .japanese:           return "無制限（動画のフレームレート）"
        case .korean:             return "무제한（영상 기본 프레임 레이트）"
        }
    }

    var optimizeResolutionLabel: String {
        switch lang {
        case .english:            return "Limit Render to Screen Resolution"
        case .traditionalChinese: return "依螢幕解析度限制渲染"
        case .simplifiedChinese:  return "根据屏幕分辨率限制渲染"
        case .japanese:           return "画面解像度に合わせてレンダリングを制限"
        case .korean:             return "화면 해상도에 맞게 렌더링 제한"
        }
    }

    var optimizeResolutionDesc: String {
        switch lang {
        case .english:
            return "Caps decode resolution to screen size, significantly reducing GPU usage for 4K videos."
        case .traditionalChinese:
            return "將解碼解析度上限設為螢幕大小，大幅降低 4K 影片的 GPU 使用量。"
        case .simplifiedChinese:
            return "将解码分辨率上限设为屏幕大小，大幅降低4K视频的GPU使用量。"
        case .japanese:
            return "デコード解像度を画面サイズに制限し、4K動画のGPU使用量を大幅に削減します。"
        case .korean:
            return "디코딩 해상도를 화면 크기로 제한하여 4K 동영상의 GPU 사용량을 크게 줄입니다."
        }
    }

    var performanceFooter: String {
        switch lang {
        case .english:
            return "Frame rate and resolution settings take effect immediately by restarting playback."
        case .traditionalChinese:
            return "幀率與解析度設定會立即重新播放以套用變更。"
        case .simplifiedChinese:
            return "帧率和分辨率设置会立即重新播放以应用更改。"
        case .japanese:
            return "フレームレートと解像度の設定は再生を再開して即座に適用されます。"
        case .korean:
            return "프레임 레이트 및 해상도 설정은 재생을 다시 시작하여 즉시 적용됩니다."
        }
    }

    // MARK: - General Section

    var launchAtLogin: String {
        switch lang {
        case .english:            return "Launch at Login"
        case .traditionalChinese: return "開機自動啟動"
        case .simplifiedChinese:  return "开机自动启动"
        case .japanese:           return "ログイン時に起動"
        case .korean:             return "로그인 시 시작"
        }
    }

    var launchAtLoginNote: String {
        switch lang {
        case .english:            return "Requires the app to be installed in /Applications"
        case .traditionalChinese: return "需要 App 已安裝於 /Applications 資料夾"
        case .simplifiedChinese:  return "需要 App 已安装于 /Applications 文件夹"
        case .japanese:           return "アプリが /Applications フォルダにインストールされている必要があります"
        case .korean:             return "앱이 /Applications 폴더에 설치되어 있어야 합니다"
        }
    }

    // MARK: - Menu Strings

    var menuSelectVideo: String {
        switch lang {
        case .english:            return "Select Video…"
        case .traditionalChinese: return "選擇影片…"
        case .simplifiedChinese:  return "选择视频…"
        case .japanese:           return "ビデオを選択…"
        case .korean:             return "동영상 선택…"
        }
    }

    var menuResumePrefix: String {
        switch lang {
        case .english:            return "Resume: "
        case .traditionalChinese: return "重新播放："
        case .simplifiedChinese:  return "重新播放："
        case .japanese:           return "再開："
        case .korean:             return "다시 재생："
        }
    }

    var menuMute: String {
        switch lang {
        case .english:            return "Mute"
        case .traditionalChinese: return "靜音"
        case .simplifiedChinese:  return "静音"
        case .japanese:           return "ミュート"
        case .korean:             return "음소거"
        }
    }

    var menuUnmute: String {
        switch lang {
        case .english:            return "Unmute"
        case .traditionalChinese: return "取消靜音"
        case .simplifiedChinese:  return "取消静音"
        case .japanese:           return "ミュート解除"
        case .korean:             return "음소거 해제"
        }
    }

    var menuStopPlayback: String {
        switch lang {
        case .english:            return "Stop Playback"
        case .traditionalChinese: return "停止播放"
        case .simplifiedChinese:  return "停止播放"
        case .japanese:           return "再生を停止"
        case .korean:             return "재생 중지"
        }
    }

    var menuPreferences: String {
        switch lang {
        case .english:            return "Preferences…"
        case .traditionalChinese: return "偏好設定…"
        case .simplifiedChinese:  return "偏好设置…"
        case .japanese:           return "環境設定…"
        case .korean:             return "환경설정…"
        }
    }

    var menuQuit: String {
        switch lang {
        case .english:            return "Quit DyWallpaper"
        case .traditionalChinese: return "結束 DyWallpaper"
        case .simplifiedChinese:  return "退出 DyWallpaper"
        case .japanese:           return "DyWallpaper を終了"
        case .korean:             return "DyWallpaper 종료"
        }
    }

    // MARK: - Alert (Login Item)

    var alertLoginItemTitle: String {
        switch lang {
        case .english:            return "Cannot Set Launch at Login"
        case .traditionalChinese: return "無法設定開機自動啟動"
        case .simplifiedChinese:  return "无法设置开机自动启动"
        case .japanese:           return "ログイン時の起動を設定できません"
        case .korean:             return "로그인 시 시작을 설정할 수 없습니다"
        }
    }

    var alertLoginItemMessage: String {
        switch lang {
        case .english:
            return "Please make sure the app is installed in /Applications."
        case .traditionalChinese:
            return "請確認 App 已安裝到 /Applications 資料夾。"
        case .simplifiedChinese:
            return "请确认 App 已安装到 /Applications 文件夹。"
        case .japanese:
            return "アプリが /Applications フォルダにインストールされていることを確認してください。"
        case .korean:
            return "앱이 /Applications 폴더에 설치되어 있는지 확인하세요."
        }
    }

    var alertLoginItemErrorPrefix: String {
        switch lang {
        case .english:            return "\n\nError: "
        case .traditionalChinese: return "\n\n錯誤："
        case .simplifiedChinese:  return "\n\n错误："
        case .japanese:           return "\n\nエラー："
        case .korean:             return "\n\n오류："
        }
    }

    // MARK: - File Panel

    var panelTitle: String {
        switch lang {
        case .english:            return "Choose a video to use as the desktop background"
        case .traditionalChinese: return "選擇要當作桌面背景的影片"
        case .simplifiedChinese:  return "选择要作为桌面背景的视频"
        case .japanese:           return "デスクトップの背景として使用するビデオを選択"
        case .korean:             return "바탕화면 배경으로 사용할 동영상을 선택하세요"
        }
    }

    var panelPrompt: String {
        switch lang {
        case .english:            return "Set as Wallpaper"
        case .traditionalChinese: return "設為桌面背景"
        case .simplifiedChinese:  return "设为桌面背景"
        case .japanese:           return "壁紙として設定"
        case .korean:             return "배경화면으로 설정"
        }
    }
}
