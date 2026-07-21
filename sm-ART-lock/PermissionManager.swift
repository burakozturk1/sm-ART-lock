import AppKit
import ApplicationServices
import IOKit.hid

final class PermissionManager: ObservableObject {
    @Published private(set) var isAccessibilityTrusted = false
    @Published private(set) var isInputMonitoringGranted = false

    var canAttemptKeyboardBlocking: Bool {
        isAccessibilityTrusted || isInputMonitoringGranted
    }

    init() {
        refresh()
    }

    func refresh() {
        isAccessibilityTrusted = AXIsProcessTrusted()
        isInputMonitoringGranted = checkInputMonitoring()
    }

    func requestAccessibilityPermission() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary

        isAccessibilityTrusted = AXIsProcessTrustedWithOptions(options)
    }

    func requestInputMonitoringPermission() {
        IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        refresh()
    }

    func openAccessibilitySettings() {
        openSettingsPane("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    }

    func openInputMonitoringSettings() {
        openSettingsPane("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    private func checkInputMonitoring() -> Bool {
        IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOHIDAccessTypeGranted
    }

    private func openSettingsPane(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
