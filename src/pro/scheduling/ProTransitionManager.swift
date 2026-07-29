import Foundation
import Cocoa

/// Coordinates preference locking and restoration as the license state changes.
class ProTransitionManager {
    static let shared = ProTransitionManager()

    /// Posted after `onProLockEngaged()` or `onProUnlocked()` changes the remembered/stored Pro
    /// selections. Observers (e.g. AppearanceTab, ControlsTab) use this to refresh any UI that
    /// depends on `LicenseManager.isProLocked` while the Settings window is already visible.
    static let proLockStateDidChangeNotification = Notification.Name("ProLockStateDidChange")

    let state = ProTransitionState()

    func onLicenseStateChanged() {
        if LicenseManager.shared.isProLocked {
            onProLockEngaged()
        }
    }

    func onProLockEngaged() {
        state.onProLockEngaged()
        NotificationCenter.default.post(name: Self.proLockStateDidChangeNotification, object: nil)
    }

    func onProUnlocked() {
        state.onProUnlocked()
        NotificationCenter.default.post(name: Self.proLockStateDidChangeNotification, object: nil)
    }

    // MARK: - Checkout helper

    static func openCheckout() {
        NSWorkspace.shared.open(URL(string: Endpoints.checkoutUrl)!)
    }

    // MARK: - QA / Debug

    #if DEBUG
    func resetAllState() {
        onProUnlocked()
        state.resetAll()
        NotificationCenter.default.post(name: Self.proLockStateDidChangeNotification, object: nil)
    }
    #endif
}
