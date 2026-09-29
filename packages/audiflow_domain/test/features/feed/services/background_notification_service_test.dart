import 'dart:async';
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Stubs
// ---------------------------------------------------------------------------

/// Fake [NotificationsShowDelegate] that records calls and can be configured
/// to throw on specific call indices.
class _StubShowDelegate implements NotificationsShowDelegate {
  _StubShowDelegate({Set<int>? throwOnCallIndices})
    : _throwOnCallIndices = throwOnCallIndices ?? {};

  final Set<int> _throwOnCallIndices;
  int _callCount = 0;
  final List<int> showedIds = [];
  final List<NotificationDetails?> shownDetails = [];

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    final index = _callCount;
    _callCount++;
    if (_throwOnCallIndices.contains(index)) {
      throw Exception('simulated show() failure at index $index');
    }
    showedIds.add(id);
    shownDetails.add(notificationDetails);
  }
}

class _StubFormatter implements NotificationTextFormatter {
  const _StubFormatter();

  @override
  String formatDate(DateTime date) => 'D:${date.day}';

  @override
  String formatDuration(Duration duration) => '${duration.inMinutes}min';
}

const _formatter = _StubFormatter();

// ---------------------------------------------------------------------------

void main() {
  group('BackgroundNotificationService', () {
    group('showPerEpisodeNotifications', () {
      test(
        'continues showing subsequent notifications after one fails',
        () async {
          final stub = _StubShowDelegate(throwOnCallIndices: {1});
          final service = BackgroundNotificationService(
            textFormatter: _formatter,
          );

          final notifications = [
            const NewEpisodeNotification(
              episodeId: 1,
              podcastId: 10,
              podcastTitle: 'Podcast A',
              episodeTitle: 'Episode 1',
            ),
            const NewEpisodeNotification(
              episodeId: 2,
              podcastId: 10,
              podcastTitle: 'Podcast A',
              episodeTitle: 'Episode 2',
            ),
            const NewEpisodeNotification(
              episodeId: 3,
              podcastId: 10,
              podcastTitle: 'Podcast A',
              episodeTitle: 'Episode 3',
            ),
          ];

          // Rethrows after all notifications are attempted.
          await expectLater(
            () => service.showPerEpisodeNotificationsViaDelegate(
              stub,
              notifications,
            ),
            throwsA(isA<Exception>()),
          );

          // Episodes 1 and 3 were shown despite episode 2 failing.
          expect(stub.showedIds, containsAll([1, 3]));
        },
      );

      test(
        'rethrows a summarized exception when at least one show fails',
        () async {
          final stub = _StubShowDelegate(throwOnCallIndices: {0});
          final service = BackgroundNotificationService(
            textFormatter: _formatter,
          );

          final notifications = [
            const NewEpisodeNotification(
              episodeId: 1,
              podcastId: 10,
              podcastTitle: 'Podcast A',
              episodeTitle: 'Episode 1',
            ),
            const NewEpisodeNotification(
              episodeId: 2,
              podcastId: 10,
              podcastTitle: 'Podcast A',
              episodeTitle: 'Episode 2',
            ),
          ];

          await expectLater(
            () => service.showPerEpisodeNotificationsViaDelegate(
              stub,
              notifications,
            ),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('1/2 notification(s)'),
              ),
            ),
          );
        },
      );
    });

    group('artwork', () {
      const withArtwork = NewEpisodeNotification(
        episodeId: 1,
        podcastId: 10,
        podcastTitle: 'Podcast A',
        episodeTitle: 'Episode 1',
        artworkUrl: 'https://example.com/art.jpg',
      );

      test('attaches artwork file on Android and iOS', () async {
        final stub = _StubShowDelegate();
        final requests = <(String, int)>[];
        final service = BackgroundNotificationService(
          textFormatter: _formatter,
          artworkFileProvider: (url, id) async {
            requests.add((url, id));
            return '/tmp/art-$id.png';
          },
        );

        await service.showPerEpisodeNotificationsViaDelegate(stub, [
          withArtwork,
        ]);

        check(requests).deepEquals([('https://example.com/art.jpg', 1)]);
        final details = stub.shownDetails.single!;
        check(details.android!.largeIcon)
            .isA<FilePathAndroidBitmap>()
            .has((icon) => icon.data, 'data')
            .equals('/tmp/art-1.png');
        check(
          details.iOS!.attachments!.single.filePath,
        ).equals('/tmp/art-1.png');
      });

      test('tints the small icon with the app icon colour', () async {
        final stub = _StubShowDelegate();

        await BackgroundNotificationService(
          textFormatter: _formatter,
        ).showPerEpisodeNotificationsViaDelegate(stub, [withArtwork]);

        check(
          stub.shownDetails.single!.android!.color,
        ).equals(androidNotificationColor);
      });

      test('shows text-only notification when artwork fails', () async {
        final stub = _StubShowDelegate();
        final service = BackgroundNotificationService(
          textFormatter: _formatter,
          artworkFileProvider: (_, _) async => throw Exception('network'),
        );

        await service.showPerEpisodeNotificationsViaDelegate(stub, [
          withArtwork,
        ]);

        final details = stub.shownDetails.single!;
        check(details.android!.largeIcon).isNull();
        check(details.iOS!.attachments).isNull();
      });

      test('gives up on artwork that does not arrive in time', () {
        fakeAsync((async) {
          final stub = _StubShowDelegate();
          final service = BackgroundNotificationService(
            textFormatter: _formatter,
            artworkFileProvider: (_, _) => Completer<String?>().future,
          );

          var done = false;
          service
              .showPerEpisodeNotificationsViaDelegate(stub, [withArtwork])
              .then((_) => done = true);
          async.elapse(const Duration(seconds: 10));

          check(done).isTrue();
          check(stub.shownDetails.single!.android!.largeIcon).isNull();
        });
      });

      test('skips artwork lookup when podcast has no artwork', () async {
        final stub = _StubShowDelegate();
        var calls = 0;
        final service = BackgroundNotificationService(
          textFormatter: _formatter,
          artworkFileProvider: (_, _) async {
            calls++;
            return '/tmp/art.png';
          },
        );

        await service.showPerEpisodeNotificationsViaDelegate(stub, [
          const NewEpisodeNotification(
            episodeId: 1,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 1',
          ),
        ]);

        check(calls).equals(0);
        check(stub.shownDetails.single!.android!.largeIcon).isNull();
      });
    });

    group('rich content', () {
      final rich = NewEpisodeNotification(
        episodeId: 1,
        podcastId: 10,
        podcastTitle: 'Podcast A',
        episodeTitle: 'Episode 1',
        publishedAt: DateTime(2026, 9, 1),
        duration: const Duration(minutes: 65),
        description: 'Show notes',
      );

      test('puts podcast and date in subtitle, duration and notes in body', () {
        final detail = BackgroundNotificationService.buildNotificationDetails([
          rich,
        ], _formatter).single;

        check(detail.title).equals('Episode 1');
        check(detail.subtitle).equals('Podcast A \u00B7 D:1');
        check(detail.body).equals('65min \u00B7 Show notes');
      });

      test('omits missing parts without leaving separators', () {
        const partial = NewEpisodeNotification(
          episodeId: 1,
          podcastId: 10,
          podcastTitle: 'Podcast A',
          episodeTitle: 'Episode 1',
          description: 'Show notes',
        );

        final detail = BackgroundNotificationService.buildNotificationDetails([
          partial,
        ], _formatter).single;

        check(detail.subtitle).equals('Podcast A');
        check(detail.body).equals('Show notes');
      });

      test('sets iOS subtitle and a stable category', () async {
        final stub = _StubShowDelegate();

        await BackgroundNotificationService(
          textFormatter: _formatter,
        ).showPerEpisodeNotificationsViaDelegate(stub, [rich]);

        final iOS = stub.shownDetails.single!.iOS!;
        check(iOS.subtitle).equals('Podcast A \u00B7 D:1');
        check(iOS.categoryIdentifier).equals(newEpisodeNotificationCategory);
      });

      test('expands the body on Android with podcast as sub text', () async {
        final stub = _StubShowDelegate();

        await BackgroundNotificationService(
          textFormatter: _formatter,
        ).showPerEpisodeNotificationsViaDelegate(stub, [rich]);

        final android = stub.shownDetails.single!.android!;
        check(android.subText).equals('Podcast A');
        check(android.styleInformation)
            .isA<BigTextStyleInformation>()
            .has((style) => style.bigText, 'bigText')
            .equals('65min \u00B7 Show notes');
      });

      test('uses the default Android style without a body', () async {
        final stub = _StubShowDelegate();

        await BackgroundNotificationService(
          textFormatter: _formatter,
        ).showPerEpisodeNotificationsViaDelegate(stub, [
          const NewEpisodeNotification(
            episodeId: 1,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 1',
          ),
        ]);

        check(stub.shownDetails.single!.android!.styleInformation).isNull();
      });
    });

    group('buildNotificationDetails', () {
      test('returns per-episode details list', () {
        final notifications = [
          const NewEpisodeNotification(
            episodeId: 1,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 1',
          ),
          const NewEpisodeNotification(
            episodeId: 2,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 2',
          ),
        ];

        final details = BackgroundNotificationService.buildNotificationDetails(
          notifications,
          _formatter,
        );

        expect(details.length, 2);

        expect(details[0].id, 1);
        expect(details[0].title, 'Episode 1');
        expect(details[0].subtitle, 'Podcast A');
        expect(details[0].body, isNull);
        final payload0 = jsonDecode(details[0].payload) as Map<String, dynamic>;
        expect(payload0['type'], 'new_episode');
        expect(payload0['episodeId'], 1);
        expect(payload0['podcastId'], 10);

        expect(details[1].id, 2);
        expect(details[1].title, 'Episode 2');
      });

      test('returns empty list for empty input', () {
        final details = BackgroundNotificationService.buildNotificationDetails(
          [],
          _formatter,
        );
        expect(details, isEmpty);
      });
    });
  });
}
