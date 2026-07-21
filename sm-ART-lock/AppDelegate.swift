import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        menuBarController = MenuBarController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        menuBarController?.stop()
    }
}

final class MenuBarController {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let permissionManager: PermissionManager
    private let keyboardBlocker: KeyboardBlocker
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()

    init() {
        permissionManager = PermissionManager()
        keyboardBlocker = KeyboardBlocker(permissionManager: permissionManager)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        popover = NSPopover()

        configureStatusItem()
        configurePopover()
        bindState()
    }

    func stop() {
        keyboardBlocker.stop()

        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.action = #selector(togglePopover(_:))
        button.target = self
        updateStatusItem()
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 380, height: 420)
        popover.contentViewController = NSHostingController(
            rootView: LockPopoverView(
                keyboardBlocker: keyboardBlocker,
                permissionManager: permissionManager
            )
        )

        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    private func bindState() {
        keyboardBlocker.$isEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        let symbolName = keyboardBlocker.isEnabled ? "lock.fill" : "lock.open"
        let description = keyboardBlocker.isEnabled ? "Temizleme Modu Açık" : "Temizleme Modu Kapalı"

        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: description)
        button.contentTintColor = keyboardBlocker.isEnabled ? .systemRed : .labelColor
        button.toolTip = "sm-ART-lock - \(description)"
    }

    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else {
            return
        }

        permissionManager.refresh()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    private func closePopover() {
        popover.performClose(nil)
    }
}
