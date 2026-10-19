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
    - packages/audiflow_app/lib/features/carplay/
    - packages/audiflow_app/ios/Runner/CarPlaySceneDelegate.swift
    - packages/audiflow_app/ios/Runner/CarPlayTemplateController.swift
    - packages/audiflow_app/ios/Runner/CarPlayChannel.swift
    - packages/audiflow_app/ios/Runner/CarPlayArtworkLoader.swift
    - packages/audiflow_app/ios/Runner/PhoneSceneDelegate.swift
    - packages/audiflow_app/ios/Runner/AppDelegate.swift
---
# FR 19: In-car playback

> Shows Audiflow on the car's head unit through CarPlay, so a driver can browse the queue, in-progress episodes, the library and downloads, start an episode, and control playback without touching the phone.

## Purpose

Podcasts are heavily listened to while commuting. A podcast player that does not appear on the car's screen forces the driver to pick an episode on the phone before setting off, or to reach for the phone while driving, so it is hard to adopt as the main player. In-car playback puts the listening the user has already set up (their queue, unfinished episodes, subscriptions and downloads) on the head unit, using the system's driver-safe list and Now Playing templates.

## User-visible Behavior

- Normal case: When the iPhone connects to CarPlay, Audiflow appears on the head unit with four tabs. **Up Next** lists the queue in play order, without the episode that is playing. **In Progress** lists the most recent partly played episodes (up to 20) with a progress bar. **Library** lists subscribed podcasts in the Library tab's sort order; selecting one opens its episodes, newest first, with duration and a progress bar on partly played ones. **Downloads** lists downloaded episodes, most recently downloaded first. Rows show artwork, and the playing episode is marked.
- Selecting an episode plays it from its saved position and opens Now Playing. Selecting an Up Next row jumps the queue to it, as tapping it in the phone's Queue tab does. Selecting an episode anywhere else plays it without changing the queue: the phone's "replace the queue?" question cannot be asked while driving, and silently replacing a queue the user built would lose it.
- Now Playing shows the same episode, position and state as the phone. Play/pause, skip forward/back (by the user's skip intervals) and the next/previous controls act on the same player, so either screen can be used and the other follows. The rate button steps through 1.0x, 1.2x, 1.5x, 1.8x and 2.0x and back to 1.0x; a speed set on the phone that falls between steps moves to the next step. The speed is saved to the podcast's own audio settings when it has them, otherwise to the global setting, as on the phone (FR 04). The Up Next button opens the queue.
- Lists follow changes made on the phone or by playback (an episode finishing, a download completing, a new subscription) without being reopened.
- Edge / failure case: The car can start Audiflow while the app is not running on the phone. The app then starts in the background and the head unit shows the app name until the lists are ready, then shows the tabs. A list that fails to load shows a "couldn't load" message instead of rows; artwork that fails to load leaves the row without an image.
- Recovery / fallback: Disconnecting from the car leaves playback running on the phone as with any audio route change (FR 04). Changing the app language updates the CarPlay labels.

## Capabilities

- Registers a CarPlay audio scene alongside the phone window; both are served by one Flutter engine owned by the app delegate and started by whichever connects first, so Dart runs even when the car launches the app.
- Builds the lists in Dart from the same repositories as the phone screens, and sends them to the native templates over the `audiflow/carplay` channel; list data is watched only while a head unit is connected, and bursts of changes are coalesced into one refresh per list.
- Drives Now Playing through the system now-playing info and remote commands that the background audio service already publishes, so the car and phone controls cannot drift apart; only the rate and Up Next buttons are wired specifically for CarPlay.
- Decodes row artwork at the size a row shows, with an in-memory cache.
- Applies parental control: CarPlay offers no search, subscribe or link-following surface, so it only lists the subscribed set; a podcast's "hide explicit episodes" flag (FR 18) hides those episodes from its CarPlay episode list, and an unreadable flag hides them too (fail closed).
- Reports CarPlay-started playback to analytics with the `carplay` play source.

## Boundaries

- iOS CarPlay only for now. Android Auto is tracked separately (#720).
- Lists are capped at 100 rows (and at what the head unit allows), and there is no search, sort or filter on the head unit; the phone remains the place to manage subscriptions, the queue and downloads.
- No queue editing, downloading, marking played, sleep timer, chapters or transcripts on the head unit. Playback commands from the car (including the steering wheel) reach the same player as lock-screen controls (FR 04).
- The CarPlay audio entitlement must be granted by Apple and present in the provisioning profiles before CarPlay works on a device. Until then only simulator builds carry it (`RunnerSimulator.entitlements`).

## Traceability

- **Source docs**: GitHub issue #717
- **Related FR**: `04-audio-playback.md` (player, speed scopes), `05-download-and-queue.md` (queue and downloads listed), `13-library.md` (library order, in-progress episodes), `18-parental-control.md` (hide-explicit flag)
