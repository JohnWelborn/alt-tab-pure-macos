import Cocoa

class AboutTab {
    static func initTab() -> NSView {
        makeContentView()
    }

    static func makeContentView(_ fitToContent: Bool = true, _ centerHero: Bool = false) -> NSView {
        let appIcon = LightImageView()
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        let appIconSize = NSSize(width: 128, height: 128)
        appIcon.updateContents(.cgImage(App.appIcon(for: appIconSize)), appIconSize)
        appIcon.fit(128, 128)
        let appText = StackView([
            BoldLabel(App.name),
            NSTextField(wrappingLabelWithString: NSLocalizedString("Version", comment: "") + " " + App.version),
            NSTextField(wrappingLabelWithString: App.licence),
            HyperlinkLabel(NSLocalizedString("Source code", comment: ""), "https://github.com/JohnWelborn/alt-tab-pure-macos"),
        ], .vertical)
        appText.spacing = GridView.interPadding / 2
        let rowToSeparate = 3
        appText.views[rowToSeparate].topAnchor.constraint(equalTo: appText.views[rowToSeparate - 1].bottomAnchor, constant: GridView.interPadding).isActive = true
        let appInfo = NSStackView(views: [appIcon, appText])
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        appInfo.spacing = GridView.interPadding
        appInfo.alignment = .centerY
        let grid = GridView([[appInfo]], 0)
        if centerHero {
            grid.cell(atColumnIndex: 0, rowIndex: 0).xPlacement = .center
        }
        if fitToContent {
            grid.fit()
        }
        return grid
    }

}

class AboutWindow: NSPanel {
    private static let contentPadding = CGFloat(24)
    static var shared: AboutWindow?

    override var canBecomeKey: Bool { SecondaryWindows.canBecomeKey }

    convenience init() {
        self.init(contentRect: NSRect(x: 0, y: 0, width: 380, height: 450), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        setupWindow()
        setupView()
        setFrameAutosaveNameSafely("AboutWindow2")
        Self.shared = self
    }

    private func setupWindow() {
        applySecondaryWindowChrome(String(format: NSLocalizedString("About %@", comment: ""), App.name))
    }

    private func setupView() {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.scrollerStyle = .overlay
        let documentView = FlippedView(frame: .zero)
        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        let aboutView = AboutTab.makeContentView(false, true)
        let columnWidth = frame.width - 2 * Self.contentPadding
        let acknowledgmentsView = AcknowledgmentsTab.makeContentView(columnWidth: columnWidth, shouldFit: false, verticallyStacked: true)
        acknowledgmentsView.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(aboutView)
        stack.addArrangedSubview(acknowledgmentsView)
        documentView.addSubview(stack)
        contentView = scrollView
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: documentView.topAnchor, constant: Self.contentPadding),
            stack.leadingAnchor.constraint(equalTo: documentView.leadingAnchor, constant: Self.contentPadding),
            stack.trailingAnchor.constraint(equalTo: documentView.trailingAnchor, constant: -Self.contentPadding),
            stack.bottomAnchor.constraint(equalTo: documentView.bottomAnchor, constant: -Self.contentPadding),
            documentView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
            aboutView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            aboutView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            acknowledgmentsView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            acknowledgmentsView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
        ])
    }

    override func close() {
        hideAppIfLastWindowIsClosed()
        super.close()
    }
}
