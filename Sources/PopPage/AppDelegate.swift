import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var managerWindow: NSWindow?
    private var languageObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        StatusBarManager.shared.start(with: PageStore.shared)
        StatusBarManager.shared.onOpenManager = { [weak self] in
            self?.openManagerWindow()
        }
        languageObserver = NotificationCenter.default.addObserver(
            forName: .appLanguageDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                NSApp.mainMenu = MainMenuBuilder.makeMainMenu()
            }
        }
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--screenshot-popover") {
            if let firstID = PageStore.shared.pages.first(where: \.isEnabled)?.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    StatusBarManager.shared.openPopover(for: firstID)
                }
            }
        } else {
            openManagerWindow(
                initialSelectedPageID: args.contains("--screenshot-page") ? PageStore.shared.pages.first?.id : nil,
                initialShowSettings: args.contains("--screenshot-settings")
            )
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openManagerWindow()
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func openManagerWindow(initialSelectedPageID: UUID? = nil, initialShowSettings: Bool = false) {
        if managerWindow == nil {
            let hostingController = NSHostingController(
                rootView: ManagerView(
                    initialSelectedPageID: initialSelectedPageID,
                    initialShowSettings: initialShowSettings
                )
            )
            let window = NSWindow(contentViewController: hostingController)
            window.title = "PopPage"
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.setContentSize(NSSize(width: 780, height: 560))
            window.minSize = NSSize(width: 680, height: 480)
            window.center()
            window.isReleasedWhenClosed = false
            managerWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        managerWindow?.makeKeyAndOrderFront(nil)
    }
}
