import SwiftUI

struct LockPopoverView: View {
    @ObservedObject var keyboardBlocker: KeyboardBlocker
    @ObservedObject var permissionManager: PermissionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            statusPanel
            actionButton
            shortcutInfo
            permissionPanel
            description
            quitButton
        }
        .padding(18)
        .frame(width: 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            permissionManager.refresh()
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: keyboardBlocker.isEnabled ? "lock.fill" : "lock.open")
                .font(.title2)
                .foregroundStyle(keyboardBlocker.isEnabled ? .red : .primary)

            Text("sm-ART-lock")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(keyboardBlocker.isEnabled ? "Temizleme Modu Açık" : "Temizleme Modu Kapalı")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(keyboardBlocker.isEnabled ? .red : .primary)

            if let error = keyboardBlocker.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButton: some View {
        Button {
            keyboardBlocker.toggle()
            permissionManager.refresh()
        } label: {
            Label(
                keyboardBlocker.isEnabled ? "Temizleme Modunu Kapat" : "Temizleme Modunu Aç",
                systemImage: keyboardBlocker.isEnabled ? "lock.open" : "lock"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(keyboardBlocker.isEnabled ? .red : .accentColor)
    }

    private var shortcutInfo: some View {
        HStack(spacing: 8) {
            Image(systemName: "keyboard")
                .foregroundStyle(.secondary)

            Text("Mod açıkken yalnızca Command + 0 ile kapatılır.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var permissionPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("İzin Durumu")
                .font(.headline)

            PermissionRow(
                title: "Accessibility",
                isGranted: permissionManager.isAccessibilityTrusted
            )

            PermissionRow(
                title: "Input Monitoring",
                isGranted: permissionManager.isInputMonitoringGranted
            )

            HStack(spacing: 8) {
                Button("Accessibility Aç") {
                    permissionManager.requestAccessibilityPermission()
                    permissionManager.openAccessibilitySettings()
                }

                Button("Input Monitoring Aç") {
                    permissionManager.requestInputMonitoringPermission()
                    permissionManager.openInputMonitoringSettings()
                }

                Button {
                    permissionManager.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Yenile")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var description: some View {
        Text("MacBook veya klavye temizlerken yanlışlıkla tuş basılmasını önlemek için klavye girişlerini geçici olarak engeller. Mouse ve touchpad girişlerine müdahale etmez.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var quitButton: some View {
        Button {
            keyboardBlocker.stop()
            NSApplication.shared.terminate(nil)
        } label: {
            Label("Çıkış", systemImage: "power")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

private struct PermissionRow: View {
    let title: String
    let isGranted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .orange)

            Text(title)

            Spacer()

            Text(isGranted ? "Verildi" : "Gerekli")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
