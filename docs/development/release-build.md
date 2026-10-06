# Production Release Build

Staging builds ship from CI when a `stg-<version>+<build>` tag is pushed
(`.github/workflows/deploy-stg.yml`). Production builds are made locally on a
maintainer's Mac and uploaded to the stores by hand. This page records that
local procedure.

## Prerequisites

- `.env.prod` at the repository root (decrypted secrets; see `tools/secrets.sh`).
- Production Firebase configuration, decrypted the same way:
  `packages/audiflow_app/android/app/src/prod/google-services.json` (the
  Android build fails without it) and
  `packages/audiflow_app/ios/config/prod/GoogleService-Info.plist` (the iOS
  build succeeds without it but ships without Firebase). Check both exist
  before building.
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

## 4. Upload debug symbols to Sentry

Without them, native crash frames in Sentry cannot be symbolicated. Upload
the files of the builds above, as the staging workflow does; files Sentry
already has are skipped.

```bash
# iOS: dSYMs from the archive the IPA was exported from
sentry-cli debug-files upload --org reedom --project audiflow --include-sources \
  build/ios/archive/Runner.xcarchive/dSYMs

# Android: unstripped native libraries (libapp.so, libflutter.so, ...)
sentry-cli debug-files upload --org reedom --project audiflow --include-sources \
  build/app/intermediates/merged_native_libs/prodRelease
```

`Flutter.framework.dSYM` carries the date of the Flutter SDK, not of the build;
that is expected. Release builds are not minified (no R8 mapping to upload)
and Dart code is not obfuscated; revisit this step if either changes.

## 5. Upload to the stores

- iOS: drag `build/ios/ipa/audiflow.ipa` into the Transporter app, or use
  `xcrun altool --upload-app` with an App Store Connect API key.
- Android: upload `app-prod-release.aab` in the Google Play Console.

Paste the release notes from `release-notes/<version>/` into each store.

## 6. Tag the release

Go back to the repository root on `main`: the remaining steps run tools
from the current tree (an older build commit may predate them) and find the
build through its tag.

```bash
cd "$(git rev-parse --show-toplevel)"
git checkout main
```

Tag the commit that was built and push the tag:

```bash
git tag "v$VERSION+$BUILD" "$COMMIT"
git push origin "v$VERSION+$BUILD"
```

## 7. Record the release in Sentry

The Sentry SDK names each release `<app id>@<version>+<build>`, one per
platform (`com.reedom.audiflow@...` for iOS, `com.reedom.audiflow_app@...` for
Android). `tools/sentry-release.sh` creates those releases with the commits
since the previous `v*` tag, so suspect commits and "resolved in release"
work for production issues.

This is automated by `.github/workflows/sentry-prod-release.yml`; nothing
needs to be run by hand:

- Pushing the tag in step 6 creates both releases
  (`tools/sentry-release.sh prod "$VERSION+$BUILD"`).
- Every 6 hours the workflow checks the build of the highest `v*` tag in each
  store with `tools/store_release_status.py`. Once a store serves it, the
  workflow records the production deploy for that platform
  (`tools/sentry-release.sh prod "$VERSION+$BUILD" --deploy --platform <ios|android>`).
  So deploys appear in Sentry within about 6 hours of the build going live.
  A build counts as live on the App Store when its version is released to
  customers (phased releases included), and on Google Play when a
  production release containing its version code is completed or in staged
  rollout. A platform whose store credentials are missing is skipped with a
  notice (see [Automation secrets](#automation-secrets)).

Manual fallback, for example to check an older build right away or when a
store secret is not set up:

```bash
gh workflow run sentry-prod-release.yml -f version="$VERSION+$BUILD"
```

or run the script directly from the repository root on `main` (step 6),
once the stores publish the build:

```bash
tools/sentry-release.sh prod "$VERSION+$BUILD"            # releases only
tools/sentry-release.sh prod "$VERSION+$BUILD" --deploy   # plus the deploy
```

Rerunning is safe: releases are updated in place, and `--deploy` leaves a
release that already has a `prod` deploy untouched. The staging workflow runs
the same script with `stg` on every `stg-*` tag. Debug symbols are matched by
file id, not by release, so step 4 does not depend on these names.

Google Play keeps only the current releases on the production track, so a
manual check of a build that has since been replaced there reports it as not
live; use the script directly for such a backfill.

## Automation secrets

`sentry-prod-release.yml` reads these repository secrets:

| Secret | Used for |
|--------|----------|
| `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` | creating releases and deploys (shared with the staging workflow) |
| `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY` | reading App Store versions (shared with the staging workflow; the private key is the `.p8` content) |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | reading the Google Play production track |

Setting up the Google Play service account:

1. In Google Cloud Console, pick or create a project and enable the
   **Google Play Android Developer API** for it.
2. Create a service account (IAM & Admin > Service accounts); it needs no
   Google Cloud roles. Under its Keys tab, add a JSON key and download it.
3. In Play Console, open **Users and permissions**, invite the service
   account's email address, and under **App permissions** add the audiflow app
   (`com.reedom.audiflow_app`) with **View app information (read-only)**.
   The workflow reads the production track inside a Play edit that it never
   commits and always deletes. Google does not document which Play Console
   permission each API method needs; if the check fails with HTTP 403 on
   creating the edit (`edits.insert`), additionally grant **Release to
   production, exclude devices, and use Play App Signing** for the app. That
   permission can publish releases, so try read-only first.
4. Store the key as the repository secret, then delete the local file:

   ```bash
   gh secret set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON < key.json
   rm key.json
   ```

Newly granted Play Console permissions can take a while (up to a day has
been reported) to apply to API calls. Verify with
`gh workflow run sentry-prod-release.yml` and check the run's log.

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
