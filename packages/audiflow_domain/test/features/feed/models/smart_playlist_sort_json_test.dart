import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistSortSpec JSON', () {
    test('single-rule round-trip', () {
      const sort = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
        ),
      ]);
      final json = sort.toJson();
      final decoded = SmartPlaylistSortSpec.fromJson(json);

      expect(decoded.rules, hasLength(1));
      expect(decoded.rules[0].field, SmartPlaylistSortField.playlistNumber);
      expect(decoded.rules[0].order, SortOrder.ascending);
    });

    test('multi-rule round-trip', () {
      const sort = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
          condition: SortKeyGreaterThan(0),
        ),
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.newestEpisodeDate,
          order: SortOrder.ascending,
        ),
      ]);
      final json = sort.toJson();
      final decoded = SmartPlaylistSortSpec.fromJson(json);

      expect(decoded.rules, hasLength(2));
      expect(decoded.rules[0].condition, isA<SortKeyGreaterThan>());
      expect((decoded.rules[0].condition! as SortKeyGreaterThan).value, 0);
      expect(decoded.rules[1].condition, isNull);
    });

    test('toJson does not write type discriminator', () {
      const sort = SmartPlaylistSortSpec([
        SmartPlaylistSortRule(
          field: SmartPlaylistSortField.playlistNumber,
          order: SortOrder.ascending,
        ),
      ]);
      final json = sort.toJson();

      expect(json.containsKey('type'), isFalse);
      expect(json.containsKey('rules'), isTrue);
    });

    group('legacy format migration', () {
      test('migrates legacy simple format', () {
        final json = {
          'type': 'simple',
          'field': 'playlistNumber',
          'order': 'ascending',
        };
        final decoded = SmartPlaylistSortSpec.fromJson(json);

        expect(decoded.rules, hasLength(1));
        expect(decoded.rules[0].field, SmartPlaylistSortField.playlistNumber);
        expect(decoded.rules[0].order, SortOrder.ascending);
      });

      test('migrates legacy composite format', () {
        final json = {
          'type': 'composite',
          'rules': [
            {'field': 'newestEpisodeDate', 'order': 'descending'},
            {
              'field': 'playlistNumber',
              'order': 'ascending',
              'condition': {'type': 'sortKeyGreaterThan', 'value': 5},
            },
          ],
        };
        final decoded = SmartPlaylistSortSpec.fromJson(json);

        expect(decoded.rules, hasLength(2));
        expect(
          decoded.rules[0].field,
          SmartPlaylistSortField.newestEpisodeDate,
        );
        expect(decoded.rules[1].condition, isA<SortKeyGreaterThan>());
      });
    });

    test('SmartPlaylistSortCondition.fromJson throws on unknown type', () {
      expect(
        () => SmartPlaylistSortCondition.fromJson({'type': 'unknown'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
