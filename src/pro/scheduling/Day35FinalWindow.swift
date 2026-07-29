import Cocoa

class Day35FinalWindow: ProPromptWindow {
    static var shared: Day35FinalWindow?

    static func show() {
        if shared == nil { shared = Day35FinalWindow() }
        shared!.fitContentHeight()
        App.showSecondaryWindow(shared!)
    }

    convenience init() {
        self.init(size: NSSize(width: 380, height: 280))
        let supportingLine = NSTextField(wrappingLabelWithString: NSLocalizedString("Pro is still available whenever you're ready.", comment: ""))
        supportingLine.font = .systemFont(ofSize: 13)
        supportingLine.textColor = .secondaryLabelColor
        supportingLine.alignment = .center
        let optOutLink = NotAdvisedButton(NSLocalizedString("No thanks — don't ask again", comment: ""))
        optOutLink.onAction = { [weak self] _ in
            ProTransitionManager.shared.userOptedOut = true
            self?.close()
        }
        setHeroContentView(
            header: ProPromptHeader(title: NSLocalizedString("Still interested in Pro?", comment: ""), size: .compact),
            hero: supportingLine,
            purchase: ProPromptButtons.makeGetPro(large: true) { ProTransitionManager.openCheckout() },
            dismiss: optOutLink,
            sidePadding: 20, gap: 18, dismissGap: 12)
    }
}
