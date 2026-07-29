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

        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let header = ProPromptHeader(
            title: NSLocalizedString("Your 14-day Pro trial just ended", comment: ""),
            size: .compact)

        let supportingLine = NSTextField(wrappingLabelWithString: Self.supportingLine())
        supportingLine.font = .systemFont(ofSize: 13)
        supportingLine.textColor = .secondaryLabelColor
        supportingLine.alignment = .center

        let purchaseButton = NSButton(title: NSLocalizedString("Get Pro", comment: ""), target: nil, action: nil)
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.bezelStyle = .rounded
        if #available(macOS 11.0, *) { purchaseButton.controlSize = .large }
        // no .keyEquivalent: this prompt steals focus, so a stray Return must not trigger checkout (#5738)
        purchaseButton.onAction = { _ in ProTransitionManager.openCheckout() }

        let continueLink = NotAdvisedButton(NSLocalizedString("Maybe later", comment: ""))
        continueLink.onAction = { [weak self] _ in self?.close() }

        container.addSubview(header)
        container.addSubview(supportingLine)
        container.addSubview(purchaseButton)
        container.addSubview(continueLink)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            header.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            header.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),

            supportingLine.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 18),
            supportingLine.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            supportingLine.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),

            purchaseButton.topAnchor.constraint(equalTo: supportingLine.bottomAnchor, constant: 18),
            purchaseButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            continueLink.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 10),
            continueLink.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            continueLink.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])

        contentView = container

        fitContentHeight()
    }

    private func fitContentHeight() {
        guard let view = contentView else { return }
        view.layoutSubtreeIfNeeded()
        setContentSize(NSSize(width: view.frame.width, height: view.fittingSize.height))
    }
}
