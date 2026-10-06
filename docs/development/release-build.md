# Production Release Build

Staging builds ship from CI when a `stg-<version>+<build>` tag is pushed
(`.github/workflows/deploy-stg.yml`). Production builds are made locally on a
maintainer's Mac and uploaded to the stores by hand. This page records that
local procedure.

## Prerequisites

- `.env.prod` at the repository root (decrypted secrets; see `tools/secrets.sh`).
- Android signing: `packages/audiflow_app/android/key.properties` and the
  upload keystore it points to.
- Xcode signed in to the team account (team `R6HMM3C9D7`). The IPA export uses
  automatic signing with a cloud-managed distribution certificate, so no
  certificate lives in the local keychain.
- `sentry-cli` with an organization auth token in `~/.sentryclirc`
  (org `reedom`, project `audiflow`).
- Flutter from `.fvm/flutter_sdk/bin/flutter` (the SDK pinned for this repo).

## 1. Choose what to build

Build the commit that was verified on staging, with the same version and build
number as its `stg-` tag. For example, `stg-2.1.0+58` becomes version `2.1.0`,
build `58`. The production app has its own bundle id, so reusing the staging
build number does not collide.

Write and merge the store release notes first: see `release-notes/README.md`.

```bash
VERSION=2.1.0
BUILD=58
COMMIT=$(git rev-list -n 1 "stg-$VERSION+$BUILD")
git checkout "$COMMIT"   # or a branch whose code is identical to it
```

## 2. Build the iOS IPA

The export options are not committed; write them into the build directory:

```bash
cd packages/audiflow_app
mkdir -p build/ios
cat > build/ios/ExportOptions.prod.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>destination</key><string>export</string>
  <key>generateAppStoreInformation</key><false/>
  <key>manageAppVersionAndBuildNumber</key><true/>
  <key>method</key><string>app-store-connect</string>
  <key>signingStyle</key><string>automatic</string>
  <key>stripSwiftSymbols</key><true/>
  <key>teamID</key><string>R6HMM3C9D7</string>
  <key>testFlightInternalTestingOnly</key><false/>
  <key>uploadSymbols</key><true/>
</dict>
</plist>
PLIST

../../.fvm/flutter_sdk/bin/flutter build ipa --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=../../.env.prod \
  --build-name="$VERSION" --build-number="$BUILD" \
  --export-options-plist=build/ios/ExportOptions.prod.plist
```

Check the result before uploading:

```bash
unzip -q -o build/ios/ipa/audiflow.ipa 'Payload/*.app/Info.plist' -d /tmp/ipa-check
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" \
  -c "Print :CFBundleShortVersionString" -c "Print :CFBundleVersion" \
  /tmp/ipa-check/Payload/*.app/Info.plist
# expect: com.reedom.audiflow, $VERSION, $BUILD
```

## 3. Build the Android App Bundle

```bash
../../.fvm/flutter_sdk/bin/flutter build appbundle --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=../../.env.prod \
  --build-name="$VERSION" --build-number="$BUILD"
# output: build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

## 4. Upload iOS debug symbols to Sentry

Without the dSYMs, native iOS crash reports in Sentry cannot be symbolicated.
Upload the ones from the archive the IPA was exported from:

```bash
sentry-cli debug-files upload --org reedom --project audiflow --include-sources \
  build/ios/archive/Runner.xcarchive/dSYMs
```

`Flutter.framework.dSYM` carries the date of the Flutter SDK, not of the build;
that is expected. Files Sentry already has are skipped.

Android needs no symbol upload: release builds are not minified (no R8
mapping) and Dart code is not obfuscated or split with `--split-debug-info`.
Revisit this step if either changes.

## 5. Upload to the stores

- iOS: drag `build/ios/ipa/audiflow.ipa` into the Transporter app, or use
  `xcrun altool --upload-app` with an App Store Connect API key.
- Android: upload `app-prod-release.aab` in the Google Play Console.

Paste the release notes from `release-notes/<version>/` into each store.

## 6. Tag the release

Tag the commit that was built and push the tag:

```bash
git tag "v$VERSION+$BUILD" "$COMMIT"
git push origin "v$VERSION+$BUILD"
```

## Troubleshooting

- **IPA export fails with `No Accounts` or `No signing certificate "iOS
  Distribution"`** while Xcode's Organizer still works: the Xcode account
  credentials are no longer persisted. Check with
  `defaults read com.apple.dt.Xcode DVTDeveloperAccountManagerAppleIDLists`;
  an empty `IDE.Identifiers.Prod` list confirms it. Remove and re-add the Apple
  ID in Xcode Settings > Accounts, then rerun only the export step
  (`xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive
  -exportOptionsPlist build/ios/ExportOptions.prod.plist -exportPath
  build/ios/ipa`). Re-exporting keeps the archive, so the uploaded dSYMs still
  match.
- **`sentry-cli` returns 403 for `organizations list` or `projects list`**: the
  organization auth token only has the `org:ci` scope. Pass `--org reedom` and
  `--project audiflow` explicitly instead of listing them.
