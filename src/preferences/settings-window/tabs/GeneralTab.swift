import Cocoa

class GeneralTab {
    static var menubarIconDropdown: NSPopUpButton?
    static var menuIconShownToggle: Switch?

    static func initTab() -> NSView {
        let startAtLogin = TableGroupView.Row(leftTitle: NSLocalizedString("Start at login", comment: ""),
            rightViews: [LabelAndControl.makeSwitch("startAtLogin")])
        menubarIconDropdown = LabelAndControl.makeDropdown("menubarIcon", MenubarIconPreference.allCases)
        menuIconShownToggle = LabelAndControl.makeSwitch("menubarIconShown")
        let menubarIcon = TableGroupView.Row(leftTitle: NSLocalizedString("Menubar icon", comment: ""),
            rightViews: [
                menubarIconDropdown!,
                menuIconShownToggle!,
            ])
        let language = TableGroupView.Row(leftTitle: NSLocalizedString("Language", comment: ""),
            rightViews: [LabelAndControl.makeDropdown("language", LanguagePreference.allCases, extraAction: setLanguageCallback)])
        for i in 0..<MenubarIconPreference.allCases.count {
            let image = NSImage.initCopy("menubar-\(i)")
            image.isTemplate = i < 2
            image.size = NSSize(width: 22, height: 22)
            menubarIconDropdown!.item(at: i)!.image = image
        }
        let cell = menubarIconDropdown!.cell! as! NSPopUpButtonCell
        cell.bezelStyle = .regularSquare
        cell.arrowPosition = .arrowAtBottom
        cell.imagePosition = .imageOverlaps
        let captureWindowsInBackground = TableGroupView.Row(leftTitle: NSLocalizedString("Capture windows in the background", comment: ""),
            subTitle: NSLocalizedString("When disabled, avoids the macOS purple screen-recording indicator, and avoids flickers when playing DRM video. Thumbnails will be less up-to-date.", comment: ""),
            rightViews: [LabelAndControl.makeSwitch("captureWindowsInBackground")])
        let table = TableGroupView(width: SettingsWindow.contentWidth)
        table.addRow(startAtLogin)
        table.addRow(menubarIcon)
        table.addRow(captureWindowsInBackground)
        table.addNewTable()
        table.addRow(language)
        let exportButton = NSButton(title: NSLocalizedString("Export settings…", comment: ""), target: nil, action: nil)
        exportButton.onAction = { _ in exportSettings() }
        let importButton = NSButton(title: NSLocalizedString("Import settings…", comment: ""), target: nil, action: nil)
        importButton.onAction = { _ in importSettings() }
        let resetButton = NSButton(title: NSLocalizedString("Reset settings and restart…", comment: ""), target: nil, action: nil)
        resetButton.bezelStyle = .rounded
        if #available(macOS 11.0, *) { resetButton.hasDestructiveAction = true }
        resetButton.onAction = { _ in resetPreferences() }
        let tools = StackView([exportButton, importButton, resetButton], .horizontal)
        let view = TableGroupSetView(originalViews: [table, tools], padding: 0, bottomPadding: 0)
        return view
    }

    static func cleanup() {
        menubarIconDropdown = nil
        menuIconShownToggle = nil
    }

    static func refreshControlsFromPreferences() {
        menubarIconDropdown?.selectItem(at: CachedUserDefaults.intFromMacroPref("menubarIcon", MenubarIconPreference.allCases))
        menubarIconDropdown?.isEnabled = Preferences.menubarIconShown
    }

    @objc static func resetPreferences() {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = ""
        alert.informativeText = NSLocalizedString("You can’t undo this action.", comment: "")
        let cancelButton = alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        cancelButton.keyEquivalent = "\u{1b}" // Escape
        let resetButton = alert.addButton(withTitle: NSLocalizedString("Reset settings and restart", comment: ""))
        if #available(macOS 11.0, *) { resetButton.hasDestructiveAction = true }
        if alert.runModal() == .alertSecondButtonReturn {
            Preferences.resetAll()
            App.restart()
        }
    }

    private static func exportSettings() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(App.bundleIdentifier).plist"
        panel.allowedFileTypes = ["plist"]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        NSDictionary(dictionary: Preferences.all).write(to: url, atomically: true)
    }

    private static func importSettings() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["plist"]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = NSLocalizedString("Failed to import settings", comment: "")
            alert.runModal()
            return
        }
        let filtered = dict.filter { Preferences.ownedKeys.contains($0.key) }
        UserDefaults.standard.setPersistentDomain(filtered, forName: App.bundleIdentifier)
        CachedUserDefaults.cache.withLock { $0.removeAll() }
        Preferences.invalidateAllCache()
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Settings imported", comment: "")
        alert.informativeText = NSLocalizedString("The application needs to restart to apply the imported settings.", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Restart Now", comment: ""))
        let laterButton = alert.addButton(withTitle: NSLocalizedString("Later", comment: ""))
        laterButton.keyEquivalent = "\u{1b}" // Escape
        if alert.runModal() == .alertFirstButtonReturn {
            App.restart()
        }
    }

    static func setLanguageCallback(_ sender: NSControl) {
        if Preferences.language == .systemDefault {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([Preferences.language.appleLanguageCode!], forKey: "AppleLanguages")
        }
        // Inform the user that the app needs to restart to apply the language change
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = NSLocalizedString("Language Change", comment: "")
        alert.informativeText = NSLocalizedString("The application needs to restart to apply the language change.", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Restart Now", comment: ""))
        let laterButton = alert.addButton(withTitle: NSLocalizedString("Later", comment: ""))
        laterButton.keyEquivalent = "\u{1b}" // Escape
        if alert.runModal() == .alertFirstButtonReturn {
            App.restart()
        }
    }
}
