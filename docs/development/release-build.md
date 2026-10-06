# Production Release Build

Staging builds ship from CI when a `stg-<version>+<build>` tag is pushed
(`.github/workflows/deploy-stg.yml`). Production builds ship from CI the same
way: pushing a `v<version>+<build>` tag runs
`.github/workflows/deploy-prod.yml`, which builds the prod flavor from the
tagged commit and uploads it to App Store Connect and to a draft release on
the Google Play production track. A maintainer then submits the build for
review in App Store Connect and publishes the Play draft.

The [local build](#local-build-fallback) on a maintainer's Mac remains as a
fallback for when CI cannot be used.

## 1. Choose what to build

Build the commit that was verified on staging, with the same version and build
number as its `stg-` tag. For example, `stg-2.1.0+58` becomes version `2.1.0`,
build `58`. The production app has its own bundle id, so reusing the staging
build number does not collide.

Write and merge the store release notes first: see `release-notes/README.md`.
CI reads them from `main`, not from the tagged commit, so notes merged after
the staging build still ship.

```bash
VERSION=2.1.0
BUILD=58
COMMIT=$(git rev-list -n 1 "stg-$VERSION+$BUILD")
```

## 2. Push the tag

From the repository root on `main`, tag the commit and push the tag:

```bash
git tag "v$VERSION+$BUILD" "$COMMIT"
git push origin "v$VERSION+$BUILD"
```

The push starts two workflows:

- **Deploy Production** (`deploy-prod.yml`) builds and uploads; see below.
- **Sentry Production Release** (`sentry-prod-release.yml`) creates the
  Sentry releases; see [step 4](#4-sentry-releases-and-deploys).

A tag push runs the workflow file as it is at the tagged commit. If that
commit predates `deploy-prod.yml`, nothing starts; run it by hand instead
(this uses the workflow from `main`):

```bash
gh workflow run deploy-prod.yml -f tag="v$VERSION+$BUILD"
```

Such an older commit also predates `sentry-prod-release.yml`, and that
workflow creates Sentry releases only on a tag push, so create them yourself,
from the repository root on `main`:

```bash
tools/sentry-release.sh prod "$VERSION+$BUILD"
```

The scheduled run of `sentry-prod-release.yml` then records the production
deploys once the stores serve the build ([step 4](#4-sentry-releases-and-deploys)).

What Deploy Production does, per platform (the jobs run in parallel):

- **iOS** (`macos-26`, Xcode 26.4.1): installs the Apple Distribution
  certificate and the prod App Store provisioning profile (checked to be for
  `com.reedom.audiflow`), decrypts `.env.prod` and the prod
  `GoogleService-Info.plist` from audiflow-secrets, sets the version to the
  tag's, builds the IPA with manual signing, checks its bundle id, version and
  build number, uploads the dSYMs to Sentry, and uploads the IPA to App Store
  Connect with `xcrun altool`. It does not submit for review.
- **Android**: decrypts `.env.prod`, the prod `google-services.json` and the
  upload keystore with its `key.properties`, sets the version, builds the App
  Bundle, uploads the native debug symbols to Sentry, and runs
  `tools/play_upload.py`. That creates a Play edit, uploads the bundle, puts a
  `draft` release with its version code on the production track (other
  releases on the track are kept; an older draft is replaced), attaches the
  release notes from `release-notes/<version>/android/{en-US,ja-JP}.txt`, and
  commits the edit. Missing notes are a warning, not a failure; a note over
  Google Play's 500 characters fails the upload.

Debug symbols are uploaded before the store upload, so a Sentry failure can be
retried without re-uploading a build the store already has. Release builds are
not minified (no R8 mapping to upload) and Dart code is not obfuscated;
revisit the symbol steps if either changes.

A missing repository secret fails the job in its first step, naming the
secret; see [CI secrets](#ci-secrets).

### Retrying

Both stores reject a second upload of the same build number, so retry only
the platform that failed:

```bash
gh workflow run deploy-prod.yml -f tag="v$VERSION+$BUILD" -f platform=android   # or ios
```

If a store upload itself succeeded and only a later step failed, do not rerun
that platform; finish by hand instead.

When the Android upload step fails with exit code 4 ("Play upload outcome
unknown"), the request committing the Play edit got no response (a timeout or
dropped connection), so the draft release may already exist; the edit is kept
rather than deleted. Check the production track in Play Console first: if the
draft `$VERSION ($BUILD)` is there, the upload is done and must not be rerun.
Rerun the `android` platform only if it is not. Any other failure deletes the
Play edit, so the platform can be rerun as is.

## 3. Submit in the stores

- **App Store Connect**: once the build finishes processing, add it to the
  `$VERSION` App Store version (create the version if needed), paste the
  "What's New" text from `release-notes/$VERSION/ios/`, and submit for review.
- **Google Play Console**: open the production track, review the draft
  release `$VERSION ($BUILD)` and its release notes, then send it for review
  and roll it out.

## 4. Sentry releases and deploys

The Sentry SDK names each release `<app id>@<version>+<build>`, one per
platform (`com.reedom.audiflow@...` for iOS, `com.reedom.audiflow_app@...` for
Android). `tools/sentry-release.sh` creates those releases with the commits
since the previous `v*` tag, so suspect commits and "resolved in release"
work for production issues.

This is automated by `.github/workflows/sentry-prod-release.yml`; nothing
needs to be run by hand:

- Pushing the tag in step 2 creates both releases
  (`tools/sentry-release.sh prod "$VERSION+$BUILD"`).
- Every 6 hours the workflow looks at the builds of the 3 highest `v*` tags,
  so an older build that goes live after a newer tag was pushed still gets
  its deploy. For each build and platform without a `prod` deploy in Sentry
  yet, it checks the store with `tools/store_release_status.py`; once the
  store serves the build, it records the production deploy for that platform
  (`tools/sentry-release.sh prod "$VERSION+$BUILD" --deploy --platform <ios|android>`).
  So deploys appear in Sentry within about 6 hours of the build going live.
  Builds older than the 3 highest tags are not checked.
  A build counts as live on the App Store when its version is released to
  customers (phased releases included), and on Google Play when the
  production release containing its version code is published
  (`releaseLifecycleState` `PUBLISHED` from `tracks.releases.list`, full or
  staged rollout). A release still in review, or the draft Deploy Production
  creates, does not count: the older edits API reports a release in review as
  `completed`. A platform whose store credentials are missing is skipped with
  a notice (see [CI secrets](#ci-secrets)).

To check one build right away, or one outside the 3-tag window, run the
workflow for it. This only helps for platforms whose store credentials are
configured:

```bash
gh workflow run sentry-prod-release.yml -f version="$VERSION+$BUILD"
```

For a platform whose store secret is not set up, the workflow skips the
check, so record the deploy with the script directly, from the repository
root on `main`, once that store publishes the build:

```bash
tools/sentry-release.sh prod "$VERSION+$BUILD" --deploy --platform ios       # or android
tools/sentry-release.sh prod "$VERSION+$BUILD"                               # releases only, both platforms
```

Rerunning is safe. Without `--deploy`, releases are updated in place. With
`--deploy`, a missing release is created first; an existing one only gets the
missing `prod` deploy (it is not finalized again, which would move its
release date), and one that already has a `prod` deploy is left untouched. The staging workflow runs
the same script with `stg` on every `stg-*` tag. Debug symbols are matched by
file id, not by release, so the symbol uploads do not depend on these names.

Google Play keeps only the current releases on the production track, so a
manual check of a build that has since been replaced there reports it as not
live; use the script directly for such a backfill.

## CI secrets

Repository secrets read by `deploy-prod.yml` and `sentry-prod-release.yml`:

| Secret | Used by | Used for |
|--------|---------|----------|
| `SECRETS_REPO_DEPLOY_KEY`, `SOPS_AGE_KEY` | deploy-prod | checking out and decrypting audiflow-secrets (shared with staging) |
| `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD` | deploy-prod | Apple Distribution certificate (`.p12`) for signing (shared with staging) |
| `IOS_PROD_PROVISIONING_PROFILE_BASE64` | deploy-prod | **new**: App Store provisioning profile for `com.reedom.audiflow` |
| `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY` | both | uploading the IPA; reading App Store versions (shared with staging; the private key is the `.p8` content) |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | both | uploading the draft release; reading the production track |
| `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` | both | debug symbol uploads; releases and deploys (shared with staging) |

### iOS provisioning profile

In the Apple Developer portal (Certificates, Identifiers & Profiles), create an
**App Store Connect** distribution profile for the App ID
`com.reedom.audiflow`, selecting the same Apple Distribution certificate that
`APPLE_CERTIFICATE_BASE64` holds. Download it and store it base64-encoded:

```bash
base64 -i audiflow_prod.mobileprovision | gh secret set IOS_PROD_PROVISIONING_PROFILE_BASE64
```

The workflow signs with the profile's name, so a renewed profile only needs
the secret updated. Profiles expire after a year, and a profile stops working
when its certificate is revoked or renewed.

### Google Play service account

1. In Google Cloud Console, pick or create a project and enable the
   **Google Play Android Developer API** for it.
2. Create a service account (IAM & Admin > Service accounts); it needs no
   Google Cloud roles. Under its Keys tab, add a JSON key and download it.
3. In Play Console, open **Users and permissions**, invite the service
   account's email address, and under **App permissions** add the audiflow app
   (`com.reedom.audiflow_app`) with:
   - **View app information (read-only)**, for the status checks in
     `sentry-prod-release.yml` (`tracks.releases.list`, which changes
     nothing), and
   - **Release to production, exclude devices, and use Play App Signing**,
     for the draft uploads in `deploy-prod.yml`. This is much broader than
     the read-only access: the key can then change the production track
     (the workflow itself only creates drafts). Keep the key in the
     repository secret only.
4. Store the key as the repository secret, then delete the local file:

   ```bash
   gh secret set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON < key.json
   rm key.json
   ```

Newly granted Play Console permissions can take a while (up to a day has
been reported) to apply to API calls. Verify the read access with
`gh workflow run sentry-prod-release.yml` and check the run's log; the upload
permission is first exercised by the next Deploy Production run.

## Local build (fallback)

Use this when CI cannot build or upload a release. Pushing the tag (step 2)
still starts Deploy Production; when the stores already have the locally
uploaded build, cancel that run (`gh run list --workflow deploy-prod.yml`,
then `gh run cancel <run id>`), or its store uploads fail on the duplicate
build number. The Sentry workflow is separate and should still run.

The build runs from the staging commit in a separate worktree, while the
release tools and release notes come from your usual checkout on an
up-to-date `main`: the build commit can predate `tools/play_upload.py`, and
notes are often merged after it. Two directories are used below:

- `$MAIN`: your usual checkout, on `main` (`git checkout main && git pull`).
- `$BUILD_DIR`: a worktree of the build commit, next to it.

Each command block says where it runs. From `$MAIN`, with `VERSION`, `BUILD`
and `COMMIT` set as in [step 1](#1-choose-what-to-build):

```bash
# in $MAIN
MAIN=$(git rev-parse --show-toplevel)
BUILD_DIR="$MAIN/../audiflow-build"
git worktree add --detach "$BUILD_DIR" "$COMMIT"
FLUTTER="$MAIN/.fvm/flutter_sdk/bin/flutter"
cat "$BUILD_DIR/.fvmrc"   # must name the same Flutter version as "$MAIN/.fvmrc"
```

### Prerequisites

The files below belong in `$BUILD_DIR`, the tree that is built. Decrypting
there with `(cd "$BUILD_DIR" && mise run secrets:decrypt)` creates them all
(see `tools/secrets.sh`; it finds audiflow-secrets next to the primary
checkout).

- `.env.prod` at the root of `$BUILD_DIR`.
- Production Firebase configuration:
  `packages/audiflow_app/android/app/src/prod/google-services.json` (the
  Android build fails without it) and
  `packages/audiflow_app/ios/config/prod/GoogleService-Info.plist` (the iOS
  build succeeds without it but ships without Firebase). Check both exist
  before building.
- Android signing: `packages/audiflow_app/android/key.properties` and the
  upload keystore it points to.

And on the machine:

- Xcode signed in to the team account (team `R6HMM3C9D7`). The IPA export uses
  automatic signing with a cloud-managed distribution certificate, so no
  certificate lives in the local keychain.
- `sentry-cli` with an organization auth token in `~/.sentryclirc`
  (org `reedom`, project `audiflow`).
- Flutter from `$MAIN/.fvm/flutter_sdk/bin/flutter` (`$FLUTTER` above; the
  worktree has no `.fvm` of its own).

### Build the iOS IPA

The export options are not committed; write them into the build directory:

```bash
# in $BUILD_DIR/packages/audiflow_app
cd "$BUILD_DIR/packages/audiflow_app"
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

"$FLUTTER" build ipa --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=../../.env.prod \
  --build-name="$VERSION" --build-number="$BUILD" \
  --export-options-plist=build/ios/ExportOptions.prod.plist
```

Check the result before uploading:

```bash
# in $BUILD_DIR/packages/audiflow_app
unzip -q -o build/ios/ipa/audiflow.ipa 'Payload/*.app/Info.plist' -d /tmp/ipa-check
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" \
  -c "Print :CFBundleShortVersionString" -c "Print :CFBundleVersion" \
  /tmp/ipa-check/Payload/*.app/Info.plist
# expect: com.reedom.audiflow, $VERSION, $BUILD
```

### Build the Android App Bundle

```bash
# in $BUILD_DIR/packages/audiflow_app
"$FLUTTER" build appbundle --flavor prod -t lib/main_prod.dart \
  --dart-define-from-file=../../.env.prod \
  --build-name="$VERSION" --build-number="$BUILD"
# output: $BUILD_DIR/packages/audiflow_app/build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### Upload debug symbols to Sentry

Without them, native crash frames in Sentry cannot be symbolicated. Upload
the files of the builds above, as CI does; files Sentry already has are
skipped.

```bash
# in $BUILD_DIR/packages/audiflow_app
# iOS: dSYMs from the archive the IPA was exported from
sentry-cli debug-files upload --org reedom --project audiflow --include-sources \
  build/ios/archive/Runner.xcarchive/dSYMs

# Android: unstripped native libraries (libapp.so, libflutter.so, ...)
sentry-cli debug-files upload --org reedom --project audiflow --include-sources \
  build/app/intermediates/merged_native_libs/prodRelease
```

`Flutter.framework.dSYM` carries the date of the Flutter SDK, not of the build;
that is expected.

### Upload to the stores

- iOS: drag `$BUILD_DIR/packages/audiflow_app/build/ios/ipa/audiflow.ipa` into
  the Transporter app, or use `xcrun altool --upload-app` with an App Store
  Connect API key. Paste the "What's New" text from
  `$MAIN/release-notes/$VERSION/ios/` into App Store Connect.
- Android: run the upload tool from `$MAIN`, so the tool exists and the
  merged notes are used, with `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` set to a key
  that has the upload permission:

  ```bash
  # in $MAIN
  cd "$MAIN"
  uv run tools/play_upload.py \
    "$BUILD_DIR/packages/audiflow_app/build/app/outputs/bundle/prodRelease/app-prod-release.aab" \
    "$VERSION+$BUILD" \
    --release-notes-dir "release-notes/$VERSION/android"
  ```

  It creates the same draft release as CI (exit code 4 means the outcome is
  unknown; see [Retrying](#retrying)). The alternative is to upload
  `app-prod-release.aab` by hand in Google Play Console and paste the notes
  from `$MAIN/release-notes/$VERSION/android/`.

Then remove the build worktree (`--force` because the decrypted secrets in it
are untracked; this deletes them too) and continue with
[step 2](#2-push-the-tag) from `$MAIN`:

```bash
# in $MAIN
git worktree remove --force "$BUILD_DIR"
```

## Troubleshooting

- **Pushing the tag did not start Deploy Production**: the tagged commit
  predates `deploy-prod.yml`. Run it by hand and create the Sentry releases
  with `tools/sentry-release.sh`, both as shown in step 2.
- **The Play upload step exits with code 4**: committing the edit got no
  response, so the draft may already exist. Check the production track in
  Play Console before any retry; see [Retrying](#retrying).
- **The Play upload fails with 403**: the service account lacks the
  production release permission, or it was granted recently and has not
  applied yet; see [Google Play service account](#google-play-service-account).
  A failed run deletes its Play edit, so nothing is left half-made.
- **The Play upload fails because the version code was already used**: the
  bundle is already on Google Play (an earlier run or a manual upload). Do not
  retry; check the production track in Play Console.
- **IPA export fails with `No Accounts` or `No signing certificate "iOS
  Distribution"`** while Xcode's Organizer still works (local build): the
  Xcode account credentials are no longer persisted. Check with
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
