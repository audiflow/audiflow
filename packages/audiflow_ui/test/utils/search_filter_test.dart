import 'package:audiflow_ui/src/utils/search_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final items = [
    _Item('Flutter Guide', 'A guide to Flutter development'),
    _Item('Dart Basics', 'Learn the Dart language'),
    _Item('React Native', 'Cross-platform with Flutter comparison'),
    _Item('SwiftUI Tips', 'iOS development tips'),
  ];

  group('filterBySearchQuery', () {
    test('returns all items when query is empty', () {
      final result = filterBySearchQuery(
        items: items,
        query: '',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result, items);
    });

    test('returns all items when query is shorter than 2 chars', () {
      final result = filterBySearchQuery(
        items: items,
        query: 'a',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result, items);
    });

    test('title matches come before description-only matches', () {
      final result = filterBySearchQuery(
        items: items,
        query: 'flutter',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result.length, 2);
      expect(result[0].title, 'Flutter Guide');
      expect(result[1].title, 'React Native');
    });

    test('title matches preserve original order', () {
      final items = [
        _Item('Zebra Flutter', 'desc'),
        _Item('Alpha Flutter', 'desc'),
        _Item('Middle Flutter', 'desc'),
      ];
      final result = filterBySearchQuery(
        items: items,
        query: 'flutter',
        getTitle: (i) => i.title,
      );
      expect(result[0].title, 'Zebra Flutter');
      expect(result[1].title, 'Alpha Flutter');
      expect(result[2].title, 'Middle Flutter');
    });

    test('is case insensitive', () {
      final result = filterBySearchQuery(
        items: items,
        query: 'DART',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result.length, 1);
      expect(result[0].title, 'Dart Basics');
    });

    test('returns empty list when nothing matches', () {
      final result = filterBySearchQuery(
        items: items,
        query: 'xyzzy',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result, isEmpty);
    });

    test('handles null description', () {
      final items = [
        _Item('Flutter Guide', null),
        _Item('Dart Basics', 'Learn Flutter here'),
      ];
      final result = filterBySearchQuery(
        items: items,
        query: 'flutter',
        getTitle: (i) => i.title,
        getDescription: (i) => i.description,
      );
      expect(result.length, 2);
      expect(result[0].title, 'Flutter Guide');
      expect(result[1].title, 'Dart Basics');
    });

    test('works without description accessor (single-tier)', () {
      final result = filterBySearchQuery(
        items: items,
        query: 'flutter',
        getTitle: (i) => i.title,
      );
      expect(result.length, 1);
      expect(result[0].title, 'Flutter Guide');
    });
  });
}

class _Item {
  _Item(this.title, this.description);

  final String title;
  final String? description;
}
