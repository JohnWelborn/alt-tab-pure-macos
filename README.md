## AltTabPure fork

AltTabPure is a personal fork of [AltTab](https://github.com/lwouis/alt-tab-macos) without its recently added Pro licensing system, which put existing AltTab features behind a license.

Changes from upstream include:

- Removed Pro licensing, trials, feature gates, cluttered promotional UI, popups, and account links.
- Removed automatic updates, Sparkle, crash reporting, and local usage statistics.
- Removed feedback and support links.
- Renamed the app to AltTabPure with its own bundle identifier, preserving existing AltTab preferences through migration.

## Build locally

Install:

- [Xcode for macOS](https://apps.apple.com/app/xcode/id497799835) — provides the macOS SDK, compiler, and `xcodebuild`.
- [Git for macOS](https://git-scm.com/download/mac) — clones the repository.

Build:

```sh
git clone git@github.com:JohnWelborn/alt-tab-pure-macos.git
cd alt-tab-pure-macos
scripts/codesign/setup_local.sh
bash ai/build_release.sh
ditto DerivedData/Build/Products/Release/AltTabPure.app /Applications/AltTabPure.app
```

Quit AltTab if it is running, then run AltTabPure:

```sh
open /Applications/AltTabPure.app
```

- `setup_local.sh` creates a local self-signed code-signing certificate.
  - This will ask for Keychain access; it adds the certificate to your login keychain and trusts it for code signing so macOS recognizes future local builds as the same app.
  - This creates temporary certificate files in the checkout. They are only for the local signing setup and must not be committed.
