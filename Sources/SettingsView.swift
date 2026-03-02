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

    private var loc: Loc { Loc(settings.language) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Form {
                videoSection
                displaySection
                performanceSection
                audioSection
                generalSection
                languageSection
            }
            .formStyle(.grouped)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 420, height: 560)
    }

    // MARK: - Sections

    private var videoSection: some View {
        Section {
            LabeledContent(loc.currentVideo) {
                if let url = settings.currentVideoURL {
                    Text(url.lastPathComponent)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    Text(loc.noVideoSelected)
                        .foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 8) {
                Button(loc.selectVideo, action: onSelectVideo)
                if settings.isPlaying {
                    Button(loc.stopPlayback, role: .destructive, action: onStopPlayback)
                } else if settings.currentVideoURL != nil {
                    Button(loc.resumePlayback, action: onResumePlayback)
                }
                Spacer()
            }

            Picker(loc.playbackSpeed, selection: $settings.playbackSpeed) {
                Text("0.25×").tag(0.25)
                Text("0.5×").tag(0.5)
                Text("0.75×").tag(0.75)
                Text("1×  (\(loc.playbackSpeedNormal))").tag(1.0)
                Text("1.5×").tag(1.5)
                Text("2×").tag(2.0)
            }
        } header: {
            Label(loc.sectionVideo, systemImage: "film")
        }
    }

    private var displaySection: some View {
        Section {
            Picker(loc.fillMode, selection: $settings.videoGravityRaw) {
                Text(loc.fillAspectFill)
                    .tag(AVLayerVideoGravity.resizeAspectFill.rawValue)
                Text(loc.fillAspectFit)
                    .tag(AVLayerVideoGravity.resizeAspect.rawValue)
                Text(loc.fillStretch)
                    .tag(AVLayerVideoGravity.resize.rawValue)
            }
            .pickerStyle(.radioGroup)
        } header: {
            Label(loc.sectionDisplay, systemImage: "display")
        } footer: {
            Text(loc.displayFooter)
                .foregroundStyle(.secondary)
        }
    }

    private var performanceSection: some View {
        Section {
            Picker(loc.maxFrameRate, selection: $settings.frameRateCap) {
                Text(loc.fps24).tag(24)
                Text(loc.fps30).tag(30)
                Text(loc.fps60).tag(60)
                Text(loc.fpsUnlimited).tag(0)
            }

            Toggle(loc.optimizeResolutionLabel, isOn: $settings.optimizeResolution)

            if settings.optimizeResolution {
                Text(loc.optimizeResolutionDesc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Label(loc.sectionPerformance, systemImage: "bolt")
        } footer: {
            Text(loc.performanceFooter)
                .foregroundStyle(.secondary)
        }
    }

    private var audioSection: some View {
        Section {
            Toggle(loc.mute, isOn: $settings.isMuted)

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
            Label(loc.sectionAudio, systemImage: "speaker.wave.2")
        }
    }

    private var generalSection: some View {
        Section {
            Toggle(isOn: Binding(
                get:  { SMAppService.mainApp.status == .enabled },
                set:  { _ in onToggleLogin() }
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.launchAtLogin)
                    Text(loc.launchAtLoginNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label(loc.sectionGeneral, systemImage: "gearshape")
        }
    }

    private var languageSection: some View {
        Section {
            Picker(loc.sectionLanguage, selection: $settings.language) {
                ForEach(Language.allCases, id: \.self) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
        } header: {
            Label(loc.sectionLanguage, systemImage: "globe")
        }
    }
}
