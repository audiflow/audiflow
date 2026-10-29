---
refs:
  id: fr:19-car-playback
  kind: fr
  title: "In-car playback"
  related:
    - arch:playback-pipeline
    - fr:04-audio-playback
    - fr:05-download-and-queue
    - fr:13-library
    - fr:18-parental-control
  modules:
    - packages/audiflow_app/lib/features/car/
    - packages/audiflow_app/lib/features/carplay/
    - packages/audiflow_app/ios/Runner/CarPlaySceneDelegate.swift
    - packages/audiflow_app/ios/Runner/CarPlayTemplateController.swift
    - packages/audiflow_app/ios/Runner/CarPlayChannel.swift
    - packages/audiflow_app/ios/Runner/CarPlayArtworkLoader.swift
    - packages/audiflow_app/ios/Runner/PhoneSceneDelegate.swift
    - packages/audiflow_app/ios/Runner/AppDelegate.swift
    - packages/audiflow_app/android/app/src/main/kotlin/com/reedom/audiflow_app/CarArtworkProvider.kt
    - packages/audiflow_app/android/app/src/main/res/xml/automotive_app_desc.xml
---
# FR 19: In-car playback

> Shows Audiflow on the car's head unit through CarPlay (iOS) and Android Auto, so a driver can browse the queue, in-progress episodes, the library and downloads, start an episode, and control playback without touching the phone.

## Purpose

Podcasts are heavily listened to while commuting. A podcast player that does not appear on the car's screen forces the driver to pick an episode on the phone before setting off, or to reach for the phone while driving, so it is hard to adopt as the main player. In-car playback puts the listening the user has already set up (their queue, unfinished episodes, subscriptions and downloads) on the head unit, using the system's driver-safe list and Now Playing templates.

## User-visible Behavior

