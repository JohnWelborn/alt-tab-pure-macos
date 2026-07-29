#!/bin/bash

# Stamps the build with the checked-out tag (e.g. "v11.4.3-pure" -> "11.4.3-pure"), so a plain
# `git clone` + build reports the right version instead of falling back to the pbxproj's default
# of "1" — which PreferencesMigrations.swift compares numerically against a stored version to
# decide whether to replay legacy migrations, so a permanently-"1" version replays all of them
# on every launch instead of once.
VERSION=$(git describe --tags --always | sed 's/^v//')

xcodebuild \
  -project alt-tab-macos.xcodeproj \
  -scheme Release \
  -configuration Release \
  -derivedDataPath DerivedData \
  CODE_SIGN_IDENTITY="Local Self-Signed" \
  CODE_SIGN_STYLE=Manual \
  OTHER_CODE_SIGN_FLAGS="--timestamp=none" \
  CURRENT_PROJECT_VERSION="$VERSION"
