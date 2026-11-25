import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct AppSettingsView: View {
    @ObservedObject private var l10n = LocalizationManager.shared
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var requiresApproval = LaunchAtLogin.requiresApproval
    @State private var errorMessage: String?

    @State private var pendingImportBackup: SettingsBackup?
    @State private var showImportConfirm = false
    @State private var transferMessage: String?
    @State private var transferIsError = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }

    var body: some View {
        Form {
            Section(L10n.tr("settings.section.general", default: "General")) {
                Toggle(L10n.tr("settings.launchAtLogin", default: "Launch Automatically at Login"), isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        updateLaunchAtLogin(newValue)
                    }

                if requiresApproval {
                    Text(L10n.tr("settings.requiresApproval", default: "Approval is required in System Settings > General > Login Items."))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Picker(L10n.tr("settings.language", default: "Language"), selection: $l10n.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            }

            Section(L10n.tr("settings.section.backup", default: "Backup & Restore")) {
                HStack {
                    Button(L10n.tr("settings.export", default: "Export Settings…")) {
                        exportSettings()
                    }
                    Button(L10n.tr("settings.import", default: "Import Settings…")) {
                        importSettings()
                    }
                    Spacer()
                }

                Text(L10n.tr("settings.backup.caption", default: "Includes all pages, custom icons, and language preference."))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let transferMessage {
                    Text(transferMessage)
                        .font(.caption)
                        .foregroundStyle(transferIsError ? Color.red : Color.secondary)
                }
            }

            Section(L10n.tr("settings.section.about", default: "About")) {
                HStack(spacing: 12) {
                    if let icon = NSApp.applicationIconImage {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PopPage")
                            .font(.headline)
                        Text("\(L10n.tr("settings.version", default: "Version")) \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            refreshStatus()
        }
        .alert(L10n.tr("settings.importAlert.title", default: "Import Settings?"), isPresented: $showImportConfirm) {
            Button(L10n.tr("settings.importAlert.cancel", default: "Cancel"), role: .cancel) {
                pendingImportBackup = nil
            }
            Button(L10n.tr("settings.importAlert.confirm", default: "Import"), role: .destructive) {
                if let backup = pendingImportBackup {
                    SettingsTransfer.applyBackup(backup)
                    transferIsError = false
                    transferMessage = L10n.format("settings.import.success", default: "Imported %d page(s).", backup.pages.count)
                    pendingImportBackup = nil
                }
            }
        } message: {
            let count = pendingImportBackup?.pages.count ?? 0
            Text(L10n.format("settings.importAlert.message", default: "This will replace your current %d page(s) and settings with %d imported page(s).", PageStore.shared.pages.count, count))
        }
    }

    private func refreshStatus() {
        launchAtLogin = LaunchAtLogin.isEnabled
        requiresApproval = LaunchAtLogin.requiresApproval
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        guard enabled != LaunchAtLogin.isEnabled else { return }
        errorMessage = nil
        do {
            try LaunchAtLogin.setEnabled(enabled)
            refreshStatus()
        } catch {
            launchAtLogin = LaunchAtLogin.isEnabled
            requiresApproval = LaunchAtLogin.requiresApproval
            errorMessage = L10n.format("settings.launchAtLoginError", default: "Unable to update Launch at Login setting: %@", error.localizedDescription)
        }
    }

    private func exportSettings() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "PopPage-Settings.json"
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let backup = SettingsTransfer.makeBackup(pages: PageStore.shared.pages, language: l10n.language)
        do {
            try SettingsTransfer.exportBackup(backup, to: url)
            transferIsError = false
            transferMessage = L10n.tr("settings.export.success", default: "Settings exported successfully.")
        } catch {
            transferIsError = true
            transferMessage = L10n.format("settings.export.error", default: "Failed to export settings: %@", error.localizedDescription)
        }
    }

    private func importSettings() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let backup = try SettingsTransfer.readBackup(from: url)
            pendingImportBackup = backup
            showImportConfirm = true
        } catch {
            transferIsError = true
            transferMessage = L10n.format("settings.import.error", default: "Failed to import settings: %@", error.localizedDescription)
        }
    }
}
