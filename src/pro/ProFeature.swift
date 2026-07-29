import Foundation

/// Every Pro-gated capability, and the two questions the rest of the app asks about them: may this
/// action proceed right now (`attemptUse`), and does this preference key currently hold a Pro value
/// (`isStoredValuePro`). The gating data itself lives in `ProGatedPreferences`.
enum ProFeature: Equatable, Hashable {
    // Degradable preferences. Stored value is snapshotted into `remembered*` on lock and restored on unlock.
    case appIconsAndTitlesStyle
    case autoSize
    case searchOnReleaseShortcut
    // Hard-gated runtime actions. No stored preference; gated at use-time.
    case extraShortcut(index: Int)
    case searchInSwitcher

    /// The Pro-gated preference backing this feature, if any. Non-nil only for degradable features.
    /// Source of truth for key, remembered-key, read/downgrade/restore — see `ProGatedPreferences`.
    var gatedPreference: AnyProGatedPreference? {
        switch self {
        case .appIconsAndTitlesStyle: return ProGatedPreferences.appearanceStyle.erased
        case .autoSize: return ProGatedPreferences.appearanceSize.erased
        case .searchOnReleaseShortcut: return ProGatedPreferences.shortcutStyle.erased
        case .extraShortcut, .searchInSwitcher: return nil
        }
    }

    /// Features whose stored preference is snapshotted + downgraded when Pro locks.
    static let degradable: [ProFeature] = [.appIconsAndTitlesStyle, .autoSize, .searchOnReleaseShortcut]

    /// True when the user has Pro available (pro or trial). Centralised so future variants
    /// (grace periods, per-feature flags) have one place to change.
    var isAvailable: Bool { LicenseManager.shared.isProAvailable }
    /// True when Pro is locked (post-expiration).
    var isLocked: Bool { LicenseManager.shared.isProLocked }

    /// Attempt to use this feature at runtime. Degradable features are handled when their
    /// preference is read; hard-gated features are unavailable after the trial expires.
    func attemptUse() -> Bool {
        switch self {
        case .extraShortcut, .searchInSwitcher: return LicenseManager.shared.isProAvailable
        case .appIconsAndTitlesStyle, .autoSize, .searchOnReleaseShortcut:
            return true
        }
    }

    /// True when the user's stored preference currently holds the Pro value. Used by
    /// `PreferencesEvents.preferenceChanged` to decide whether a setter should bounce to Upgrade.
    static func isStoredValuePro(preferenceKey: String) -> Bool {
        ProGatedPreferences.forPreferenceKey(preferenceKey)?.isStoredValuePro() ?? false
    }
}
