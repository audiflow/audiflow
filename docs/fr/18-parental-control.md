---
refs:
  id: fr:18-parental-control
  kind: fr
  title: "Parental control"
  related:
    - fr:02-podcast-discovery
    - fr:03-subscription-feeds
    - fr:14-settings
    - fr:15-links-and-sharing
    - fr:17-podcast-detail
---

# FR 18: Parental control

> A PIN-gated Restricted Mode that hides discovery and locks subscription so the device owner curates what plays, and a child or shared user consumes only the curated set.

## Purpose

Audiflow is often used on a shared device, including by children. Podcast discovery is open by design — search reaches the entire podcast index, universal links can deep-link any feed, and any episode of any subscribed show can play. A parent who hands the device to a child cannot trust that the next tap will stay inside a curated set.

Parental control exists to give the device owner one switch that closes the discovery surfaces and locks subscription changes, so the resulting listening environment is exactly the set of shows the owner picked, and nothing else. The design deliberately gates only the content-entry boundary — Subscribe, Import, deep-link follow — rather than every downstream surface. Once a podcast is on the subscription list, the parent has vouched for it, and playback / queue / download / sleep timer all stay open over that curated set.

It also acknowledges the limits of an in-app gate: the PIN is local-only and survives only as long as the install does. Users who need device-level enforcement against a determined child are pointed at iOS Screen Time and Android Family Link as the real lockdown layer; Audiflow's job is to keep the normal surfaces curated, not to be a tamper-proof kiosk.

## User-visible Behavior

- Normal case: The user opens Settings → Parental Control, sets a 4-to-8 digit PIN (entered twice), and toggles Restricted Mode on. The gate locks immediately on enable, so any subsequent restricted action requires re-entering the PIN even within the same session. From that moment the Search tab is hidden, the Developer section of settings is hidden, the Subscribe action on podcast detail is disabled, the Unsubscribe action on subscribed podcasts is disabled, OPML import is disabled, and tapping a universal link that resolves to a non-subscribed podcast or episode shows a "Restricted Mode is on" notice instead of opening the target.
- Library, podcast detail of subscribed shows, episode detail, playback, queue, downloads, sleep timer, and transcript / chapters all behave normally over the already-subscribed set.
- Turning Restricted Mode off, changing the PIN, subscribing, unsubscribing, importing OPML, following a deep link into non-subscribed content, or opening the Developer section all require entering the current PIN. A successful PIN entry grants an in-memory unlock that lasts until the configured timeout (default: until the app is backgrounded, or 5 minutes idle, whichever comes first), then re-locks automatically.
- Optional biometric unlock: once a PIN is set the user can flip an "Allow biometric unlock" toggle in Parental Control settings (shown only when the device reports an enrolled biometric). When on, the PIN entry sheet adds a "Use biometric" button that completes the unlock via Face ID / Touch ID / Android biometric. Biometric failure or cancellation does NOT count toward PIN lockout — only guessed-PIN abuse triggers the backoff window.
- Optional per-podcast "Hide explicit episodes" toggle: on a subscribed podcast's detail screen, an unlocked user can flip a per-podcast switch that hides episodes whose feed item carries `<itunes:explicit>` true. Off by default. There is no global explicit filter — `<itunes:explicit>` is publisher-set and inconsistent, and the parent has already vetted the show by subscribing.
- Edge / failure case: A forgotten PIN cannot be recovered in-app — the user is told that resetting the PIN requires "Reset all data" from Storage & Data, which clears subscriptions, downloads, and history along with the PIN. PIN entry rate-limits after 5 consecutive failures with exponential backoff up to 5 minutes. A universal link that resolves to a podcast or episode the user is already subscribed to opens normally, even while Restricted Mode is on. Background feed refresh continues to run for the subscribed set without prompting for a PIN.
- Recovery / fallback: If the parental-control store cannot be read (disk error), Restricted Mode fails closed — the app behaves as if restricted, but every PIN entry is refused with a "settings unavailable" message rather than silently disabling the gate. Defaults: Restricted Mode off, no per-podcast explicit-hide flags, unlock timeout 5 minutes idle.

## Capabilities

- Persists a hashed PIN, a Restricted-Mode toggle, per-podcast `hideExplicitEpisodes` flags, and the unlock-timeout policy through a single `ParentalControlRepository`.
- Exposes a domain-layer gate consulted by the small set of content-entry surfaces — Subscribe, Unsubscribe, OPML import, universal-link resolver — so that every entry path applies the same lock without depending on UI screens to enforce it.
- Drives navigation: while locked, the Search tab is removed from the bottom navigation and the Developer category card is removed from the Settings grid, so the lock is reflected in the shell rather than only in disabled buttons.
- Hashes the PIN with a per-install salt; never stores or logs the plaintext PIN; rate-limits PIN entry with exponential backoff and clears the in-memory unlock when the app is backgrounded or the idle timeout elapses.
- Provides a Settings → Parental Control screen for PIN setup, PIN change, Restricted Mode toggle, and unlock-timeout selection — every destructive change is gated by re-entering the current PIN.
- Provides a per-podcast "Hide explicit episodes" toggle on subscribed podcast detail, visible and editable only while unlocked, applied as a filter when the episode list is built.
- Supports opt-in biometric unlock via the platform's biometric API (`local_auth`): the Parental Control settings screen exposes the toggle only when the device reports an enrolled biometric, and the PIN entry sheet adds a biometric button under the same condition. Biometric paths reuse the gate's idle-timeout and lockout semantics; biometric failure never counts toward PIN lockout.
- Falls closed on storage failure: an unreadable parental-control store behaves as if Restricted Mode is on and locked, rather than silently disabling the gate.

## Boundaries

- The lock sits at the content-entry boundary only. Playback (FR 04), queue and downloads (FR 05), sleep timer (FR 09), library (FR 13), podcast detail (FR 17), and transcript / chapters (FR 08) are intentionally not gated — they operate over the already-subscribed set, which the device owner has curated.
- This FR does not implement Subscribe, Unsubscribe, OPML import, universal-link resolution, or search itself. Those flows live in FR 02, FR 03, FR 14, and FR 15; this FR only declares the gate they must consult.
- There is no global explicit-content filter, no category blocklist, and no keyword blocklist. The per-podcast `hideExplicitEpisodes` flag is the only content-level filter and is opt-in per show.
- The PIN is local to the install. This feature does not provide cross-device sync, account-based recovery, or tamper-proof enforcement against device reinstall, factory reset, or app deletion; iOS Screen Time and Android Family Link remain the device-level lockdown layer and are out of scope here.
- The Settings → Parental Control screen lives inside the existing settings surface (FR 14) and reuses its persistence and navigation conventions; this FR does not redefine the settings shell. Reset of the PIN through "Reset all data" is owned by FR 14; this FR only declares that path as the documented recovery.

## Traceability

- **Source docs**: (new feature — no prior plan)
- **Related FR**: `02-podcast-discovery.md` (Search tab hidden while restricted), `03-subscription-feeds.md` (Subscribe / Unsubscribe gated), `14-settings.md` (hosts the Parental Control screen and Reset-all-data recovery), `15-links-and-sharing.md` (universal-link follow gated), `17-podcast-detail.md` (Subscribe action and per-podcast explicit-hide toggle)
