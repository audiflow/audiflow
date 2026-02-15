import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/subscription/models/opml_entry.dart';
import 'package:audiflow_domain/src/features/subscription/models/opml_import_result.dart';
import 'package:audiflow_domain/src/features/subscription/repositories/subscription_repository.dart';
import 'package:audiflow_domain/src/features/subscription/services/opml_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([SubscriptionRepository])
import 'opml_import_service_test.mocks.dart';

Subscription _subscription({
  required int id,
  required String itunesId,
  required String feedUrl,
  required String title,
}) {
  return Subscription(
    id: id,
    itunesId: itunesId,
    feedUrl: feedUrl,
    title: title,
    artistName: '',
    artworkUrl: null,
    description: null,
    genres: '',
    explicit: false,
    subscribedAt: DateTime.now(),
    lastRefreshedAt: null,
  );
}

void main() {
  late MockSubscriptionRepository mockRepository;
  late OpmlImportService service;

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    service = OpmlImportService(repository: mockRepository);
  });

  group('importEntries', () {
    test('subscribes new entries with placeholder itunesId', () async {
      const entry = OpmlEntry(
        title: 'Test Podcast',
        feedUrl: 'https://example.com/feed.xml',
      );

      when(
        mockRepository.isSubscribedByFeedUrl(entry.feedUrl),
      ).thenAnswer((_) async => false);

      when(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: anyNamed('feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      ).thenAnswer(
        (invocation) async => _subscription(
          id: 1,
          itunesId: invocation.namedArguments[#itunesId] as String,
          feedUrl: invocation.namedArguments[#feedUrl] as String,
          title: invocation.namedArguments[#title] as String,
        ),
      );

      final result = await service.importEntries([entry]);

      expect(result.succeeded, hasLength(1));
      expect(result.succeeded.first, entry);
      expect(result.alreadySubscribed, isEmpty);
      expect(result.failed, isEmpty);

      final captured = verify(
        mockRepository.subscribe(
          itunesId: captureAnyNamed('itunesId'),
          feedUrl: captureAnyNamed('feedUrl'),
          title: captureAnyNamed('title'),
          artistName: captureAnyNamed('artistName'),
        ),
      ).captured;

      final capturedItunesId = captured[0] as String;
      expect(capturedItunesId, startsWith('opml:'));
      expect(captured[1], entry.feedUrl);
      expect(captured[2], entry.title);
      expect(captured[3], '');
    });

    test('skips already-subscribed entries', () async {
      const entry = OpmlEntry(
        title: 'Existing Podcast',
        feedUrl: 'https://example.com/existing.xml',
      );

      when(
        mockRepository.isSubscribedByFeedUrl(entry.feedUrl),
      ).thenAnswer((_) async => true);

      final result = await service.importEntries([entry]);

      expect(result.succeeded, isEmpty);
      expect(result.alreadySubscribed, hasLength(1));
      expect(result.alreadySubscribed.first, entry);
      expect(result.failed, isEmpty);

      verifyNever(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: anyNamed('feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      );
    });

    test('collects failures without aborting', () async {
      const successEntry = OpmlEntry(
        title: 'Success Podcast',
        feedUrl: 'https://example.com/success.xml',
      );
      const failEntry = OpmlEntry(
        title: 'Fail Podcast',
        feedUrl: 'https://example.com/fail.xml',
      );

      when(
        mockRepository.isSubscribedByFeedUrl(successEntry.feedUrl),
      ).thenAnswer((_) async => false);
      when(
        mockRepository.isSubscribedByFeedUrl(failEntry.feedUrl),
      ).thenAnswer((_) async => false);

      when(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: argThat(equals(successEntry.feedUrl), named: 'feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      ).thenAnswer(
        (_) async => _subscription(
          id: 1,
          itunesId: 'opml:test',
          feedUrl: successEntry.feedUrl,
          title: successEntry.title,
        ),
      );

      when(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: argThat(equals(failEntry.feedUrl), named: 'feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await service.importEntries([successEntry, failEntry]);

      expect(result.succeeded, hasLength(1));
      expect(result.succeeded.first, successEntry);
      expect(result.failed, hasLength(1));
      expect(result.failed.first, failEntry);
      expect(result.alreadySubscribed, isEmpty);
    });

    test('handles mixed results correctly', () async {
      const newEntry = OpmlEntry(
        title: 'New Podcast',
        feedUrl: 'https://example.com/new.xml',
      );
      const existingEntry = OpmlEntry(
        title: 'Existing Podcast',
        feedUrl: 'https://example.com/existing.xml',
      );
      const failingEntry = OpmlEntry(
        title: 'Failing Podcast',
        feedUrl: 'https://example.com/failing.xml',
      );

      when(
        mockRepository.isSubscribedByFeedUrl(newEntry.feedUrl),
      ).thenAnswer((_) async => false);
      when(
        mockRepository.isSubscribedByFeedUrl(existingEntry.feedUrl),
      ).thenAnswer((_) async => true);
      when(
        mockRepository.isSubscribedByFeedUrl(failingEntry.feedUrl),
      ).thenAnswer((_) async => false);

      when(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: argThat(equals(newEntry.feedUrl), named: 'feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      ).thenAnswer(
        (_) async => _subscription(
          id: 1,
          itunesId: 'opml:new',
          feedUrl: newEntry.feedUrl,
          title: newEntry.title,
        ),
      );

      when(
        mockRepository.subscribe(
          itunesId: anyNamed('itunesId'),
          feedUrl: argThat(equals(failingEntry.feedUrl), named: 'feedUrl'),
          title: anyNamed('title'),
          artistName: anyNamed('artistName'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await service.importEntries([
        newEntry,
        existingEntry,
        failingEntry,
      ]);

      expect(result.succeeded, hasLength(1));
      expect(result.succeeded.first, newEntry);
      expect(result.alreadySubscribed, hasLength(1));
      expect(result.alreadySubscribed.first, existingEntry);
      expect(result.failed, hasLength(1));
      expect(result.failed.first, failingEntry);
    });

    test('returns empty result for empty input', () async {
      final result = await service.importEntries([]);

      expect(result.succeeded, isEmpty);
      expect(result.alreadySubscribed, isEmpty);
      expect(result.failed, isEmpty);

      verifyZeroInteractions(mockRepository);
    });
  });
}
