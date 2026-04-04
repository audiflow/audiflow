import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([QueueRepository, EpisodeRepository, AppSettingsRepository])
import 'queue_service_test.mocks.dart';

Episode _episode({
  required int id,
  int podcastId = 1,
  String? title,
  int? episodeNumber,
  DateTime? publishedAt,
}) {
  return Episode()
    ..id = id
    ..podcastId = podcastId
    ..guid = 'guid-$id'
    ..title = title ?? 'Episode $id'
    ..audioUrl = 'https://example.com/ep$id.mp3'
    ..episodeNumber = episodeNumber
    ..publishedAt = publishedAt;
}

QueueItem _queueItem({
  required int id,
  required int episodeId,
  int position = 0,
  bool isAdhoc = true,
  String? sourceContext,
}) {
  return QueueItem()
    ..id = id
    ..episodeId = episodeId
    ..position = position
    ..isAdhoc = isAdhoc
    ..sourceContext = sourceContext
    ..addedAt = DateTime.now();
}

void _stubReplaceWithAdhoc(MockQueueRepository mock) {
  when(
    mock.replaceWithAdhoc(
      episodeIds: anyNamed('episodeIds'),
      sourceContext: anyNamed('sourceContext'),
    ),
  ).thenAnswer((_) async {});
}

