import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartPlaylistSortRule JSON', () {
    test('round-trip', () {
      const rule = SmartPlaylistSortRule(
        field: SmartPlaylistSortField.playlistNumber,
        order: SortOrder.ascending,
      );
      final json = rule.toJson();
      final decoded = SmartPlaylistSortRule.fromJson(json);

      expect(decoded.field, SmartPlaylistSortField.playlistNumber);
      expect(decoded.order, SortOrder.ascending);
    });

    test('toJson produces correct keys', () {
      const rule = SmartPlaylistSortRule(
        field: SmartPlaylistSortField.newestEpisodeDate,
        order: SortOrder.descending,
      );
      final json = rule.toJson();

      expect(json['field'], 'newestEpisodeDate');
      expect(json['order'], 'descending');
    });

    test('all sort fields round-trip', () {
      for (final field in SmartPlaylistSortField.values) {
        final rule = SmartPlaylistSortRule(
          field: field,
          order: SortOrder.ascending,
        );
        final decoded = SmartPlaylistSortRule.fromJson(rule.toJson());
        expect(decoded.field, field);
      }
    });
  });
}
