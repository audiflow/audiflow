import 'package:audiflow_app/features/settings/presentation/screens/opml_import_preview_screen.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump_app.dart';

/// Records what the screen subscribes, so the test can assert the feed
/// urls handed to the sync afterwards.
class _ImportingSubscriptionRepository extends FakeSubscriptionRepository {
  final subscribedFeedUrls = <String>[];

  /// Feed urls this repository reports as already subscribed.
  final existingFeedUrls = <String>{};

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) async =>
      existingFeedUrls.contains(feedUrl);

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) async {
    subscribedFeedUrls.add(feedUrl);
    return Subscription()
      ..id = subscribedFeedUrls.length
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = artistName
      ..genres = ''
      ..explicit = explicit
      ..subscribedAt = DateTime.now();
  }
}

/// Captures the feed urls the screen asks to sync after an import.
class _RecordingFeedSyncService implements FeedSyncService {
  List<String>? syncedFeedUrls;

  /// When set, the sync fails the way a database or network error would.
  Object? failure;

  @override
  Future<FeedSyncResult> syncFeedsByUrls(List<String> feedUrls) async {
    syncedFeedUrls = feedUrls;
    final error = failure;
    if (error != null) throw error;
    return const FeedSyncResult(
      totalCount: 0,
      successCount: 0,
      skipCount: 0,
      errorCount: 0,
    );
  }

  @override
  Future<FeedSyncResult> syncAllSubscriptions({bool forceRefresh = false}) =>
      throw UnimplementedError();

  @override
  Future<FeedSyncResult> syncStationFeeds(int stationId) =>
      throw UnimplementedError();

  @override
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) => throw UnimplementedError();

  @override
  Future<void> cancelAll() => throw UnimplementedError();
}

OpmlEntry _entry(String title, String feedUrl) =>
    OpmlEntry(title: title, feedUrl: feedUrl);

void main() {
  late _ImportingSubscriptionRepository repository;
  late _RecordingFeedSyncService syncService;

  setUp(() {
    repository = _ImportingSubscriptionRepository();
    syncService = _RecordingFeedSyncService();
  });

  Future<void> pumpPreview(
    WidgetTester tester, {
    required List<OpmlEntry> entries,
    Set<String> subscribedFeedUrls = const {},
  }) async {
    await tester.pumpApp(
      OpmlImportPreviewScreen(
        entries: entries,
        subscribedFeedUrls: subscribedFeedUrls,
      ),
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(repository),
        feedSyncServiceProvider.overrideWithValue(syncService),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapImport(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
  }

  testWidgets('syncs the feeds it just imported', (tester) async {
    await pumpPreview(
      tester,
      entries: [
        _entry('Syntax', 'https://feed.syntax.fm/rss'),
        _entry('The Changelog', 'https://changelog.com/podcast/feed'),
      ],
    );

    await tapImport(tester);

    check(repository.subscribedFeedUrls).deepEquals([
      'https://feed.syntax.fm/rss',
      'https://changelog.com/podcast/feed',
    ]);
    check(syncService.syncedFeedUrls).isNotNull().deepEquals([
      'https://feed.syntax.fm/rss',
      'https://changelog.com/podcast/feed',
    ]);
  });

  testWidgets('does not sync feeds that were already subscribed', (
    tester,
  ) async {
    repository.existingFeedUrls.add('https://changelog.com/podcast/feed');

    await pumpPreview(
      tester,
      entries: [
        _entry('Syntax', 'https://feed.syntax.fm/rss'),
        _entry('The Changelog', 'https://changelog.com/podcast/feed'),
      ],
    );

    await tapImport(tester);

    check(
      syncService.syncedFeedUrls,
    ).isNotNull().deepEquals(['https://feed.syntax.fm/rss']);
  });

  testWidgets('completes the import when the sync fails', (tester) async {
    // The sync is fired without being awaited, so a failure must not
    // escape as an unhandled async error or block the summary.
    syncService.failure = StateError('database closed');

    await pumpPreview(
      tester,
      entries: [_entry('Syntax', 'https://feed.syntax.fm/rss')],
    );

    await tapImport(tester);

    check(
      repository.subscribedFeedUrls,
    ).deepEquals(['https://feed.syntax.fm/rss']);
    check(tester.takeException()).isNull();
  });

  testWidgets('skips the sync when nothing was imported', (tester) async {
    repository.existingFeedUrls.add('https://feed.syntax.fm/rss');

    await pumpPreview(
      tester,
      entries: [_entry('Syntax', 'https://feed.syntax.fm/rss')],
    );

    await tapImport(tester);

    check(syncService.syncedFeedUrls).isNull();
  });
}
