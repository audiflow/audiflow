# OPML Import/Export Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add full round-trip OPML import/export for podcast subscriptions, enabling migration from other apps and backup/restore.

**Architecture:** OPML parsing/generation and import orchestration live in `audiflow_domain` under the `subscription` feature. UI controllers and screens live in `audiflow_app` under `settings`. The `OpmlParserService` handles XML ↔ model conversion; `OpmlImportService` orchestrates batch subscribe with background iTunes enrichment.

**Tech Stack:** `xml` (OPML parsing), `file_picker` (import), `share_plus` + `path_provider` (export), `freezed` (models), Riverpod (controllers), Drift (batch insert).

**Design doc:** `docs/plans/2026-02-15-opml-feature-design.md`

---

### Task 1: Add dependencies

**Files:**
- Modify: `packages/audiflow_domain/pubspec.yaml`
- Modify: `packages/audiflow_app/pubspec.yaml`

**Step 1: Add `xml` to audiflow_domain**

Use the `pub` MCP tool to add `xml` to `audiflow_domain`:
```
pub add xml (root: audiflow_domain)
```

**Step 2: Add `file_picker` to audiflow_app**

Use the `pub` MCP tool to add `file_picker` to `audiflow_app`:
```
pub add file_picker (root: audiflow_app)
```

**Step 3: Verify resolution**

Run `pub get` on the workspace root to ensure all packages resolve.

**Step 4: Commit**

```
jj commit -m "chore(deps): add xml and file_picker for OPML feature"
```

---

### Task 2: Create OpmlEntry and OpmlImportResult models

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/subscription/models/opml_entry.dart`
- Create: `packages/audiflow_domain/lib/src/features/subscription/models/opml_import_result.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add exports)

**Step 1: Create OpmlEntry model**

Create `packages/audiflow_domain/lib/src/features/subscription/models/opml_entry.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'opml_entry.freezed.dart';

/// A single podcast entry parsed from an OPML file.
@freezed
class OpmlEntry with _$OpmlEntry {
  const factory OpmlEntry({
    required String title,
    required String feedUrl,
    String? htmlUrl,
  }) = _OpmlEntry;
}
```

**Step 2: Create OpmlImportResult model**

Create `packages/audiflow_domain/lib/src/features/subscription/models/opml_import_result.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'opml_entry.dart';

part 'opml_import_result.freezed.dart';

/// Tracks outcomes of an OPML import operation.
@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required List<OpmlEntry> succeeded,
    required List<OpmlEntry> alreadySubscribed,
    required List<OpmlEntry> failed,
  }) = _OpmlImportResult;
}
```

