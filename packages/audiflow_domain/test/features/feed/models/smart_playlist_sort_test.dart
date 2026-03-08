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
}
