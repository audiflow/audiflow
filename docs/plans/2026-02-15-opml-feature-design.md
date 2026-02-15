# OPML Import/Export Feature Design

## Overview

Full round-trip OPML support for Audiflow: export subscriptions to share with
other apps, import from other podcast apps or backups. Uses the standard OPML
2.0 format compatible with Apple Podcasts, Overcast, Pocket Casts, and others.

## Architecture & Package Placement

All business logic lives in `audiflow_domain` under the existing `subscription`
feature. UI lives in `audiflow_app` under `settings`.

### New files in audiflow_domain

```
audiflow_domain/lib/src/features/subscription/
├── models/
│   ├── opml_entry.dart              # @freezed parsed OPML podcast entry
│   └── opml_import_result.dart      # @freezed import result summary
└── services/
    ├── opml_parser_service.dart      # Parse & generate OPML XML
    └── opml_import_service.dart      # Orchestrate import flow
```

### New files in audiflow_app

```
audiflow_app/lib/features/settings/presentation/
├── controllers/
│   ├── opml_export_controller.dart
│   └── opml_import_controller.dart
└── screens/
    └── opml_import_preview_screen.dart
```

### Modified files

- `storage_settings_screen.dart` -- wire up existing Export/Import buttons
- `subscription_local_datasource.dart` -- add batch insert method

## Data Models

### OpmlEntry

Simple `@freezed` class representing a single podcast from an OPML file.
Not persisted.

```dart
@freezed
class OpmlEntry with _$OpmlEntry {
  const factory OpmlEntry({
    required String title,
    required String feedUrl,
    String? htmlUrl,
  }) = _OpmlEntry;
}
```

### OpmlImportResult

Tracks outcomes of the import operation.

```dart
@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required List<OpmlEntry> succeeded,
    required List<OpmlEntry> alreadySubscribed,
    required List<OpmlEntry> failed,
  }) = _OpmlImportResult;
}
```

## OPML Format

Standard OPML 2.0 used by all major podcast apps:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>Audiflow Subscriptions</title>
    <dateCreated>2026-02-15T12:00:00Z</dateCreated>
  </head>
  <body>
    <outline text="feeds">
      <outline type="rss" text="Podcast Title"
               xmlUrl="https://example.com/feed.xml"
               htmlUrl="https://example.com" />
    </outline>
  </body>
</opml>
```

Mapping from Subscription to OPML outline:

| OPML attribute | Source                  |
|----------------|------------------------|
| `text`         | `subscription.title`   |
| `xmlUrl`       | `subscription.feedUrl` |
| `type`         | `"rss"` (constant)     |

## Export Flow

1. User taps "Export Subscriptions" on storage settings screen.
2. `OpmlExportController` fetches all subscriptions from repository.
3. `OpmlParserService.generate(List<Subscription>)` builds OPML XML string.
4. Write XML to a temp file: `{tempDir}/audiflow_subscriptions.opml`.
5. Open system share sheet via `share_plus` with the file.
6. Clean up temp file after share completes.

Edge case: if user has zero subscriptions, show a snackbar "No subscriptions to
export" instead of generating an empty file.

## Import Flow

Three phases:

### Phase 1: File Selection & Parse

1. User taps "Import Subscriptions" on storage settings screen.
2. System file picker opens (filtered to `.opml`, `.xml` files).
3. `OpmlParserService.parse(String xml)` extracts `List<OpmlEntry>`.
4. If parsing fails (invalid XML or no outlines found), show error dialog and
   stop.

### Phase 2: Preview Screen

1. Navigate to `OpmlImportPreviewScreen` with parsed entries.
2. Screen shows a selectable list with checkboxes.
3. Each entry shows: podcast title + feed URL.
4. Already-subscribed podcasts (matched by `feedUrl`) are dimmed and unchecked
   by default.
5. "Import Selected" button at bottom with count badge.

### Phase 3: Subscribe & Enrich

1. `OpmlImportService.importEntries(List<OpmlEntry>)` runs:
   - **Immediate**: Batch-insert subscriptions using feed URL as temporary
     identifier (generate a placeholder `itunesId` like `opml:<feedUrl-hash>`).
   - **Background**: For each new subscription, search iTunes API by feed URL.
     On match, update the subscription row with real `itunesId`, artwork,
     genres, etc.
   - **Feed fetch**: Trigger feed parsing for each new subscription to populate
     episodes.
2. Show progress indicator during import.
3. On completion, show summary dialog: "Imported 10, skipped 3 already
   subscribed, 2 failed".
4. Failed entries listed with "Retry" option.

The placeholder `itunesId` approach avoids schema changes -- the column stays
non-nullable and unique, while background enrichment upgrades it to the real
iTunes ID.

## Error Handling

Best-effort with summary:

- Import what we can, skip failures.
- Show summary at end with counts (succeeded, already subscribed, failed).
- Failed entries listed with option to retry.
- Individual feed resolution failures do not abort the entire import.

## Dependencies

### New

- `file_picker` -- file selection for import (add to `audiflow_app`)

### Existing (reuse)

- `xml` -- already in `audiflow_podcast`, add to `audiflow_domain`
- `share_plus` -- already in `audiflow_app`
- `path_provider` -- already in `audiflow_app`

## Testing Strategy

### Unit tests (audiflow_domain)

**OpmlParserService:**

- Parse valid OPML (standard format from Apple Podcasts, Overcast, etc.)
- Parse OPML with flat outlines (no nested wrapper)
- Handle malformed XML gracefully (return error, not crash)
- Handle empty body / no RSS outlines
- Generate valid OPML from subscriptions
- Round-trip: generate then parse produces same entries

**OpmlImportService:**

- Batch subscribe with placeholder iTunes IDs
- Skip already-subscribed feeds
- Collect failures without aborting
- Background enrichment updates subscription with real iTunes data

### Widget tests (audiflow_app)

**OpmlImportPreviewScreen:**

- Renders all entries with checkboxes
- Already-subscribed entries shown dimmed and unchecked
- Select/deselect toggles count badge
- "Import Selected" triggers import with only checked entries

**StorageSettingsScreen:**

- Export button triggers export flow
- Import button opens file picker

### Not tested

No integration tests for this feature. The file picker and share sheet are
platform-level; mocking them adds complexity without proportional value.

## File Summary

| File | Package | Purpose |
|------|---------|---------|
| `opml_entry.dart` | domain | `@freezed` parsed entry model |
| `opml_import_result.dart` | domain | `@freezed` import result model |
| `opml_parser_service.dart` | domain | Parse & generate OPML XML |
| `opml_import_service.dart` | domain | Orchestrate import flow |
| `opml_export_controller.dart` | app | Riverpod controller for export |
| `opml_import_controller.dart` | app | Riverpod controller for import |
| `opml_import_preview_screen.dart` | app | Selectable list UI |
| `opml_parser_service_test.dart` | domain/test | Parser unit tests |
| `opml_import_service_test.dart` | domain/test | Import service tests |
| `opml_import_preview_screen_test.dart` | app/test | Widget tests |