- Normal case: When the phone connects to CarPlay or Android Auto, Audiflow appears on the head unit with four tabs. **Up Next** lists the queue in play order, without the episode that is playing. **In Progress** lists the most recent partly played episodes (up to 20) with a progress bar. **Library** lists subscribed podcasts in the Library tab's sort order; selecting one opens its episodes, newest first, with duration and a progress bar on partly played ones. **Downloads** lists downloaded episodes, most recently downloaded first. Rows show artwork, and on CarPlay the playing episode is marked (Android Auto has no such marker for browse rows).
- Selecting an episode plays it from its saved position and opens Now Playing. Selecting an Up Next row jumps the queue to it, as tapping it in the phone's Queue tab does. Selecting an episode anywhere else plays it without changing the queue: the phone's "replace the queue?" question cannot be asked while driving, and silently replacing a queue the user built would lose it.
- Now Playing shows the same episode, position and state as the phone. Play/pause, skip forward/back (by the user's skip intervals) and the next/previous controls act on the same player, so either screen can be used and the other follows. The rate button steps through 1.0x, 1.2x, 1.5x, 1.8x and 2.0x and back to 1.0x; a speed set on the phone that falls between steps moves to the next step. The speed is saved to the podcast's own audio settings when it has them, otherwise to the global setting, as on the phone (FR 04). The Up Next button opens the queue.
- Android Auto: the same four tabs and podcast drill-down, shown as lists. Now Playing is Android Auto's own player screen, driven by the same media session as the phone's notification, so play/pause, skip and seek stay in step; the playback-rate button and the Up Next button on Now Playing are CarPlay only. Android Auto's "resume" suggestion offers the most recently played unfinished episode. Partly played rows show their progress on both.
- Lists follow changes made on the phone or by playback (an episode finishing, a download completing, a new subscription) without being reopened.
- Edge / failure case: The car can start Audiflow while the app is not running on the phone. On CarPlay the app then starts in the background and the head unit shows the app name until the lists are ready, then shows the tabs; on Android Auto the media service starts the app the same way. On Android Auto, a list opened for the first time may appear before all of its artwork has loaded (at most about two seconds' wait); the images fill in when the list reloads itself. A list that fails to load shows a "couldn't load" message instead of rows on CarPlay, and an empty list on Android Auto; artwork that fails to load leaves the row without an image.
- Recovery / fallback: Disconnecting from the car leaves playback running on the phone as with any audio route change (FR 04). Changing the app language updates the CarPlay labels.

## Capabilities

- Android Auto: declares the app as an Android Auto media app and answers the media browser that the background audio service already runs, from the same lists as CarPlay. Row artwork is downloaded and downscaled into the app cache and served to Android Auto by a read-only content provider (Android Auto cannot load remote images); the provider serves only those cached files and never fetches anything itself.
- Registers a CarPlay audio scene alongside the phone window; both are served by one Flutter engine owned by the app delegate and started by whichever connects first, so Dart runs even when the car launches the app.
- Builds the lists in Dart from the same repositories as the phone screens, and sends them to the CarPlay templates over the `audiflow/carplay` channel or to Android Auto through the media browser. Bursts of changes are coalesced into one refresh per list. CarPlay watches list data only while a head unit is connected; Android, which has no such signal, watches it from the first Android Auto browse request until the app process ends (Android's own media-resumption request, which every phone makes, does not count). Android Auto artwork is downloaded at most four at a time.
- Drives Now Playing through the system now-playing info and remote commands that the background audio service already publishes, so the car and phone controls cannot drift apart; only the rate and Up Next buttons are wired specifically for CarPlay.
- Decodes row artwork at the size a row shows, with an in-memory cache.
- Applies parental control: CarPlay offers no search, subscribe or link-following surface, so it only lists the subscribed set; a podcast's "hide explicit episodes" flag (FR 18) hides those episodes from its CarPlay episode list, and an unreadable flag hides them too (fail closed).
- Reports car-started playback to analytics with the `car` play source (the platform is recorded separately).

## Boundaries

- No Android Automotive OS (built-in car) build, and no Android Auto search or voice ("play X on Audiflow") support.
- Lists are capped at 100 rows (and at what the head unit allows), and there is no search, sort or filter on the head unit; the phone remains the place to manage subscriptions, the queue and downloads.
- No queue editing, downloading, marking played, sleep timer, chapters or transcripts on the head unit. Playback commands from the car (including the steering wheel) reach the same player as lock-screen controls (FR 04).
- The CarPlay audio entitlement must be granted by Apple and present in the provisioning profiles before CarPlay works on a device. Until then CarPlay exists only in simulator builds; see below.

## CarPlay entitlement

Status (2026-10-29): not granted. The request (category Audio, `com.apple.developer.carplay-audio`) is filed through https://developer.apple.com/contact/carplay/, which also asks the Account Holder to accept the CarPlay Entitlement Addendum to the Apple Developer Program License Agreement.

What the addendum (Rev. 06-08-2026) requires of this app:

- Do not access, or attempt to access, CarPlay APIs before Apple has provided the entitlement, and do not submit a CarPlay app to App Store Connect before Apple has approved it in writing (email counts). A development-only entitlement may come first and does not promise a distribution one.
- Minimize driver distraction and never require touching the phone while in CarPlay.
- Audio apps must be primarily for audio playback and must not offer gaming, commerce, social networking, texting, messaging or mapping on the car screen or through car audio; lyrics, web browsers and text-to-speech readers are named as forbidden. Keep transcripts, links and search off the head unit for this reason.
- Disclose the use of CarPlay APIs in writing when submitting to App Store Connect (App Review notes).
- Apple may change the terms or revoke the entitlement at any time; the app must be retested with each iOS release.

Until the entitlement is granted, device builds ship without CarPlay while the code stays in:

- `RunnerSimulator.entitlements` (simulator builds only, via `CODE_SIGN_ENTITLEMENTS[sdk=iphonesimulator*]`) carries the entitlement; `Runner.entitlements` does not.
- The Runner build phase "Strip CarPlay scene from device builds" deletes the `CPTemplateApplicationSceneSessionRoleApplication` scene from the built `Info.plist` for every non-simulator build, so iOS never offers the app to a head unit.
- Testing therefore needs the iOS Simulator's CarPlay window, which Xcode 27's Device Hub no longer offers; an Xcode 26.x install is the only local option. With the entitlement, a USB-connected iPhone works with Device Hub's CarPlay Simulator or an aftermarket head unit.

Once Apple grants it:

1. Enable the CarPlay capability on the App IDs `com.reedom.audiflow`, `com.reedom.audiflow.stg` and `com.reedom.audiflow.dev`, regenerate their provisioning profiles, and update the CI secrets holding the stg and prod profiles.
2. Move the entitlement key into `Runner.entitlements`, delete `RunnerSimulator.entitlements` and the `[sdk=iphonesimulator*]` settings, and delete the strip build phase.
3. Test on a device, then mention CarPlay in the App Review notes of the first production submission that includes it.

## Traceability

- **Source docs**: GitHub issues #717 (CarPlay), #720 (Android Auto)
- **Related FR**: `04-audio-playback.md` (player, speed scopes), `05-download-and-queue.md` (queue and downloads listed), `13-library.md` (library order, in-progress episodes), `18-parental-control.md` (hide-explicit flag)
