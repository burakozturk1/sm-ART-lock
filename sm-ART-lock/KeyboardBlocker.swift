import AppKit
import Foundation

final class KeyboardBlocker: ObservableObject {
    @Published private(set) var isEnabled = false
    @Published private(set) var lastError: String?

    private let permissionManager: PermissionManager
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init(permissionManager: PermissionManager) {
        self.permissionManager = permissionManager
    }

    deinit {
        stop()
    }

    func toggle() {
        isEnabled ? stop() : start()
    }

    func start() {
        guard !isEnabled else {
            return
        }

        permissionManager.refresh()

        guard permissionManager.canAttemptKeyboardBlocking else {
            lastError = "Klavye kilidi için Accessibility veya Input Monitoring izni gerekiyor."
            return
        }

        let mask = Self.keyboardEventMask
        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: KeyboardBlocker.eventTapCallback,
            userInfo: userInfo
        ) else {
            permissionManager.refresh()
            lastError = "Event tap oluşturulamadı. macOS izinlerini kontrol edin."
            return
        }

        guard let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            CFMachPortInvalidate(tap)
            lastError = "Event tap run loop kaynağı oluşturulamadı."
            return
        }

        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        lastError = nil
        isEnabled = true
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isEnabled = false
    }

    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }

            return Unmanaged.passUnretained(event)
        }

        guard isEnabled, Self.isKeyboardEvent(type) else {
            return Unmanaged.passUnretained(event)
        }

        if type == .keyDown, Self.isUnlockShortcut(event) {
            DispatchQueue.main.async { [weak self] in
                self?.stop()
            }
            return nil
        }

        return nil
    }

    private static var keyboardEventMask: CGEventMask {
        let types: [CGEventType] = [.keyDown, .keyUp, .flagsChanged]

        return types.reduce(CGEventMask(0)) { mask, type in
            mask | (CGEventMask(1) << CGEventMask(type.rawValue))
        }
    }

    private static func isKeyboardEvent(_ type: CGEventType) -> Bool {
        type == .keyDown || type == .keyUp || type == .flagsChanged
    }

    private static func isUnlockShortcut(_ event: CGEvent) -> Bool {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        return keyCode == 29 && flags.contains(.maskCommand)
    }

    private static let eventTapCallback: CGEventTapCallBack = { proxy, type, event, userInfo in
        guard let userInfo else {
            return Unmanaged.passUnretained(event)
        }

        let blocker = Unmanaged<KeyboardBlocker>
            .fromOpaque(userInfo)
            .takeUnretainedValue()

        return blocker.handleEvent(proxy: proxy, type: type, event: event)
    }
}
