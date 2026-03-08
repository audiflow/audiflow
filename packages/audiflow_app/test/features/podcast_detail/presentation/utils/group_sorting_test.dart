import 'package:audiflow_app/features/podcast_detail/presentation/utils/group_sorting.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        SmartPlaylistGroup,
        SmartPlaylistSortField,
        SmartPlaylistSortRule,
        SmartPlaylistSortSpec,
        SortKeyGreaterThan,
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
  group('sortGroupsByCustomSort', () {
    group('null/empty customSort falls back to sortKey', () {
      final groups = [
        _group(id: 'b', sortKey: 2),
        _group(id: 'a', sortKey: 1),
        _group(id: 'c', sortKey: 3),
      ];

      test('ascending by sortKey when customSort is null', () {
        final result = sortGroupsByCustomSort(
          groups,
          null,
          SortOrder.ascending,
        );
        expect(result.map((g) => g.id), ['a', 'b', 'c']);
      });

      test('descending by sortKey when customSort is null', () {
        final result = sortGroupsByCustomSort(
          groups,
          null,
          SortOrder.descending,
        );
        expect(result.map((g) => g.id), ['c', 'b', 'a']);
      });

      test('ascending by sortKey when customSort has empty rules', () {
        final result = sortGroupsByCustomSort(
          groups,
          const SmartPlaylistSortSpec([]),
          SortOrder.ascending,
        );
        expect(result.map((g) => g.id), ['a', 'b', 'c']);
      });
    });

    group('single rule without condition', () {
      test('sorts by newestEpisodeDate ascending', () {
        final groups = [
          _group(id: 'new', sortKey: 1, latestDate: DateTime(2024, 6)),
          _group(id: 'old', sortKey: 2, latestDate: DateTime(2024, 1)),
        ];
        final spec = SmartPlaylistSortSpec([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.newestEpisodeDate,
            order: SortOrder.ascending,
          ),
        ]);

        final result = sortGroupsByCustomSort(
          groups,
          spec,
          SortOrder.ascending,
        );
        expect(result.map((g) => g.id), ['old', 'new']);
      });

      test('sorts alphabetically descending', () {
        final groups = [
          _group(id: 'alpha', sortKey: 1, displayName: 'Alpha'),
          _group(id: 'charlie', sortKey: 2, displayName: 'Charlie'),
          _group(id: 'bravo', sortKey: 3, displayName: 'Bravo'),
        ];
        final spec = SmartPlaylistSortSpec([
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.alphabetical,
            order: SortOrder.descending,
          ),
        ]);

        final result = sortGroupsByCustomSort(
          groups,
          spec,
          SortOrder.descending,
        );
        expect(result.map((g) => g.id), ['charlie', 'bravo', 'alpha']);
      });
    });

    group('inversion when UI sortOrder differs from first rule', () {
      final groups = [
        _group(id: 'a', sortKey: 1),
        _group(id: 'b', sortKey: 2),
        _group(id: 'c', sortKey: 3),
      ];
      final spec = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
        ),
      ]);

      test('no inversion when sortOrder matches first rule', () {
        final result = sortGroupsByCustomSort(
          groups,
          spec,
          SortOrder.ascending,
        );
        expect(result.map((g) => g.id), ['a', 'b', 'c']);
      });

      test('inverted when sortOrder differs from first rule', () {
        final result = sortGroupsByCustomSort(
          groups,
          spec,
          SortOrder.descending,
        );
        expect(result.map((g) => g.id), ['c', 'b', 'a']);
      });
    });

    group('conditional SortKeyGreaterThan rule', () {
      test('applies rule only when both groups match condition', () {
        final groups = [
          _group(id: 'low', sortKey: 1, displayName: 'Zebra'),
          _group(id: 'mid', sortKey: 5, displayName: 'Mid'),
          _group(id: 'high', sortKey: 10, displayName: 'Alpha'),
        ];
        final spec = SmartPlaylistSortSpec([
          // Only sort alphabetically when sortKey > 3
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.alphabetical,
            order: SortOrder.ascending,
            condition: const SortKeyGreaterThan(3),
          ),
          // Fallback: sort by playlistNumber
          SmartPlaylistSortRule(
            field: SmartPlaylistSortField.playlistNumber,
            order: SortOrder.ascending,
          ),
        ]);

        final result = sortGroupsByCustomSort(
          groups,
          spec,
          SortOrder.ascending,
        );
        // 'low' (sortKey=1) doesn't match condition, so conditional
        // rule is skipped when comparing with others. Fallback sorts
        // by playlistNumber: low(1), mid(5), high(10).
        // Between mid and high (both match), alphabetical applies:
        // Alpha(high) < Mid(mid), so high before mid.
        expect(result.map((g) => g.id), ['low', 'high', 'mid']);
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

  group('matchesGroupCondition', () {
    test('returns true when sortKey is greater than condition value', () {
      final g = _group(id: 'x', sortKey: 10);
      expect(matchesGroupCondition(g, const SortKeyGreaterThan(5)), isTrue);
    });

    test('returns false when sortKey equals condition value', () {
      final g = _group(id: 'x', sortKey: 5);
      expect(matchesGroupCondition(g, const SortKeyGreaterThan(5)), isFalse);
    });

    test('returns false when sortKey is less than condition value', () {
      final g = _group(id: 'x', sortKey: 3);
      expect(matchesGroupCondition(g, const SortKeyGreaterThan(5)), isFalse);
    });
  });
}
