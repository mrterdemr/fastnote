import SwiftUI

struct SettingsView: View {
    @AppStorage(AppearanceMode.storageKey)
    private var appearanceRaw = AppearanceMode.system.rawValue

    @AppStorage(LanguageMode.storageKey)
    private var languageRaw = LanguageMode.system.rawValue

    @ObservedObject private var settings = EditorSettings.shared

    @State private var showRestartAlert = false
    @State private var originalFontName: String? = nil
    @State private var originalFontSize: Double? = nil

    private var fontChanged: Bool {
        guard let name = originalFontName, let size = originalFontSize else { return false }
        return settings.fontName != name || settings.fontSize != size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            section("Appearance") {
                Picker("", selection: $appearanceRaw) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Divider()

            section("Language") {
                Picker("", selection: $languageRaw) {
                    ForEach(LanguageMode.allCases) { mode in
                        Text(verbatim: mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            section("Font") {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: settings.fontName)
                        Text(verbatim: "\(Int(settings.fontSize))pt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if fontChanged {
                        Button("Revert") {
                            settings.fontName = originalFontName!
                            settings.fontSize = originalFontSize!
                        }
                        .foregroundStyle(.red)
                    }
                    Button("Change…") { settings.openFontPanel() }
                }
            }
        }
        .padding(24)
        .frame(width: 340)
        .onAppear {
            originalFontName = settings.fontName
            originalFontSize = settings.fontSize
        }
        .onChange(of: appearanceRaw) { newValue in
            (AppearanceMode(rawValue: newValue) ?? .system).apply()
        }
        .onChange(of: languageRaw) { newValue in
            (LanguageMode(rawValue: newValue) ?? .system).apply()
            showRestartAlert = true
        }
        .alert("Language Changed", isPresented: $showRestartAlert) {
            Button("Restart Now") { restartApp() }
            Button("Later", role: .cancel) { }
        } message: {
            Text("Restart the app to apply the new language.")
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func restartApp() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [Bundle.main.bundleURL.path]
        task.launch()
        exit(0)
    }
}
