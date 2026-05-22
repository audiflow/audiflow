---
refs:
  id: fr:15-links-and-sharing
  kind: fr
  title: "Universal links and sharing"
  related:
    - fr:01-app-foundation
    - fr:04-audio-playback
  modules:
    - packages/audiflow_app/lib/features/share/
    - packages/audiflow_domain/lib/src/features/share/
    - packages/audiflow_app/lib/routing/
---

# FR 15: Universal links and sharing

> Lets users share podcasts and episodes as `audiflow.reedom.com` web links that open the right screen inside the app, and resolves such links when they are tapped from outside.

## Purpose

A podcast player is more useful when listeners can pass content to each other, but a raw RSS `<link>` or audio URL has no connection to Audiflow — tapping it opens a browser, not the app. Before this feature the episode share buttons were non-functional stubs and the episode detail screen shared the unrelated RSS link.

This feature gives the app a single, branded URL space (`https://audiflow.reedom.com/p/...`) for podcasts and episodes. A shared link opens directly on the matching screen when the recipient has Audiflow installed, and falls back to the appropriate app store when they do not. It also lets a sharer pin a specific moment in an episode, so "listen to this bit at 34:20" can be communicated as a link.

## User-visible Behavior

- Normal case (sharing): from a podcast detail screen, an episode list tile, a smart-playlist episode tile, or the episode detail screen, the user taps a share button. The system share sheet opens with an `audiflow.reedom.com` link. Podcast links look like `https://audiflow.reedom.com/p/{itunesId}`; episode links append `/e/{encodedGuid}`.
- Normal case (timestamped sharing): when a share is initiated with a chosen position, the episode link carries a `?t=<seconds>` query parameter. Opening that link starts playback at (or near) that moment instead of the saved-resume position.
- Normal case (opening with the app installed): tapping a universal link launches Audiflow. A brief loading screen ("Opening link...") appears while the link is resolved, then the app navigates to the podcast detail screen or to the episode detail screen.
- Normal case (opening without the app): tapping the link in a browser or messaging app loads a static page that detects the platform and redirects to the App Store (iOS) or Play Store (Android).
- Edge case (episode not yet known locally): when the linked episode is not in the local database, the app fetches and parses the podcast feed to locate it by GUID before navigating.
- Edge case (podcast not subscribed): when the linked podcast is not subscribed, the app looks it up via the iTunes API to obtain its feed URL, title, and artwork.
- Edge case (timestamp malformed): a `t` value that is not a non-negative integer is ignored; playback falls back to the saved-resume position. A timestamp past the episode end is clamped to the episode duration.
- Failure case: an unresolvable podcast or a network failure sends the user to the home screen with an explanatory snackbar. An episode GUID that cannot be found in the feed degrades gracefully to opening the podcast detail screen instead.
- Fallback (sharing): when an episode has no shareable GUID or the link cannot be built, sharing falls back to the episode's RSS link; when nothing shareable exists, the share is a no-op.

## Capabilities

- Builds branded universal link URLs for a podcast (by iTunes ID) and for an episode (iTunes ID plus Base64url-encoded GUID, without padding so the URL is HTTP-safe).
- Optionally embeds a playback start position in an episode link as a `?t=<seconds>` query parameter, emitted only when the position is strictly positive.
- Presents share buttons across the podcast detail screen, episode detail screen, episode list tiles, and smart-playlist episode tiles, all routed through a shared share helper with a consistent fallback chain (universal link, then RSS link, then no-op).
- Hands off the constructed URL to the system share sheet.
- Resolves incoming `https://audiflow.reedom.com/p/...` URIs into typed navigation targets (podcast or episode), validating scheme, host, and path shape.
- Resolves a linked podcast from a local subscription first, then from the iTunes API when not subscribed; resolves a linked episode from the local database first, then by parsing the live feed.
- Decodes the Base64url episode GUID and parses the optional `t` timestamp, forwarding it to the episode target.
- Drives a dedicated deep-link loading screen that shows progress, navigates to the resolved screen on success, and recovers to the home screen with a localized error message on failure.
- Registers top-level GoRouter routes (`/p/:itunesId` and `/p/:itunesId/e/:encodedGuid`) so universal links match before the router's unknown-route exception handler.

## Boundaries

- General app routing, the tab navigation shell, and the GoRouter setup are owned by FR 01 (app foundation); this feature only adds the two deep-link routes and the loading screen that bridge into existing screens.
- Audio playback, the resume-position logic, and seeking are owned by FR 04 (audio playback); this feature only conveys a requested start position and lets playback apply or clamp it.
- It does not own the static `audiflow-universal-links` site (association files and store-redirect pages); that lives in a separate repository and is configured via platform association files.
- It does not import OPML/feed files — the existing OPML link handler is a separate path that filters by file extension and does not capture `/p/...` links.
- It does not provide station sharing, rich link previews (Open Graph metadata), link-click analytics, deferred deep linking, or non-Apple servicer support (the URL shape leaves room for servicer prefixes, but only Apple/iTunes is implemented).
- It does not define episode bookmarks; timestamped links are a standalone capability that a future bookmarks feature could build on.

## Traceability

- **Source docs**:
  - `docs/superpowers/plans/2026-03-22-universal-links.md`
  - `docs/superpowers/specs/2026-03-22-universal-links-design.md`
  - `docs/superpowers/specs/2026-04-17-share-url-timestamp-design.md`
  - `packages/audiflow_domain/lib/src/features/share/services/share_link_builder.dart`, `share_link_builder_impl.dart`
  - `packages/audiflow_domain/lib/src/features/share/services/deep_link_resolver.dart`, `deep_link_resolver_impl.dart`
  - `packages/audiflow_domain/lib/src/features/share/models/deep_link_target.dart`
  - `packages/audiflow_domain/lib/src/features/share/providers/share_providers.dart`
  - `packages/audiflow_app/lib/features/share/presentation/helpers/share_helper.dart`
  - `packages/audiflow_app/lib/features/share/presentation/screens/deep_link_screen.dart`
  - `packages/audiflow_app/lib/routing/app_router.dart`
- **Related FR**: `01-app-foundation.md`, `04-audio-playback.md`
