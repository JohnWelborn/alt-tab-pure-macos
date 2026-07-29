import Foundation

/// Persisted state for Pro preference locking. Owns remembered indices and snapshot/restore logic.
///
/// Storage: `LicenseManager.defaultsSuiteName` suite, keys prefixed `proTransition.`.
class ProTransitionState {
    static let defaults = UserDefaults(suiteName: LicenseManager.defaultsSuiteName)!

    // MARK: - Remembered Pro indices (for ghost UI + restoration on unlock)

    var rememberedAppearanceStyle: Int? {
        get { Self.int(ProGatedPreferences.appearanceStyle.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.appearanceStyle.gate!.rememberedKey, newValue) }
    }
    var rememberedAppearanceSize: Int? {
        get { Self.int(ProGatedPreferences.appearanceSize.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.appearanceSize.gate!.rememberedKey, newValue) }
    }
    var rememberedShortcutStyle: Int? {
        get { Self.int(ProGatedPreferences.shortcutStyle.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.shortcutStyle.gate!.rememberedKey, newValue) }
    }

    // Per-shortcut override remembered indices. Shortcut 0 is the only index reachable while
    // locked, so it's the only one we snapshot. Indices >= 1 are hard-gated at trigger time.
    var rememberedAppearanceStyleOverride: Int? {
        get { Self.int(ProGatedPreferences.appearanceStyleOverride0.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.appearanceStyleOverride0.gate!.rememberedKey, newValue) }
    }
    var rememberedAppearanceSizeOverride: Int? {
        get { Self.int(ProGatedPreferences.appearanceSizeOverride0.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.appearanceSizeOverride0.gate!.rememberedKey, newValue) }
    }
    var rememberedShortcutStyleOverride: Int? {
        get { Self.int(ProGatedPreferences.shortcutStyleOverride0.gate!.rememberedKey) }
        set { Self.setInt(ProGatedPreferences.shortcutStyleOverride0.gate!.rememberedKey, newValue) }
    }

    // MARK: - Snapshot / restore Pro preferences

    /// Snapshot the user's Pro-selected preferences and switch them to Free equivalents so the
    /// switcher and Settings UI render the locked experience immediately. Snapshots the Pro index
    /// into `remembered*` so Settings can show the locked selection and activation can restore it.
    func onProLockEngaged() {
        for pref in ProGatedPreferences.all {
            if let storedIndex = pref.snapshotAndDowngrade() {
                Self.setInt(pref.rememberedKey, storedIndex)
            }
        }
    }

    /// Restore any remembered Pro values back to stored values. Called when the user upgrades to Pro.
    /// Restore writes with `notify: false` so `PreferencesEvents.preferenceChanged` doesn't fire while
    /// we're restoring — otherwise the `isProLocked && isStoredValuePro` check would yank the user to
    /// the Upgrade tab because the lock is still technically active during the restore pass.
    func onProUnlocked() {
        for pref in ProGatedPreferences.all {
            if let idx = Self.int(pref.rememberedKey) {
                pref.restoreFromIndex(idx)
                Self.setInt(pref.rememberedKey, nil)
            }
        }
    }

    static func removeLegacyPromptState() {
        ["hasSeenWelcome", "hasSeenDay4Tour", "hasSeenDay12", "freePassUsed", "hasSeenFullUpgrade",
         "hasSeenProactiveDay15", "hasSeenDay21", "hasSeenDay35", "userOptedOut",
         "hasTriggeredPostExpirationSwitcher", "isFreshInstall", "nextScheduledDate"].forEach {
            Self.defaults.removeObject(forKey: "proTransition.\($0)")
        }
    }

    // MARK: - QA / Debug

    #if DEBUG
    func resetAll() {
        let rememberedKeys = ProGatedPreferences.all.map { $0.rememberedKey }
        rememberedKeys.forEach { Self.defaults.removeObject(forKey: "proTransition.\($0)") }
    }
    #endif

    // MARK: - UserDefaults helpers

    static func int(_ key: String) -> Int? {
        defaults.object(forKey: "proTransition.\(key)") as? Int
    }

    static func setInt(_ key: String, _ value: Int?) {
        if let value {
            defaults.set(value, forKey: "proTransition.\(key)")
        } else {
            defaults.removeObject(forKey: "proTransition.\(key)")
        }
    }
}