**Step 3: Add exports to audiflow_domain.dart**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart` after the existing subscription exports:

```dart
// Subscription feature - OPML
export 'src/features/subscription/models/opml_entry.dart';
export 'src/features/subscription/models/opml_import_result.dart';
```

**Step 4: Run code generation**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

**Step 5: Verify analysis passes**

Run `analyze_files` on `audiflow_domain`.

**Step 6: Commit**

```
jj commit -m "feat(subscription): add OpmlEntry and OpmlImportResult models"
```

---

### Task 3: Create OpmlParserService with tests (TDD)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/subscription/services/opml_parser_service.dart`
- Create: `packages/audiflow_domain/test/features/subscription/services/opml_parser_service_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

This is pure logic with no external dependencies -- ideal for TDD.

**Step 1: Write failing tests**

Create `packages/audiflow_domain/test/features/subscription/services/opml_parser_service_test.dart`:

```dart
import 'package:audiflow_domain/src/features/subscription/models/opml_entry.dart';
import 'package:audiflow_domain/src/features/subscription/services/opml_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OpmlParserService service;

  setUp(() {
    service = OpmlParserService();
  });

  group('parse', () {
    test('parses standard nested OPML with outline wrapper', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>My Podcasts</title></head>
  <body>
    <outline text="feeds">
      <outline type="rss" text="Podcast One"
               xmlUrl="https://example.com/feed1.xml"
               htmlUrl="https://example.com/1" />
      <outline type="rss" text="Podcast Two"
               xmlUrl="https://example.com/feed2.xml" />
    </outline>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 2);
      expect(result[0].title, 'Podcast One');
      expect(result[0].feedUrl, 'https://example.com/feed1.xml');
      expect(result[0].htmlUrl, 'https://example.com/1');
      expect(result[1].title, 'Podcast Two');
      expect(result[1].feedUrl, 'https://example.com/feed2.xml');
      expect(result[1].htmlUrl, isNull);
    });

    test('parses flat OPML without outline wrapper', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Podcasts</title></head>
  <body>
    <outline type="rss" text="Flat Podcast"
             xmlUrl="https://example.com/flat.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'Flat Podcast');
      expect(result[0].feedUrl, 'https://example.com/flat.xml');
    });

    test('skips outlines without xmlUrl', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline text="Category">
      <outline type="rss" text="Valid"
               xmlUrl="https://example.com/valid.xml" />
      <outline text="No URL" />
    </outline>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'Valid');
    });

    test('returns empty list for OPML with no RSS outlines', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Empty</title></head>
  <body></body>
</opml>''';

      final result = service.parse(xml);
      expect(result, isEmpty);
    });

    test('throws FormatException for invalid XML', () {
      const xml = 'this is not xml';
      expect(() => service.parse(xml), throwsFormatException);
    });

    test('throws FormatException for XML without opml root', () {
      const xml = '<?xml version="1.0"?><html><body></body></html>';
      expect(() => service.parse(xml), throwsFormatException);
    });

    test('uses xmlUrl as title fallback when text is missing', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline type="rss" xmlUrl="https://example.com/no-title.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'https://example.com/no-title.xml');
      expect(result[0].feedUrl, 'https://example.com/no-title.xml');
    });
  });

  group('generate', () {
    test('generates valid OPML 2.0 from entries', () {
      final entries = [
        const OpmlEntry(
          title: 'Podcast A',
          feedUrl: 'https://example.com/a.xml',
          htmlUrl: 'https://example.com/a',
        ),
        const OpmlEntry(
          title: 'Podcast B',
          feedUrl: 'https://example.com/b.xml',
        ),
      ];

      final xml = service.generate(entries);

      expect(xml, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(xml, contains('<opml version="2.0">'));
      expect(xml, contains('<title>Audiflow Subscriptions</title>'));
      expect(xml, contains('text="Podcast A"'));
      expect(xml, contains('xmlUrl="https://example.com/a.xml"'));
      expect(xml, contains('htmlUrl="https://example.com/a"'));
      expect(xml, contains('text="Podcast B"'));
      expect(xml, contains('xmlUrl="https://example.com/b.xml"'));
    });

    test('generates empty body for empty list', () {
      final xml = service.generate([]);

      expect(xml, contains('<body>'));
      expect(xml, contains('</body>'));
      expect(xml, isNot(contains('xmlUrl')));
    });
  });

  group('round-trip', () {
    test('generate then parse produces equivalent entries', () {
      final original = [
        const OpmlEntry(
          title: 'Round Trip',
          feedUrl: 'https://example.com/round.xml',
          htmlUrl: 'https://example.com/round',
        ),
        const OpmlEntry(
          title: 'No HTML',
          feedUrl: 'https://example.com/nohtml.xml',
        ),
      ];

      final xml = service.generate(original);
      final parsed = service.parse(xml);

      expect(parsed.length, original.length);
      for (var i = 0; i < original.length; i++) {
        expect(parsed[i].title, original[i].title);
        expect(parsed[i].feedUrl, original[i].feedUrl);
        expect(parsed[i].htmlUrl, original[i].htmlUrl);
      }
    });
  });
}
```

**Step 2: Run tests to verify they fail**

Run `run_tests` on `audiflow_domain` with path filter for `test/features/subscription/services/opml_parser_service_test.dart`.
Expected: compilation error (OpmlParserService doesn't exist yet).

**Step 3: Implement OpmlParserService**

Create `packages/audiflow_domain/lib/src/features/subscription/services/opml_parser_service.dart`:

```dart
import 'package:xml/xml.dart';

import '../models/opml_entry.dart';

/// Parses and generates OPML 2.0 XML for podcast subscriptions.
///
/// Handles both nested (outline wrapper) and flat OPML structures
/// for compatibility with Apple Podcasts, Overcast, Pocket Casts, etc.
class OpmlParserService {
  /// Parses an OPML XML string into a list of [OpmlEntry].
  ///
  /// Recursively traverses all `<outline>` elements and collects
  /// those with an `xmlUrl` attribute (RSS feeds).
  ///
  /// Throws [FormatException] if the XML is malformed or lacks
  /// an `<opml>` root element.
  List<OpmlEntry> parse(String xml) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xml);
    } on XmlParserException catch (e) {
      throw FormatException('Invalid XML: ${e.message}');
    }

    final opml = document.findElements('opml').firstOrNull;
    if (opml == null) {
      throw const FormatException('Missing <opml> root element');
    }

    final body = opml.findElements('body').firstOrNull;
    if (body == null) {
      return [];
    }

    final entries = <OpmlEntry>[];
    _collectEntries(body, entries);
    return entries;
  }

  /// Generates an OPML 2.0 XML string from a list of [OpmlEntry].
  String generate(List<OpmlEntry> entries) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('opml', attributes: {'version': '2.0'}, nest: () {
      builder.element('head', nest: () {
        builder.element('title', nest: 'Audiflow Subscriptions');
        builder.element(
          'dateCreated',
          nest: DateTime.now().toUtc().toIso8601String(),
        );
      });
      builder.element('body', nest: () {
        for (final entry in entries) {
          final attrs = <String, String>{
            'type': 'rss',
            'text': entry.title,
            'xmlUrl': entry.feedUrl,
          };
          if (entry.htmlUrl != null) {
            attrs['htmlUrl'] = entry.htmlUrl!;
          }
          builder.element('outline', attributes: attrs);
        }
      });
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _collectEntries(XmlElement element, List<OpmlEntry> entries) {
    for (final outline in element.findElements('outline')) {
      final xmlUrl = outline.getAttribute('xmlUrl');
      if (xmlUrl != null && xmlUrl.isNotEmpty) {
        final text = outline.getAttribute('text');
        entries.add(OpmlEntry(
          title: (text != null && text.isNotEmpty) ? text : xmlUrl,
          feedUrl: xmlUrl,
          htmlUrl: outline.getAttribute('htmlUrl'),
        ));
      }
      // Recurse into nested outlines (category wrappers)
      _collectEntries(outline, entries);
    }
  }
}
```

**Step 4: Add export to audiflow_domain.dart**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/subscription/services/opml_parser_service.dart';
```

**Step 5: Run tests to verify they pass**

Run `run_tests` on `audiflow_domain` with path filter for the test file.
Expected: all tests PASS.

**Step 6: Run analysis**

Run `analyze_files` on `audiflow_domain`. Expected: zero errors.

**Step 7: Commit**

```
jj commit -m "feat(subscription): add OpmlParserService with parse/generate"
```

---

### Task 4: Add batch operations to subscription data layer

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/subscription/datasources/local/subscription_local_datasource.dart`
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`

**Step 1: Add batchInsert to SubscriptionLocalDatasource**

Add method to `packages/audiflow_domain/lib/src/features/subscription/datasources/local/subscription_local_datasource.dart`:

```dart
/// Inserts multiple subscriptions in a single batch.
///
/// Returns the number of rows inserted. Skips entries that
/// violate unique constraints (duplicate itunesId).
Future<int> batchInsert(List<SubscriptionsCompanion> companions) async {
  var inserted = 0;
  await _db.batch((batch) {
    for (final companion in companions) {
      batch.insert(
        _db.subscriptions,
        companion,
        mode: InsertMode.insertOrIgnore,
      );
    }
  });
  // InsertMode.insertOrIgnore doesn't give us exact count,
  // so we return the input count as best-effort.
  inserted = companions.length;
  return inserted;
}
```

**Step 2: Add `existsByFeedUrl` to SubscriptionLocalDatasource**

Add method to the same file:

```dart
/// Returns true if a subscription exists for the given feed URL.
Future<bool> existsByFeedUrl(String feedUrl) async {
  final result = await getByFeedUrl(feedUrl);
  return result != null;
}
```

**Step 3: Add `isSubscribedByFeedUrl` to SubscriptionRepository interface**

Add to `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart`:

```dart
/// Returns whether the user is subscribed to a podcast by feed URL.
Future<bool> isSubscribedByFeedUrl(String feedUrl);
```

**Step 4: Implement in SubscriptionRepositoryImpl**

Add to `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`:

```dart
@override
Future<bool> isSubscribedByFeedUrl(String feedUrl) {
  return _datasource.existsByFeedUrl(feedUrl);
}
```

**Step 5: Run analysis**

Run `analyze_files` on `audiflow_domain`. Expected: zero errors.

**Step 6: Commit**

```
jj commit -m "feat(subscription): add batch insert and feedUrl lookup to data layer"
```

---

### Task 5: Create OpmlImportService with tests (TDD)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/subscription/services/opml_import_service.dart`
- Create: `packages/audiflow_domain/test/features/subscription/services/opml_import_service_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add export)

**Step 1: Write failing tests**

Create `packages/audiflow_domain/test/features/subscription/services/opml_import_service_test.dart`:

```dart
import 'package:audiflow_domain/src/features/subscription/models/opml_entry.dart';
import 'package:audiflow_domain/src/features/subscription/models/opml_import_result.dart';
import 'package:audiflow_domain/src/features/subscription/repositories/subscription_repository.dart';
import 'package:audiflow_domain/src/features/subscription/services/opml_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SubscriptionRepository])
import 'opml_import_service_test.mocks.dart';

void main() {
  late MockSubscriptionRepository mockRepo;
  late OpmlImportService service;

  setUp(() {
    mockRepo = MockSubscriptionRepository();
    service = OpmlImportService(repository: mockRepo);
  });

  group('importEntries', () {
    test('subscribes new entries with placeholder itunesId', () async {
      const entry = OpmlEntry(
        title: 'New Podcast',
        feedUrl: 'https://example.com/new.xml',
      );

      when(mockRepo.isSubscribedByFeedUrl(entry.feedUrl))
          .thenAnswer((_) async => false);
      when(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: entry.feedUrl,
        title: entry.title,
        artistName: anyNamed('artistName'),
      )).thenAnswer((_) async => _fakeSubscription());

      final result = await service.importEntries([entry]);

      expect(result.succeeded.length, 1);
      expect(result.succeeded[0].feedUrl, entry.feedUrl);
      expect(result.alreadySubscribed, isEmpty);
      expect(result.failed, isEmpty);

      final captured = verify(mockRepo.subscribe(
        itunesId: captureAnyNamed('itunesId'),
        feedUrl: entry.feedUrl,
        title: entry.title,
        artistName: captureAnyNamed('artistName'),
      )).captured;

      // itunesId should start with 'opml:'
      final itunesId = captured[0] as String;
      expect(itunesId, startsWith('opml:'));
    });

    test('skips already-subscribed entries', () async {
      const entry = OpmlEntry(
        title: 'Existing',
        feedUrl: 'https://example.com/existing.xml',
      );

      when(mockRepo.isSubscribedByFeedUrl(entry.feedUrl))
          .thenAnswer((_) async => true);

      final result = await service.importEntries([entry]);

      expect(result.succeeded, isEmpty);
      expect(result.alreadySubscribed.length, 1);
      expect(result.failed, isEmpty);
      verifyNever(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: anyNamed('feedUrl'),
        title: anyNamed('title'),
        artistName: anyNamed('artistName'),
      ));
    });

    test('collects failures without aborting', () async {
      const good = OpmlEntry(
        title: 'Good',
        feedUrl: 'https://example.com/good.xml',
      );
      const bad = OpmlEntry(
        title: 'Bad',
        feedUrl: 'https://example.com/bad.xml',
      );

      when(mockRepo.isSubscribedByFeedUrl(good.feedUrl))
          .thenAnswer((_) async => false);
      when(mockRepo.isSubscribedByFeedUrl(bad.feedUrl))
          .thenAnswer((_) async => false);

      when(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: good.feedUrl,
        title: good.title,
        artistName: anyNamed('artistName'),
      )).thenAnswer((_) async => _fakeSubscription());

      when(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: bad.feedUrl,
        title: bad.title,
        artistName: anyNamed('artistName'),
      )).thenThrow(Exception('DB error'));

      final result = await service.importEntries([good, bad]);

      expect(result.succeeded.length, 1);
      expect(result.succeeded[0].feedUrl, good.feedUrl);
      expect(result.failed.length, 1);
      expect(result.failed[0].feedUrl, bad.feedUrl);
      expect(result.alreadySubscribed, isEmpty);
    });

    test('handles mixed results correctly', () async {
      const newEntry = OpmlEntry(
        title: 'New',
        feedUrl: 'https://example.com/new.xml',
      );
      const existingEntry = OpmlEntry(
        title: 'Existing',
        feedUrl: 'https://example.com/existing.xml',
      );
      const failEntry = OpmlEntry(
        title: 'Fail',
        feedUrl: 'https://example.com/fail.xml',
      );

      when(mockRepo.isSubscribedByFeedUrl(newEntry.feedUrl))
          .thenAnswer((_) async => false);
      when(mockRepo.isSubscribedByFeedUrl(existingEntry.feedUrl))
          .thenAnswer((_) async => true);
      when(mockRepo.isSubscribedByFeedUrl(failEntry.feedUrl))
          .thenAnswer((_) async => false);

      when(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: newEntry.feedUrl,
        title: newEntry.title,
        artistName: anyNamed('artistName'),
      )).thenAnswer((_) async => _fakeSubscription());

      when(mockRepo.subscribe(
        itunesId: anyNamed('itunesId'),
        feedUrl: failEntry.feedUrl,
        title: failEntry.title,
        artistName: anyNamed('artistName'),
      )).thenThrow(Exception('fail'));

      final result = await service.importEntries(
        [newEntry, existingEntry, failEntry],
      );

      expect(result.succeeded.length, 1);
      expect(result.alreadySubscribed.length, 1);
      expect(result.failed.length, 1);
    });

    test('returns empty result for empty input', () async {
      final result = await service.importEntries([]);

      expect(result.succeeded, isEmpty);
      expect(result.alreadySubscribed, isEmpty);
      expect(result.failed, isEmpty);
    });
  });
}

// Helper to create a fake Subscription for mock returns.
// The actual Subscription type is a Drift-generated data class.
// We use a minimal fake that satisfies the return type.
dynamic _fakeSubscription() {
  // This will need to be a real Subscription instance.
  // Use Drift's companion or create via database test utilities.
  // For mockito, we just need the Future to complete.
  // The test only checks the OpmlImportResult, not the Subscription itself.
  throw UnimplementedError(
    'Replace with actual Subscription constructor from generated code',
  );
}
```

**Important:** The `_fakeSubscription()` helper needs to return a real `Subscription` instance from Drift. Look at `packages/audiflow_domain/lib/src/common/database/app_database.dart` for the generated `Subscription` data class constructor and create a minimal valid instance. It will have fields like:
```dart
Subscription(
  id: 1,
  itunesId: 'opml:test',
  feedUrl: 'https://example.com/test.xml',
  title: 'Test',
  artistName: '',
  artworkUrl: null,
  description: null,
  genres: '',
  explicit: false,
  subscribedAt: DateTime.now(),
  lastRefreshedAt: null,
)
```

**Step 2: Run tests to verify they fail**

Run `run_tests` on `audiflow_domain` with path filter.
Expected: compilation error (OpmlImportService doesn't exist yet).

**Step 3: Implement OpmlImportService**

Create `packages/audiflow_domain/lib/src/features/subscription/services/opml_import_service.dart`:

```dart
import 'dart:convert';

import 'package:crypto/crypto.dart' show md5; // If available, otherwise use hashCode

import '../models/opml_entry.dart';
import '../models/opml_import_result.dart';
import '../repositories/subscription_repository.dart';

/// Orchestrates OPML import: checks duplicates, batch subscribes,
/// and collects results.
class OpmlImportService {
  OpmlImportService({required SubscriptionRepository repository})
    : _repository = repository;

  final SubscriptionRepository _repository;

  /// Imports a list of [OpmlEntry] as subscriptions.
  ///
  /// For each entry:
  /// - Skips if already subscribed (matched by feedUrl)
  /// - Subscribes with placeholder itunesId (`opml:<hash>`)
  /// - Collects failures without aborting
  ///
  /// Returns [OpmlImportResult] summarizing outcomes.
  Future<OpmlImportResult> importEntries(List<OpmlEntry> entries) async {
    final succeeded = <OpmlEntry>[];
    final alreadySubscribed = <OpmlEntry>[];
    final failed = <OpmlEntry>[];

    for (final entry in entries) {
      try {
        final exists = await _repository.isSubscribedByFeedUrl(entry.feedUrl);
        if (exists) {
          alreadySubscribed.add(entry);
          continue;
        }

        final placeholderId = _generatePlaceholderId(entry.feedUrl);
        await _repository.subscribe(
          itunesId: placeholderId,
          feedUrl: entry.feedUrl,
          title: entry.title,
          artistName: '',
        );
        succeeded.add(entry);
      } on Exception {
        failed.add(entry);
      }
    }

    return OpmlImportResult(
      succeeded: succeeded,
      alreadySubscribed: alreadySubscribed,
      failed: failed,
    );
  }

  /// Generates a deterministic placeholder iTunes ID from a feed URL.
  String _generatePlaceholderId(String feedUrl) {
    final hash = feedUrl.hashCode.toRadixString(16);
    return 'opml:$hash';
  }
}
```

**Note:** Don't use `crypto` package -- `hashCode` is sufficient for a placeholder ID that will be replaced by the real iTunes ID during background enrichment.

**Step 4: Add export to audiflow_domain.dart**

```dart
export 'src/features/subscription/services/opml_import_service.dart';
```

**Step 5: Generate mocks and run tests**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

Then run `run_tests`. Fix the `_fakeSubscription()` helper with the real `Subscription` constructor. Expected: all tests PASS.

**Step 6: Run analysis**

Run `analyze_files` on `audiflow_domain`. Expected: zero errors.

**Step 7: Commit**

```
jj commit -m "feat(subscription): add OpmlImportService with best-effort import"
```

---

### Task 6: Create OpmlExportController

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_export_controller.dart`

**Step 1: Implement OpmlExportController**

Create `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_export_controller.dart`:

```dart
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'opml_export_controller.g.dart';

/// Sealed result type for export operations.
sealed class OpmlExportState {}

class OpmlExportIdle extends OpmlExportState {}

class OpmlExportLoading extends OpmlExportState {}

class OpmlExportSuccess extends OpmlExportState {}

class OpmlExportEmpty extends OpmlExportState {}

class OpmlExportError extends OpmlExportState {
  OpmlExportError(this.message);
  final String message;
}

/// Controls OPML export: fetch subscriptions, generate XML,
/// share via system share sheet.
@riverpod
class OpmlExportController extends _$OpmlExportController {
  @override
  OpmlExportState build() => OpmlExportIdle();

  /// Exports all subscriptions as an OPML file and opens
  /// the system share sheet.
  Future<void> export() async {
    state = OpmlExportLoading();

    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscriptions = await repo.getSubscriptions();

      if (subscriptions.isEmpty) {
        state = OpmlExportEmpty();
        return;
      }

      final entries = subscriptions
          .map((s) => OpmlEntry(
                title: s.title,
                feedUrl: s.feedUrl,
              ))
          .toList();

      final parser = OpmlParserService();
      final xml = parser.generate(entries);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/audiflow_subscriptions.opml');
      await file.writeAsString(xml);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );

      // Clean up temp file
      if (file.existsSync()) {
        await file.delete();
      }

      state = OpmlExportSuccess();
    } on Exception catch (e) {
      state = OpmlExportError(e.toString());
    }
  }
}
```

**Step 2: Run code generation**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Run analysis**

Run `analyze_files` on `audiflow_app`. Expected: zero errors.

**Step 4: Commit**

```
jj commit -m "feat(settings): add OpmlExportController"
```

---

### Task 7: Create OpmlImportController

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart`

**Step 1: Implement OpmlImportController**

Create `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'opml_import_controller.g.dart';

/// Sealed result type for import file pick + parse.
sealed class OpmlPickResult {}

class OpmlPickIdle extends OpmlPickResult {}

class OpmlPickLoading extends OpmlPickResult {}

class OpmlPickSuccess extends OpmlPickResult {
  OpmlPickSuccess({required this.entries, required this.subscribedFeedUrls});
  final List<OpmlEntry> entries;
  final Set<String> subscribedFeedUrls;
}

class OpmlPickError extends OpmlPickResult {
  OpmlPickError(this.message);
  final String message;
}

class OpmlPickCancelled extends OpmlPickResult {}

/// Sealed result type for the actual import operation.
sealed class OpmlImportState {}

class OpmlImportIdle extends OpmlImportState {}

class OpmlImportLoading extends OpmlImportState {}

class OpmlImportDone extends OpmlImportState {
  OpmlImportDone(this.result);
  final OpmlImportResult result;
}

class OpmlImportError extends OpmlImportState {
  OpmlImportError(this.message);
  final String message;
}

/// Controls OPML import: pick file, parse, and execute import.
@riverpod
class OpmlImportController extends _$OpmlImportController {
  @override
  OpmlPickResult build() => OpmlPickIdle();

  /// Opens file picker, reads the OPML file, and parses entries.
  ///
  /// On success, sets state to [OpmlPickSuccess] with parsed
  /// entries and a set of already-subscribed feed URLs.
  Future<void> pickAndParse() async {
    state = OpmlPickLoading();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml', 'xml'],
      );

      if (result == null || result.files.isEmpty) {
        state = OpmlPickCancelled();
        return;
      }

      final file = result.files.first;
      final path = file.path;
      if (path == null) {
        state = OpmlPickError('Could not read file');
        return;
      }

      final content = await _readFile(path);
      final parser = OpmlParserService();
      final entries = parser.parse(content);

      if (entries.isEmpty) {
        state = OpmlPickError('No podcast feeds found in the file');
        return;
      }

      // Check which feeds are already subscribed
      final repo = ref.read(subscriptionRepositoryProvider);
      final subscribedUrls = <String>{};
      for (final entry in entries) {
        final exists = await repo.isSubscribedByFeedUrl(entry.feedUrl);
        if (exists) {
          subscribedUrls.add(entry.feedUrl);
        }
      }

      state = OpmlPickSuccess(
        entries: entries,
        subscribedFeedUrls: subscribedUrls,
      );
    } on FormatException catch (e) {
      state = OpmlPickError(e.message);
    } on Exception catch (e) {
      state = OpmlPickError(e.toString());
    }
  }

  Future<String> _readFile(String path) async {
    final file = java.io.File(path);
    return file.readAsString();
  }
}
```

**Important fix:** The `_readFile` method uses `dart:io`. Replace `java.io.File` with:
```dart
import 'dart:io';
// ...
Future<String> _readFile(String path) async {
  final file = File(path);
  return file.readAsString();
}
```

**Step 2: Run code generation**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

**Step 3: Run analysis**

Run `analyze_files` on `audiflow_app`. Expected: zero errors.

**Step 4: Commit**

```
jj commit -m "feat(settings): add OpmlImportController"
```

---

### Task 8: Create OpmlImportPreviewScreen

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/screens/opml_import_preview_screen.dart`

**Step 1: Implement the preview screen**

Create `packages/audiflow_app/lib/features/settings/presentation/screens/opml_import_preview_screen.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preview screen for OPML import showing a selectable list
/// of podcast entries parsed from the OPML file.
///
/// Already-subscribed entries are dimmed and unchecked by default.
/// User can toggle checkboxes and tap "Import Selected" to proceed.
class OpmlImportPreviewScreen extends ConsumerStatefulWidget {
  const OpmlImportPreviewScreen({
    required this.entries,
    required this.subscribedFeedUrls,
    super.key,
  });

  final List<OpmlEntry> entries;
  final Set<String> subscribedFeedUrls;

  @override
  ConsumerState<OpmlImportPreviewScreen> createState() =>
      _OpmlImportPreviewScreenState();
}

class _OpmlImportPreviewScreenState
    extends ConsumerState<OpmlImportPreviewScreen> {
  late final Set<String> _selectedFeedUrls;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    // Pre-select all entries that are NOT already subscribed
    _selectedFeedUrls = widget.entries
        .where((e) => !widget.subscribedFeedUrls.contains(e.feedUrl))
        .map((e) => e.feedUrl)
        .toSet();
  }

  int get _selectedCount => _selectedFeedUrls.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Import Podcasts')),
      body: ListView.builder(
        itemCount: widget.entries.length,
        itemBuilder: (context, index) {
          final entry = widget.entries[index];
          final isSubscribed = widget.subscribedFeedUrls
              .contains(entry.feedUrl);
          final isSelected = _selectedFeedUrls.contains(entry.feedUrl);

          return CheckboxListTile(
            value: isSelected,
            onChanged: _isImporting
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selectedFeedUrls.add(entry.feedUrl);
                      } else {
                        _selectedFeedUrls.remove(entry.feedUrl);
                      }
                    });
                  },
            title: Text(
              entry.title,
              style: isSubscribed
                  ? theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    )
                  : null,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.feedUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                if (isSubscribed)
                  Text(
                    'Already subscribed',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_selectedCount < 1 || _isImporting)
                ? null
                : _importSelected,
            child: _isImporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Import Selected ($_selectedCount)'),
          ),
        ),
      ),
    );
  }

  Future<void> _importSelected() async {
    setState(() => _isImporting = true);

    final selectedEntries = widget.entries
        .where((e) => _selectedFeedUrls.contains(e.feedUrl))
        .toList();

    final repo = ref.read(subscriptionRepositoryProvider);
    final importService = OpmlImportService(repository: repo);
    final result = await importService.importEntries(selectedEntries);

    if (!mounted) return;

    // Pop back and return the result
    Navigator.of(context).pop(result);
  }
}
```

**Step 2: Run analysis**

Run `analyze_files` on `audiflow_app`. Expected: zero errors.

**Step 3: Commit**

```
jj commit -m "feat(settings): add OpmlImportPreviewScreen"
```

---

### Task 9: Wire up StorageSettingsScreen

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/storage_settings_screen.dart`

**Step 1: Replace the _OpmlSection widget**

The existing `_OpmlSection` shows "Coming soon" for both buttons. Replace it to wire up the export and import flows.

Replace the `_OpmlSection` class (lines 118-152) with a `ConsumerWidget` version that:

1. **Export button:** Calls `OpmlExportController.export()` and shows snackbar for results (empty/error/success).
2. **Import button:** Calls `OpmlImportController.pickAndParse()`, navigates to `OpmlImportPreviewScreen` on success, shows error snackbar on failure, and shows the import result summary dialog when returning.

Key changes:
- `_OpmlSection` becomes a `ConsumerWidget` (needs `ref` for controllers)
- Remove the `context` constructor parameter (not needed, use `BuildContext` from `build`)
- Export button calls the export controller
- Import button calls the import controller, then navigates to preview screen
- On return from preview, show summary dialog with results

**Step 2: Update parent widget**

In `StorageSettingsScreen.build()`, update the `_OpmlSection` instantiation to remove the `context:` parameter since it's now a `ConsumerWidget`.

**Step 3: Add imports**

Add these imports to the top of `storage_settings_screen.dart`:
```dart
import '../controllers/opml_export_controller.dart';
import '../controllers/opml_import_controller.dart';
import 'opml_import_preview_screen.dart';
```

**Step 4: Run analysis**

Run `analyze_files` on `audiflow_app`. Expected: zero errors.

**Step 5: Commit**

```
jj commit -m "feat(settings): wire up OPML export/import in storage settings"
```

---

### Task 10: Write OpmlParserService tests for edge cases

**Files:**
- Modify: `packages/audiflow_domain/test/features/subscription/services/opml_parser_service_test.dart`

Add additional edge case tests (if not already covered in Task 3):
- OPML from Apple Podcasts (deeply nested categories)
- OPML with special characters in titles (XML entities: `&amp;`, `&lt;`)
- OPML with duplicate feed URLs (should parse all, dedup is import service's job)
- Very large OPML (100+ entries -- just verify it doesn't crash)

**Step 1: Add edge case tests**

Add to the existing test file.

**Step 2: Run all tests**

Run `run_tests` on `audiflow_domain`. Expected: all tests PASS.

**Step 3: Commit**

```
jj commit -m "test(subscription): add edge case tests for OPML parser"
```

---

### Task 11: Final verification and bookmark

**Step 1: Run dart format**

Run `dart_format` on both `audiflow_domain` and `audiflow_app`.

**Step 2: Run analysis on all packages**

Run `analyze_files` on the workspace. Expected: zero errors.

**Step 3: Run all tests**

Run `run_tests` on `audiflow_domain`. Expected: all tests PASS.

**Step 4: Create jj bookmark**

```bash
jj bookmark create feat/opml-import-export
```

---

## Implementation Notes

### Key file paths reference

| File | Full path |
|------|-----------|
| OpmlEntry model | `packages/audiflow_domain/lib/src/features/subscription/models/opml_entry.dart` |
| OpmlImportResult model | `packages/audiflow_domain/lib/src/features/subscription/models/opml_import_result.dart` |
| OpmlParserService | `packages/audiflow_domain/lib/src/features/subscription/services/opml_parser_service.dart` |
| OpmlImportService | `packages/audiflow_domain/lib/src/features/subscription/services/opml_import_service.dart` |
| OpmlExportController | `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_export_controller.dart` |
| OpmlImportController | `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart` |
| OpmlImportPreviewScreen | `packages/audiflow_app/lib/features/settings/presentation/screens/opml_import_preview_screen.dart` |
| StorageSettingsScreen | `packages/audiflow_app/lib/features/settings/presentation/screens/storage_settings_screen.dart` |
| Domain exports | `packages/audiflow_domain/lib/audiflow_domain.dart` |
| Subscription table | `packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.dart` |
| Subscription repo interface | `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart` |
| Subscription repo impl | `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart` |
| Subscription datasource | `packages/audiflow_domain/lib/src/features/subscription/datasources/local/subscription_local_datasource.dart` |
| Parser tests | `packages/audiflow_domain/test/features/subscription/services/opml_parser_service_test.dart` |
| Import service tests | `packages/audiflow_domain/test/features/subscription/services/opml_import_service_test.dart` |

### Conventions observed

- **Riverpod controllers:** Use `@riverpod` annotation with code generation (see `theme_controller.dart`)
- **Repository pattern:** Interface + impl in same package (see `subscription_repository.dart` / `_impl.dart`)
- **Provider for repo:** `@Riverpod(keepAlive: true)` function in impl file (see `subscriptionRepository` provider)
- **Domain exports:** All public types exported from `audiflow_domain.dart`
- **Test pattern:** Arrange-Act-Assert with mockito, mocks generated via `@GenerateMocks`
- **Navigation:** GoRouter for persistent routes, `Navigator.push` for transient screens
- **Numeric comparisons:** Use `<` and `<=` only (never `>` or `>=`)
- **VCS:** jj (Jujutsu), not git
