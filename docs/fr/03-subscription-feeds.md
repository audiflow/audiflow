---
refs:
  id: fr:03-subscription-feeds
  kind: fr
  title: "Subscription and feed management"
  related:
    - fr:02-podcast-discovery
    - fr:12-background-refresh
  modules:
    - packages/audiflow_app/lib/features/subscription/
    - packages/audiflow_domain/lib/src/features/subscription/
    - packages/audiflow_domain/lib/src/features/feed/
---
# FR 03: Subscription and feed management

> Subscribing to and unsubscribing from podcasts, moving subscriptions in and out of the app via OPML, and keeping the subscribed-podcast list and its feeds populated.

## Purpose

Discovery (FR 02) gets a user as far as choosing a podcast; this feature is what turns that choice into a lasting relationship. Subscribing is the act that adds a podcast to the user's library, pulls in its episodes, and signals that the app should keep that feed fresh going forward. Without it, the app would be a search tool with nothing to come back to.

Subscription management also exists to respect the fact that listeners rarely start from zero. People migrate between podcast apps and keep backups, so the feature provides full OPML round-trip support: a user can export their subscriptions to carry them elsewhere, and import a list from Apple Podcasts, Overcast, Pocket Casts, or any other OPML-producing app. The goal is that adopting audiflow never means abandoning an existing library, and leaving it never means losing one.

## User-visible Behavior

- **Subscribing**: From a podcast's detail screen the user toggles a subscribe control. Subscribing records the podcast in the library with its title, artist, artwork, description, and genres, and the podcast immediately appears in the Library tab. Episodes for that podcast are fetched and stored as part of subscribing, so the podcast is browsable right away rather than empty until a later refresh.
- **Unsubscribing**: Toggling the same control while subscribed removes the podcast from the library. The control reflects the current state reactively, so any screen showing the subscribe state updates as soon as it changes.
- **Subscribe failure**: If a chosen podcast has no usable feed URL, subscribing fails with a clear error instead of creating a broken library entry.
- **Exporting subscriptions**: From storage settings the user taps "Export Subscriptions". The app gathers every subscription, writes them to a standard OPML 2.0 file, and opens the system share sheet so the file can be saved or sent to another app. If the user has no subscriptions, a message says there is nothing to export rather than producing an empty file.
- **Importing subscriptions**: From storage settings the user taps "Import Subscriptions" and picks an `.opml` or `.xml` file. The app parses it and shows a preview screen listing every podcast found. Podcasts already in the library are shown dimmed and unchecked; new ones are checked by default. The user adjusts the selection and confirms, and the selected podcasts are added.
- **Receiving a shared OPML file**: An OPML file shared into audiflow from another app (via the system share sheet or "open with") is handled the same way as a picked file — it flows into the import preview.
- **Import outcome**: Import is best-effort. When it finishes, the user sees a summary of how many podcasts were imported, how many were skipped because they were already subscribed, and how many failed. A failure on one feed does not stop the rest of the import.
- **Malformed import file**: If the chosen file is not valid XML, has no `<opml>` root, or contains no podcast feeds, the user sees an explanatory error and the import stops cleanly.

## Capabilities

- **Subscribe / unsubscribe**: Adds or removes a podcast from the user's library, keyed by its iTunes ID, recording the podcast's metadata on subscribe. The subscribe action records the entry surface it came from (discovery, search, deep link, OPML) for analytics.
- **Reactive subscription state**: The subscribed set is observable, so the subscribe control and the library list update automatically whenever a subscription is added or removed; a per-podcast status query backs individual detail screens.
- **Feed fetch on subscribe**: Subscribing triggers parsing of the podcast's RSS feed so its episodes are persisted immediately, making the podcast usable without waiting for a scheduled refresh.
- **Subscribed-podcast list**: Maintains the canonical list of subscriptions ordered newest-first, alongside lookups by iTunes ID, by feed URL, and by database ID.
- **Cached vs. subscribed entries**: Distinguishes true subscriptions from podcasts merely cached for browsing; a cached entry can later be promoted to a real subscription, and unused cached entries can be evicted.
- **Per-subscription settings and feed bookkeeping**: Tracks per-podcast preferences such as auto-download, and stores HTTP cache headers (ETag / Last-Modified) and the last-refreshed timestamp so feed re-fetches can use conditional requests and survive "304 Not Modified" responses.
- **OPML export**: Generates a standard OPML 2.0 document from all current subscriptions and hands it to the system share sheet via a temporary file, which is cleaned up afterward.
- **OPML import**: Parses OPML files from any major podcast app — nested category wrappers or flat layouts — collecting every `<outline>` entry that carries a feed URL, de-duplicating repeated URLs, and falling back to the feed URL as a title when none is given.
- **Import preview and selection**: Presents parsed entries for review, pre-marking already-subscribed podcasts so the user only adds what is genuinely new.
- **Best-effort import orchestration**: For each selected entry, skips it if already subscribed (matched by feed URL), otherwise subscribes it with a deterministic placeholder iTunes ID derived from the feed URL, and collects failures without aborting. The outcome is returned as a summary of succeeded, already-subscribed, and failed entries. The placeholder ID keeps the subscription record valid until background enrichment can replace it with real catalog metadata.
- **Receiving shared OPML files**: Accepts OPML files handed to the app by the OS and routes them into the same import flow as file-picker selections.

## Boundaries

- **Not background refresh**: This feature fetches a feed once, at subscribe time and on explicit import. Periodic re-syncing of subscribed feeds, scheduled background refresh, new-episode detection, and dropped-episode cleanup belong to FR 12 (background refresh). The cache headers and last-refreshed timestamp stored here are the inputs that FR 12 consumes, but the scheduling and execution of recurring sync are out of scope.
- **Not RSS parsing internals**: Turning RSS XML into feed and episode data is owned by the `audiflow_podcast` package (streaming parser, iTunes namespace handling, transcript and chapter extraction). This feature triggers and persists the result; it does not define the parse.
- **Not discovery**: Finding a podcast to subscribe to is FR 02. This feature starts at the moment the user decides to subscribe.
- **Not episode-level features**: Playback, downloads, queueing, and smart-playlist grouping of the episodes pulled in by a subscription are separate features. This FR covers populating the feed, not consuming it.
- **Not implementation detail**: Drift table layout, repository wiring, Riverpod provider graph, and controller state classes are architecture concerns. This FR describes behavior, not storage schema or the state machine.

## Traceability

- **Source docs**: `docs/plans/2026-02-15-opml-feature-design.md`, `docs/plans/2026-02-15-opml-implementation-plan.md`, `packages/audiflow_podcast/CLAUDE.md`, `packages/audiflow_app/lib/features/subscription/presentation/controllers/subscription_controller.dart`, `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart`, `packages/audiflow_domain/lib/src/features/subscription/services/opml_parser_service.dart`, `packages/audiflow_domain/lib/src/features/subscription/services/opml_import_service.dart`, `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_export_controller.dart`, `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart`, `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_file_receiver_controller.dart`, `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart`
- **Related FR**: `fr:02-podcast-discovery` — choosing a podcast to subscribe to. `fr:12-background-refresh` — recurring re-sync of subscribed feeds (forward reference; created separately).
</content>
</invoke>
