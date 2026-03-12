import 'package:audiflow_app/features/podcast_detail/presentation/utils/group_sorting.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortField,
        SmartPlaylistSortRule,
        SortOrder;
import 'package:flutter_test/flutter_test.dart';

SmartPlaylistGroup _group({
  required String id,
  required int sortKey,
  String? displayName,
  DateTime? latestDate,
}) {
  return SmartPlaylistGroup(
    id: id,
    displayName: displayName ?? id,
    sortKey: sortKey,
    episodeIds: const [],
    latestDate: latestDate,
  );
}

void main() {
  group('sortGroupsBySort', () {
    group('null groupSort falls back to sortKey', () {
      final groups = [
        _group(id: 'b', sortKey: 2),
        _group(id: 'a', sortKey: 1),
        _group(id: 'c', sortKey: 3),
      ];

      test('ascending by sortKey when groupSort is null', () {
        final result = sortGroupsBySort(groups, null, SortOrder.ascending);
        expect(result.map((g) => g.id), ['a', 'b', 'c']);
      });

      test('descending by sortKey when groupSort is null', () {
        final result = sortGroupsBySort(groups, null, SortOrder.descending);
        expect(result.map((g) => g.id), ['c', 'b', 'a']);
      });
    });

    group('single rule', () {
      test('sorts by newestEpisodeDate ascending', () {
        final groups = [
          _group(id: 'new', sortKey: 1, latestDate: DateTime(2024, 6)),
          _group(id: 'old', sortKey: 2, latestDate: DateTime(2024, 1)),
        ];
        final rule = SmartPlaylistSortRule(
          field: SmartPlaylistSortField.newestEpisodeDate,
          order: SortOrder.ascending,
        );

        final result = sortGroupsBySort(groups, rule, SortOrder.ascending);
        expect(result.map((g) => g.id), ['old', 'new']);
      });

      test('sorts alphabetically descending', () {
        final groups = [
          _group(id: 'alpha', sortKey: 1, displayName: 'Alpha'),
          _group(id: 'charlie', sortKey: 2, displayName: 'Charlie'),
          _group(id: 'bravo', sortKey: 3, displayName: 'Bravo'),
        ];
        final rule = SmartPlaylistSortRule(
          field: SmartPlaylistSortField.alphabetical,
          order: SortOrder.descending,
        );

        final result = sortGroupsBySort(groups, rule, SortOrder.descending);
        expect(result.map((g) => g.id), ['charlie', 'bravo', 'alpha']);
      });
    });

    group('inversion when UI sortOrder differs from rule', () {
      final groups = [
        _group(id: 'a', sortKey: 1),
        _group(id: 'b', sortKey: 2),
        _group(id: 'c', sortKey: 3),
      ];
      final rule = SmartPlaylistSortRule(
        field: SmartPlaylistSortField.playlistNumber,
        order: SortOrder.ascending,
      );

      test('no inversion when sortOrder matches rule', () {
        final result = sortGroupsBySort(groups, rule, SortOrder.ascending);
        expect(result.map((g) => g.id), ['a', 'b', 'c']);
      });

      test('inverted when sortOrder differs from rule', () {
        final result = sortGroupsBySort(groups, rule, SortOrder.descending);
        expect(result.map((g) => g.id), ['c', 'b', 'a']);
      });
    });
  });

  group('compareNullableDates', () {
    test('both null returns 0', () {
      expect(compareNullableDates(null, null), 0);
    });

    test('first null sorts after', () {
      expect(0 < compareNullableDates(null, DateTime(2024)), isTrue);
    });

    test('second null sorts after', () {
      expect(compareNullableDates(DateTime(2024), null) < 0, isTrue);
    });

    test('earlier date before later date', () {
      expect(
        compareNullableDates(DateTime(2024, 1), DateTime(2024, 6)) < 0,
        isTrue,
      );
    });

    test('same dates return 0', () {
      final d = DateTime(2024, 3, 15);
      expect(compareNullableDates(d, d), 0);
    });
  });
}
