import SwiftUI
import AVFoundation
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    // Callbacks to AppDelegate (avoid direct coupling)
    let onSelectVideo:    () -> Void
    let onStopPlayback:   () -> Void
    let onResumePlayback: () -> Void
    let onToggleLogin:    () -> Void

    var body: some View {
        Form {
            videoSection
            displaySection
            performanceSection
            audioSection
            generalSection
        }
        .formStyle(.grouped)
        // Fix the width; let SwiftUI calculate the height so NSHostingController
        // reports a non-zero preferredContentSize to NSWindow.
        .frame(width: 420)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Sections

    private var videoSection: some View {
        Section {
            LabeledContent("目前影片") {
                if let url = settings.currentVideoURL {
                    Text(url.lastPathComponent)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    Text("尚未選擇")
                        .foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 8) {
                Button("選擇影片…", action: onSelectVideo)
                if settings.isPlaying {
                    Button("停止播放", role: .destructive, action: onStopPlayback)
                } else if settings.currentVideoURL != nil {
                    Button("重新播放", action: onResumePlayback)
                }
                Spacer()
            }
        } header: {
            Label("影片", systemImage: "film")
        }
    }

    private var displaySection: some View {
        Section {
            Picker("填充方式", selection: $settings.videoGravityRaw) {
                Text("填滿（超出範圍裁切）")
                    .tag(AVLayerVideoGravity.resizeAspectFill.rawValue)
                Text("等比縮放（邊緣保留黑邊）")
                    .tag(AVLayerVideoGravity.resizeAspect.rawValue)
                Text("拉伸填滿（不保持比例）")
                    .tag(AVLayerVideoGravity.resize.rawValue)
            }
            .pickerStyle(.radioGroup)
        } header: {
            Label("顯示", systemImage: "display")
        } footer: {
            Text("設定後立即生效。")
                .foregroundStyle(.secondary)
        }
    }
    private var performanceSection: some View {
        Section {
            Picker("最高幀率", selection: $settings.frameRateCap) {
                Text("24 fps（省電，電影風格）").tag(24)
                Text("30 fps（平衡）").tag(30)
                Text("60 fps（流暢）").tag(60)
                Text("不限制（影片原始幀率）").tag(0)
            }

            Toggle("依螢幕解析度限制渲染", isOn: $settings.optimizeResolution)

            if settings.optimizeResolution {
                Text("將解碼解析度上限設為螢幕大小，大幅降低 4K 影片的 GPU 使用量。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Label("效能", systemImage: "bolt")
        } footer: {
            Text("幀率與解析度設定在下次播放影片時生效。")
                .foregroundStyle(.secondary)
        }
    }

    private var audioSection: some View {
        Section {
            Toggle("靜音", isOn: $settings.isMuted)

            if !settings.isMuted {
                HStack(spacing: 6) {
                    Image(systemName: "speaker.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                    Slider(value: $settings.volume, in: 0...1)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    Text("\(Int(settings.volume * 100))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }
            }
        } header: {
            Label("音訊", systemImage: "speaker.wave.2")
        }
    }

    private var generalSection: some View {
        Section {
            Toggle(isOn: Binding(
                get:  { SMAppService.mainApp.status == .enabled },
                set:  { _ in onToggleLogin() }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("開機自動啟動")
                    Text("需要 App 已安裝於 /Applications 資料夾")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label("一般", systemImage: "gearshape")
        }
    }
}
