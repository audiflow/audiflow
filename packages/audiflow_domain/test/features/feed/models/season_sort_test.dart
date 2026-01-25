import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeasonSortField', () {
    test('all enum values exist', () {
      expect(
        SeasonSortField.values,
        containsAll([
          SeasonSortField.seasonNumber,
          SeasonSortField.newestEpisodeDate,
          SeasonSortField.progress,
          SeasonSortField.alphabetical,
        ]),
      );
    });
  });

  group('SortOrder', () {
    test('ascending and descending exist', () {
      expect(
        SortOrder.values,
        containsAll([SortOrder.ascending, SortOrder.descending]),
      );
    });
  });

  group('SeasonSortSpec', () {
    test('simple sort spec holds field and order', () {
      const spec = SimpleSeasonSort(
        SeasonSortField.seasonNumber,
        SortOrder.ascending,
      );

      expect(spec.field, SeasonSortField.seasonNumber);
      expect(spec.order, SortOrder.ascending);
    });

    test('composite sort spec holds multiple rules', () {
      final spec = CompositeSeasonSort([
        SeasonSortRule(
          field: SeasonSortField.seasonNumber,
          order: SortOrder.ascending,
        ),
        SeasonSortRule(
          field: SeasonSortField.newestEpisodeDate,
          order: SortOrder.descending,
        ),
      ]);

      expect(spec.rules.length, 2);
    });

    test('exhaustive switch works on SeasonSortSpec', () {
      const SeasonSortSpec spec = SimpleSeasonSort(
        SeasonSortField.alphabetical,
        SortOrder.ascending,
      );

      final result = switch (spec) {
        SimpleSeasonSort() => 'simple',
        CompositeSeasonSort() => 'composite',
      };

      expect(result, 'simple');
    });
  });
}
