import Cocoa

class Day15FullUpgradeWindow: ProPromptWindow {
    static var shared: Day15FullUpgradeWindow?

    private var header: ProPromptHeader!
    private var supportingLine: NSTextField!

    static func show(for reason: HardGateReason? = nil) {
        if shared == nil { shared = Day15FullUpgradeWindow() }
        shared!.header.title = (reason?.resolved ?? .nonEngaged).unlockHeader
        shared!.supportingLine.stringValue = supportingLine(for: reason)
        shared!.fitContentHeight()
        App.showSecondaryWindow(shared!)
    }

    private static func supportingLine(for reason: HardGateReason?) -> String {
        let resolved = reason?.resolved ?? .nonEngaged
        if resolved == .nonEngaged {
            return NSLocalizedString(
                "AltTab Pro adds 4 features beyond the free switcher.",
                comment: "")
        }
        let revertSentence = NSLocalizedString(
            "Some Pro features have reverted to free defaults.", comment: "")
        switch resolved {
        case .extraShortcut:
            return revertSentence + "\n" + NSLocalizedString(
                "Extra shortcuts are a Pro feature.", comment: "")
        case .search:
            return revertSentence + "\n" + NSLocalizedString(
                "Search is a Pro feature.", comment: "")
        case .appIconsStyle:
            return revertSentence + "\n" + NSLocalizedString(
                "The App Icons style is a Pro feature.", comment: "")
        case .titlesStyle:
            return revertSentence + "\n" + NSLocalizedString(
                "The Titles style is a Pro feature.", comment: "")
        case .nonEngaged:
            return ""
        }
    }

    convenience init() {
        self.init(size: NSSize(width: 440, height: 340))
        let header = ProPromptHeader(title: ResolvedReason.nonEngaged.unlockHeader, size: .large)
        self.header = header
        let supportingLine = Self.makeSupportingLine(Self.supportingLine(for: nil))
        self.supportingLine = supportingLine
        let continueLink = NotAdvisedButton(NSLocalizedString("Continue with Free", comment: ""))
        continueLink.onAction = { [weak self] _ in self?.close() }
        setHeroContentView(
            header: header,
            hero: supportingLine,
            purchase: ProPromptButtons.makeGetPro(large: true) { ProTransitionManager.openCheckout() },
            dismiss: continueLink,
            sidePadding: 30, gap: 24, dismissGap: 12)
    }

    private static func makeSupportingLine(_ text: String) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabelColor
        label.alignment = .center
        return label
    }
}
