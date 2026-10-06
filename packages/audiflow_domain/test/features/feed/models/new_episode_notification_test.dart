import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewEpisodeNotification', () {
    test('constructs with required fields', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      expect(notification.episodeId, 42);
      expect(notification.podcastId, 7);
      expect(notification.podcastTitle, 'The Daily');
      expect(notification.episodeTitle, 'Breaking News');
    });

    test('toPayload returns valid JSON with type and IDs', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      final payload = notification.toPayload();
      final decoded = jsonDecode(payload) as Map<String, dynamic>;

      expect(decoded['type'], 'new_episode');
      expect(decoded['episodeId'], 42);
      expect(decoded['podcastId'], 7);
    });

    test('fromEpisode carries the episode and podcast fields', () {
      final subscription = Subscription()
        ..id = 7
        ..itunesId = '1'
        ..title = 'The Daily';
      final episode = Episode()
        ..id = 42
        ..podcastId = 7
        ..guid = 'g'
        ..title = 'Breaking News'
        ..audioUrl = 'https://example.com/a.mp3'
        ..publishedAt = DateTime.utc(2026, 10, 6)
        ..durationMs = 90000
        ..description = '<p>Notes</p>';

      final notification = NewEpisodeNotification.fromEpisode(
        subscription: subscription,
        episode: episode,
        artworkUrl: 'https://example.com/art.jpg',
      );

      check(notification)
        ..has((n) => n.episodeId, 'episodeId').equals(42)
        ..has((n) => n.podcastId, 'podcastId').equals(7)
        ..has((n) => n.podcastTitle, 'podcastTitle').equals('The Daily')
        ..has((n) => n.episodeTitle, 'episodeTitle').equals('Breaking News')
        ..has(
          (n) => n.artworkUrl,
          'artworkUrl',
        ).equals('https://example.com/art.jpg')
        ..has(
          (n) => n.publishedAt,
          'publishedAt',
        ).equals(DateTime.utc(2026, 10, 6))
        ..has((n) => n.duration, 'duration').equals(const Duration(seconds: 90))
        ..has((n) => n.description, 'description').equals('Notes');
    });

    test('fromEpisode leaves an unknown duration null', () {
      final notification = NewEpisodeNotification.fromEpisode(
        subscription: Subscription()
          ..id = 7
          ..itunesId = '1'
          ..title = 'P',
        episode: Episode()
          ..id = 1
          ..podcastId = 7
          ..guid = 'g'
          ..title = 'E'
          ..audioUrl = 'https://example.com/a.mp3',
        artworkUrl: null,
      );

      check(notification.duration).isNull();
    });

    group('plainTextDescription', () {
      test('strips HTML from the description', () {
        check(
          NewEpisodeNotification.plainTextDescription(
            description: '<p>Show <b>notes</b> &amp; more</p>',
            summary: 'Summary',
          ),
        ).equals('Show notes & more');
      });

      test('keeps paragraph breaks as newlines', () {
        check(
          NewEpisodeNotification.plainTextDescription(
            description: '<p>First</p><p>Second</p>',
            summary: null,
          ),
        ).equals('First\nSecond');
      });

      test('does not split a joined emoji at the cut point', () {
        const max = NewEpisodeNotification.descriptionMaxLength;
        // Family emoji: several code points joined by zero-width joiners.
        const family = '\u{1F468}‍\u{1F469}‍\u{1F467}';
        final result = NewEpisodeNotification.plainTextDescription(
          description: '${'a' * (max - 2)}${family}rest',
          summary: null,
        );

        // Counted as one character, the emoji is kept whole.
        check(result).equals('${'a' * (max - 2)}$family…');
      });

      test('falls back to summary when description is blank', () {
        check(
          NewEpisodeNotification.plainTextDescription(
            description: '<p> </p>',
            summary: 'Summary text',
          ),
        ).equals('Summary text');
      });

      test('returns null when neither has text', () {
        check(
          NewEpisodeNotification.plainTextDescription(
            description: null,
            summary: '',
          ),
        ).isNull();
      });

      test('truncates long text with an ellipsis', () {
        final result = NewEpisodeNotification.plainTextDescription(
          description: 'a' * 1000,
          summary: null,
        );

        check(result).isNotNull()
          ..has(
            (r) => r.length,
            'length',
          ).equals(NewEpisodeNotification.descriptionMaxLength)
          ..endsWith('\u2026');
      });
    });
  });
}
