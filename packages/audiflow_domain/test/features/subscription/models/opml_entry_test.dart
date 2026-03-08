import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpmlEntry', () {
    group('construction', () {
      test('creates with required fields only', () {
        final entry = OpmlEntry(
          title: 'My Podcast',
          feedUrl: 'https://example.com/feed.xml',
        );

        expect(entry.title, 'My Podcast');
        expect(entry.feedUrl, 'https://example.com/feed.xml');
        expect(entry.htmlUrl, isNull);
      });

      test('creates with all fields', () {
        final entry = OpmlEntry(
          title: 'My Podcast',
          feedUrl: 'https://example.com/feed.xml',
          htmlUrl: 'https://example.com',
        );

        expect(entry.title, 'My Podcast');
        expect(entry.feedUrl, 'https://example.com/feed.xml');
        expect(entry.htmlUrl, 'https://example.com');
      });

      test('accepts empty strings', () {
        final entry = OpmlEntry(title: '', feedUrl: '', htmlUrl: '');

        expect(entry.title, '');
        expect(entry.feedUrl, '');
        expect(entry.htmlUrl, '');
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = OpmlEntry(
          title: 'Podcast',
          feedUrl: 'https://example.com/feed.xml',
          htmlUrl: 'https://example.com',
        );
        final b = OpmlEntry(
          title: 'Podcast',
          feedUrl: 'https://example.com/feed.xml',
          htmlUrl: 'https://example.com',
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('equal when both htmlUrl are null', () {
        final a = OpmlEntry(
          title: 'Podcast',
          feedUrl: 'https://example.com/feed.xml',
        );
        final b = OpmlEntry(
          title: 'Podcast',
          feedUrl: 'https://example.com/feed.xml',
        );

        expect(a, equals(b));
      });

      test('not equal when title differs', () {
        final a = OpmlEntry(title: 'A', feedUrl: 'url');
        final b = OpmlEntry(title: 'B', feedUrl: 'url');

        expect(a, isNot(equals(b)));
      });

      test('not equal when feedUrl differs', () {
        final a = OpmlEntry(title: 'T', feedUrl: 'url1');
        final b = OpmlEntry(title: 'T', feedUrl: 'url2');

        expect(a, isNot(equals(b)));
      });

      test('not equal when htmlUrl differs (null vs value)', () {
        final a = OpmlEntry(title: 'T', feedUrl: 'url');
        final b = OpmlEntry(title: 'T', feedUrl: 'url', htmlUrl: 'html');

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new title', () {
        final original = OpmlEntry(
          title: 'Old Title',
          feedUrl: 'https://example.com/feed.xml',
          htmlUrl: 'https://example.com',
        );
        final copied = original.copyWith(title: 'New Title');

        expect(copied.title, 'New Title');
        expect(copied.feedUrl, 'https://example.com/feed.xml');
        expect(copied.htmlUrl, 'https://example.com');
      });

      test('copies with new feedUrl', () {
        final original = OpmlEntry(title: 'Title', feedUrl: 'old-url');
        final copied = original.copyWith(feedUrl: 'new-url');

        expect(copied.feedUrl, 'new-url');
        expect(copied.title, 'Title');
      });

      test('copies with new htmlUrl', () {
        final original = OpmlEntry(title: 'Title', feedUrl: 'url');
        final copied = original.copyWith(htmlUrl: 'html-url');

        expect(copied.htmlUrl, 'html-url');
      });

      test('returns equal instance when no changes', () {
        final original = OpmlEntry(
          title: 'Title',
          feedUrl: 'url',
          htmlUrl: 'html',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });
  });
}
