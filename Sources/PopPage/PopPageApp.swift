import AppKit

@main
enum PopPageMain {
    static func main() {
        MainActor.assumeIsolated {
            let app = NSApplication.shared
            let delegate = AppDelegate()
            app.delegate = delegate
            app.setActivationPolicy(.accessory)
            app.mainMenu = MainMenuBuilder.makeMainMenu()
            withExtendedLifetime(delegate) {
                app.run()
            }
        }
    }
}

@MainActor
enum MainMenuBuilder {
    static func makeMainMenu() -> NSMenu {
        let mainMenu = NSMenu()

        // Application menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: L10n.tr("menu.about", default: "About PopPage"), action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: L10n.tr("menu.hide", default: "Hide PopPage"), action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: L10n.tr("menu.quit", default: "Quit PopPage"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Edit menu (supports standard ⌘C/⌘V shortcuts in text fields and WKWebView)
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: L10n.tr("menu.edit", default: "Edit"))
        editMenu.addItem(withTitle: L10n.tr("menu.edit.undo", default: "Undo"), action: Selector(("undo:")), keyEquivalent: "z")
        let redoItem = NSMenuItem(title: L10n.tr("menu.edit.redo", default: "Redo"), action: Selector(("redo:")), keyEquivalent: "Z")
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(redoItem)
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: L10n.tr("menu.edit.cut", default: "Cut"), action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: L10n.tr("menu.edit.copy", default: "Copy"), action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: L10n.tr("menu.edit.paste", default: "Paste"), action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: L10n.tr("menu.edit.selectAll", default: "Select All"), action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        // Window menu
        let windowMenuItem = NSMenuItem()
        let windowMenu = NSMenu(title: L10n.tr("menu.window", default: "Window"))
        windowMenu.addItem(withTitle: L10n.tr("menu.window.close", default: "Close"), action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: L10n.tr("menu.window.minimize", default: "Minimize"), action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)

        return mainMenu
    }
}