void main() {
  late MockQueueRepository mockQueueRepo;
  late MockEpisodeRepository mockEpisodeRepo;
  late MockAppSettingsRepository mockSettingsRepo;
  late QueueService service;

  setUp(() {
    provideDummy(const PlaybackQueue());
    mockQueueRepo = MockQueueRepository();
    mockEpisodeRepo = MockEpisodeRepository();
    mockSettingsRepo = MockAppSettingsRepository();
    // Default to oldestFirst (existing behavior)
    when(
      mockSettingsRepo.getAutoPlayOrder(),
    ).thenReturn(AutoPlayOrder.oldestFirst);
    service = QueueService(
      repository: mockQueueRepo,
      episodeRepository: mockEpisodeRepo,
      settingsRepository: mockSettingsRepo,
      logger: Logger(level: Level.off),
    );
  });

  group('playLater', () {
    test('adds episode to end of queue', () async {
      final episode = _episode(id: 1);
      final queueItem = _queueItem(id: 1, episodeId: 1);

      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(mockQueueRepo.addToEnd(1)).thenAnswer((_) async => queueItem);

      final result = await service.playLater(1);

      expect(result, isNotNull);
      expect(result!.episodeId, 1);
      verify(mockQueueRepo.addToEnd(1)).called(1);
    });

    test('returns null when episode not found', () async {
      when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => null);

      final result = await service.playLater(99);

      expect(result, isNull);
      verifyNever(mockQueueRepo.addToEnd(any));
    });
  });

  group('playNext', () {
    test('adds episode to front of queue', () async {
      final episode = _episode(id: 1);
      final queueItem = _queueItem(id: 1, episodeId: 1);

      when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => episode);
      when(mockQueueRepo.addToFront(1)).thenAnswer((_) async => queueItem);

      final result = await service.playNext(1);

      expect(result, isNotNull);
      expect(result!.episodeId, 1);
      verify(mockQueueRepo.addToFront(1)).called(1);
    });

    test('returns null when episode not found', () async {
      when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => null);

      final result = await service.playNext(99);

      expect(result, isNull);
      verifyNever(mockQueueRepo.addToFront(any));
    });
  });

  group('shouldConfirmAdhocReplace', () {
    test('delegates to repository hasManualItems', () async {
      when(mockQueueRepo.hasManualItems()).thenAnswer((_) async => true);

      final result = await service.shouldConfirmAdhocReplace();

      expect(result, true);
      verify(mockQueueRepo.hasManualItems()).called(1);
    });

    test('returns false when no manual items', () async {
      when(mockQueueRepo.hasManualItems()).thenAnswer((_) async => false);

      final result = await service.shouldConfirmAdhocReplace();

      expect(result, false);
    });
  });

  group('createAdhocQueue', () {
    group('without siblingEpisodeIds', () {
      test('queues subsequent episodes by episode number', () async {
        final starting = _episode(id: 1, episodeNumber: 5);
        final subsequent = [
          _episode(id: 2, episodeNumber: 6),
          _episode(id: 3, episodeNumber: 7),
          _episode(id: 4, episodeNumber: 8),
        ];

        when(mockEpisodeRepo.getById(1)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getSubsequentEpisodes(
            podcastId: anyNamed('podcastId'),
            afterEpisodeNumber: anyNamed('afterEpisodeNumber'),
            limit: anyNamed('limit'),
          ),
        ).thenAnswer((_) async => subsequent);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 1,
          sourceContext: 'Test Podcast',
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [2, 3, 4],
            sourceContext: 'Test Podcast',
          ),
        ).called(1);
      });

      test('does nothing when starting episode not found', () async {
        when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => null);

        await service.createAdhocQueue(
          startingEpisodeId: 99,
          sourceContext: 'Test',
        );

        verifyNever(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: anyNamed('episodeIds'),
            sourceContext: anyNamed('sourceContext'),
          ),
        );
      });
    });

    group('with siblingEpisodeIds', () {
      test(
        'sorts siblings by episode number ascending and queues after starting',
        () async {
          final siblingIds = [10, 20, 30, 40, 50];
          final starting = _episode(id: 30, episodeNumber: 3);
          final siblings = [
            _episode(id: 10, episodeNumber: 1),
            _episode(id: 20, episodeNumber: 2),
            _episode(id: 30, episodeNumber: 3),
            _episode(id: 40, episodeNumber: 4),
            _episode(id: 50, episodeNumber: 5),
          ];

          when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
          when(
            mockEpisodeRepo.getByIds(siblingIds),
          ).thenAnswer((_) async => siblings);
          _stubReplaceWithAdhoc(mockQueueRepo);

          await service.createAdhocQueue(
            startingEpisodeId: 30,
            sourceContext: 'Group',
            siblingEpisodeIds: siblingIds,
          );

          verify(
            mockQueueRepo.replaceWithAdhoc(
              episodeIds: [40, 50],
              sourceContext: 'Group',
            ),
          ).called(1);
        },
      );

      test('queues all remaining episodes from first episode', () async {
        final siblingIds = [10, 20, 30, 40, 50];
        final starting = _episode(id: 10, episodeNumber: 1);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
          _episode(id: 30, episodeNumber: 3),
          _episode(id: 40, episodeNumber: 4),
          _episode(id: 50, episodeNumber: 5),
        ];

        when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 10,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [20, 30, 40, 50],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('empty queue when playing last episode', () async {
        final siblingIds = [10, 20, 30];
        final starting = _episode(id: 30, episodeNumber: 3);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
          _episode(id: 30, episodeNumber: 3),
        ];

        when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 30,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('sorts by episode number regardless of input order', () async {
        final siblingIds = [50, 40, 30, 20, 10];
        final starting = _episode(id: 30, episodeNumber: 3);
        final siblings = [
          _episode(id: 50, episodeNumber: 5),
          _episode(id: 20, episodeNumber: 2),
          _episode(id: 40, episodeNumber: 4),
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 30, episodeNumber: 3),
        ];

        when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 30,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [40, 50],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('falls back to publishedAt when episodeNumber is null', () async {
        final siblingIds = [10, 20, 30];
        final starting = _episode(id: 20, publishedAt: DateTime(2024, 2));
        final siblings = [
          _episode(id: 30, publishedAt: DateTime(2024, 3)),
          _episode(id: 10, publishedAt: DateTime(2024, 1)),
          _episode(id: 20, publishedAt: DateTime(2024, 2)),
        ];

        when(mockEpisodeRepo.getById(20)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 20,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [30],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('episodes with episodeNumber sort before those without', () async {
        final siblingIds = [10, 20, 30];
        final starting = _episode(id: 10, episodeNumber: 1);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
          _episode(id: 30),
        ];

        when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 10,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [20, 30],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('handles starting episode not in siblings list', () async {
        final siblingIds = [10, 20];
        final starting = _episode(id: 99, episodeNumber: 5);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
        ];

        when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 99,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('does not include starting episode in queue', () async {
        final siblingIds = [10, 20];
        final starting = _episode(id: 10, episodeNumber: 1);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
        ];

        when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 10,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [20],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('does not call getSubsequentEpisodes', () async {
        final siblingIds = [10, 20];
        final starting = _episode(id: 10, episodeNumber: 1);
        final siblings = [
          _episode(id: 10, episodeNumber: 1),
          _episode(id: 20, episodeNumber: 2),
        ];

        when(mockEpisodeRepo.getById(10)).thenAnswer((_) async => starting);
        when(
          mockEpisodeRepo.getByIds(siblingIds),
        ).thenAnswer((_) async => siblings);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 10,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verifyNever(
          mockEpisodeRepo.getSubsequentEpisodes(
            podcastId: anyNamed('podcastId'),
            afterEpisodeNumber: anyNamed('afterEpisodeNumber'),
            limit: anyNamed('limit'),
          ),
        );
      });
    });

    group('with siblingEpisodeIds and asDisplayed order', () {
      setUp(() {
        when(
          mockSettingsRepo.getAutoPlayOrder(),
        ).thenReturn(AutoPlayOrder.asDisplayed);
      });

      test('preserves display order without fetching from DB', () async {
        final siblingIds = [50, 30, 10, 40, 20];
        final starting = _episode(id: 30, episodeNumber: 3);

        when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 30,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        // Should preserve order: after 30 comes [10, 40, 20]
        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [10, 40, 20],
            sourceContext: 'Group',
          ),
        ).called(1);

        // Should NOT call getByIds (no sorting needed)
        verifyNever(mockEpisodeRepo.getByIds(any));
      });

      test('empty queue when starting episode is last', () async {
        final siblingIds = [10, 20, 30];
        final starting = _episode(id: 30, episodeNumber: 3);

        when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 30,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [],
            sourceContext: 'Group',
          ),
        ).called(1);
      });

      test('empty queue when starting episode not in list', () async {
        final siblingIds = [10, 20];
        final starting = _episode(id: 99, episodeNumber: 5);

        when(mockEpisodeRepo.getById(99)).thenAnswer((_) async => starting);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 99,
          sourceContext: 'Group',
          siblingEpisodeIds: siblingIds,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [],
            sourceContext: 'Group',
          ),
        ).called(1);
      });
    });

    group('with forceDisplayOrder', () {
      test(
        'preserves display order even when autoPlayOrder is chronological',
        () async {
          // Default setUp uses oldestFirst (chronological), which normally
          // re-sorts by publishedAt. forceDisplayOrder should bypass that.
          final siblingIds = [50, 30, 10, 40, 20];
          final starting = _episode(
            id: 30,
            episodeNumber: 3,
            publishedAt: DateTime(2024, 3),
          );

          when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
          _stubReplaceWithAdhoc(mockQueueRepo);

          await service.createAdhocQueue(
            startingEpisodeId: 30,
            sourceContext: 'Station',
            siblingEpisodeIds: siblingIds,
            forceDisplayOrder: true,
          );

          // Should preserve display order: after 30 comes [10, 40, 20]
          verify(
            mockQueueRepo.replaceWithAdhoc(
              episodeIds: [10, 40, 20],
              sourceContext: 'Station',
            ),
          ).called(1);

          // Should NOT fetch episodes from DB for sorting
          verifyNever(mockEpisodeRepo.getByIds(any));
        },
      );

      test('empty queue when starting episode is last in list', () async {
        final siblingIds = [10, 20, 30];
        final starting = _episode(id: 30);

        when(mockEpisodeRepo.getById(30)).thenAnswer((_) async => starting);
        _stubReplaceWithAdhoc(mockQueueRepo);

        await service.createAdhocQueue(
          startingEpisodeId: 30,
          sourceContext: 'Station',
          siblingEpisodeIds: siblingIds,
          forceDisplayOrder: true,
        );

        verify(
          mockQueueRepo.replaceWithAdhoc(
            episodeIds: [],
            sourceContext: 'Station',
          ),
        ).called(1);
      });
    });
  });

  group('removeItem', () {
    test('delegates to repository', () async {
      when(mockQueueRepo.remove(5)).thenAnswer((_) async {});

      await service.removeItem(5);

      verify(mockQueueRepo.remove(5)).called(1);
    });
  });

  group('clearQueue', () {
    test('delegates to repository', () async {
      when(mockQueueRepo.clearAll()).thenAnswer((_) async {});

      await service.clearQueue();

      verify(mockQueueRepo.clearAll()).called(1);
    });
  });

  group('reorderItem', () {
    test('delegates to repository', () async {
      when(mockQueueRepo.reorder(3, 5)).thenAnswer((_) async {});

      await service.reorderItem(3, 5);

      verify(mockQueueRepo.reorder(3, 5)).called(1);
    });
  });

  group('popNextEpisode', () {
    test('returns next episode and removes it by ID', () async {
      final episode = _episode(id: 2);
      final qItem = _queueItem(id: 10, episodeId: 2);
      final queue = PlaybackQueue(
        adhocItems: [QueueItemWithEpisode(queueItem: qItem, episode: episode)],
      );

      when(mockQueueRepo.getQueue()).thenAnswer((_) async => queue);
      when(mockQueueRepo.remove(any)).thenAnswer((_) async {});

      final result = await service.popNextEpisode();

      expect(result, isNotNull);
      expect(result!.id, 2);
      verify(mockQueueRepo.getQueue()).called(1);
      verify(mockQueueRepo.remove(10)).called(1);
    });

    test('returns null and does not remove when queue is empty', () async {
      when(
        mockQueueRepo.getQueue(),
      ).thenAnswer((_) async => const PlaybackQueue());

      final result = await service.popNextEpisode();

      expect(result, isNull);
      verifyNever(mockQueueRepo.remove(any));
    });

    test('returns episodes in FIFO order across successive calls', () async {
      final ep2 = _episode(id: 2, title: 'Episode 2');
      final ep3 = _episode(id: 3, title: 'Episode 3');
      final qItem2 = _queueItem(id: 10, episodeId: 2, position: 0);
      final qItem3 = _queueItem(id: 11, episodeId: 3, position: 10);

      // Stateful fake: mutable list that getQueue reads from and
      // remove mutates, so the data reflects real queue behavior.
      final items = [
        QueueItemWithEpisode(queueItem: qItem2, episode: ep2),
        QueueItemWithEpisode(queueItem: qItem3, episode: ep3),
      ];

      when(
        mockQueueRepo.getQueue(),
      ).thenAnswer((_) async => PlaybackQueue(adhocItems: List.of(items)));
      when(mockQueueRepo.remove(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments.first as int;
        items.removeWhere((i) => i.queueItem.id == id);
      });

      // First pop: should return ep2
      final first = await service.popNextEpisode();
      expect(first?.id, 2);

      // Second pop: should return ep3
      final second = await service.popNextEpisode();
      expect(second?.id, 3);

      // Third pop: queue empty
      final third = await service.popNextEpisode();
      expect(third, isNull);
    });

    test('skips orphan queue items with missing episodes', () async {
      // Simulate orphan: queue has item id=10 (episodeId=99, no episode
      // join) followed by item id=11 (episodeId=3). _buildPlaybackQueue
      // drops the orphan, so nextItem points to id=11.
      final ep3 = _episode(id: 3);
      final qItem3 = _queueItem(id: 11, episodeId: 3);
      final queue = PlaybackQueue(
        adhocItems: [QueueItemWithEpisode(queueItem: qItem3, episode: ep3)],
      );

      when(mockQueueRepo.getQueue()).thenAnswer((_) async => queue);
      when(mockQueueRepo.remove(any)).thenAnswer((_) async {});

      final result = await service.popNextEpisode();

      expect(result?.id, 3);
      // Removes the correct item (id=11), not the orphan at DB head
      verify(mockQueueRepo.remove(11)).called(1);
    });
  });

  group('skipToItem', () {
    test('removes all items up to and including target', () async {
      final episode1 = _episode(id: 1);
      final episode2 = _episode(id: 2);
      final episode3 = _episode(id: 3);

      final queue = PlaybackQueue(
        adhocItems: [
          QueueItemWithEpisode(
            queueItem: _queueItem(id: 100, episodeId: 1),
            episode: episode1,
          ),
          QueueItemWithEpisode(
            queueItem: _queueItem(id: 101, episodeId: 2),
            episode: episode2,
          ),
          QueueItemWithEpisode(
            queueItem: _queueItem(id: 102, episodeId: 3),
            episode: episode3,
          ),
        ],
      );

      when(mockQueueRepo.getQueue()).thenAnswer((_) async => queue);
      when(mockQueueRepo.remove(any)).thenAnswer((_) async {});

      final result = await service.skipToItem(101);

      expect(result, isNotNull);
      expect(result!.id, 2);
      verify(mockQueueRepo.remove(100)).called(1);
      verify(mockQueueRepo.remove(101)).called(1);
      verifyNever(mockQueueRepo.remove(102));
    });

    test('returns null when queue item not found', () async {
      when(
        mockQueueRepo.getQueue(),
      ).thenAnswer((_) async => const PlaybackQueue());

      final result = await service.skipToItem(999);

      expect(result, isNull);
      verifyNever(mockQueueRepo.remove(any));
    });
  });
}
