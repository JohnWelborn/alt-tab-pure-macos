# Building this fork (`free` branch)

This branch is a minimal-diff, license-unlocked build of AltTab: every Pro feature is
unlocked and the nag/upsell flow is disabled via a `FREE_BUILD` compilation flag (see
`config/debug.xcconfig`/`config/release.xcconfig`), rather than by deleting any Pro-only
code. `FREE_BUILD` is always on for both configs on this branch.

## Local Debug build

1. Install full Xcode. Command Line Tools alone are insufficient — the project builds
   with `xcodebuild` and needs the macOS SDK.
2. Create and trust the project's local self-signed code-signing certificate:

   ```
   scripts/codesign/setup_local.sh
   ```

3. Build:

   ```
   bash ai/build.sh
   ```

The local Debug build does not need an Apple Developer account or notarization. It is
produced at:

```
DerivedData/Build/Products/Debug/AltTab.app
```

macOS may require approval in Privacy & Security and permissions for Accessibility and
Screen Recording. A local build is a separate app from any official AltTab install, so
it needs its own permission grants.

## Public release requirements

To distribute a signed/notarized release from this branch, use your own Apple Developer
account, Developer ID certificate, and notarization credentials — the upstream
release-signing identity (`config/release.xcconfig`'s `CODE_SIGN_IDENTITY`) cannot be
used, and must be overridden per-developer via the gitignored `config/local.xcconfig`.
This branch keeps upstream's bundle identifier and product name (`AltTab` /
`com.lwouis.alt-tab-macos`) rather than rebranding, and does not wire up an auto-update
feed, so a distributed build will not self-update.
