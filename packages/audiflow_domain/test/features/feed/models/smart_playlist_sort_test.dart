import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistSortField', () {
    test('all enum values exist', () {
      expect(
        SmartPlaylistSortField.values,
        containsAll([
          SmartPlaylistSortField.playlistNumber,
          SmartPlaylistSortField.newestEpisodeDate,
          SmartPlaylistSortField.progress,
          SmartPlaylistSortField.alphabetical,
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

  group('SmartPlaylistSortSpec', () {
    test('single-rule spec holds one rule', () {
      const spec = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
        ),
      ]);

      expect(spec.rules, hasLength(1));
      expect(spec.rules[0].field, SmartPlaylistSortField.playlistNumber);
      expect(spec.rules[0].order, SortOrder.ascending);
    });

    test('multi-rule spec holds multiple rules', () {
      const spec = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
        ),
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.newestEpisodeDate,
          order: SortOrder.descending,
        ),
      ]);

      expect(spec.rules, hasLength(2));
    });

    test('rules list is accessible', () {
      const spec = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.alphabetical,
          order: SortOrder.ascending,
        ),
      ]);

      expect(spec.rules[0].field, SmartPlaylistSortField.alphabetical);
      expect(spec.rules[0].order, SortOrder.ascending);
    });
  });
}
