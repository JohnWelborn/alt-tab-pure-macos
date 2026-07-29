import Cocoa

class Day15ProactiveWindow: ProPromptWindow {
    static var shared: Day15ProactiveWindow?

    static func show() {
        if shared == nil { shared = Day15ProactiveWindow() }
        shared!.fitContentHeight()
        App.showSecondaryWindow(shared!)
    }

    private static func supportingLine() -> String {
        NSLocalizedString("Some Pro features have reverted to free defaults.", comment: "")
    }

    convenience init() {
        self.init(size: NSSize(width: 380, height: 280))
        let supportingLine = NSTextField(wrappingLabelWithString: Self.supportingLine())
        supportingLine.font = .systemFont(ofSize: 13)
        supportingLine.textColor = .secondaryLabelColor
        supportingLine.alignment = .center
        let continueLink = NotAdvisedButton(NSLocalizedString("Maybe later", comment: ""))
        continueLink.onAction = { [weak self] _ in self?.close() }
        setHeroContentView(
            header: ProPromptHeader(title: NSLocalizedString("Your 14-day Pro trial just ended", comment: ""), size: .compact),
            hero: supportingLine,
            purchase: ProPromptButtons.makeGetPro(large: true) { ProTransitionManager.openCheckout() },
            dismiss: continueLink,
            sidePadding: 24, gap: 18, dismissGap: 10)
    }
}
