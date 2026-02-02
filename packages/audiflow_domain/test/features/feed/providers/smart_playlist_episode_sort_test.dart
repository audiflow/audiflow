import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Episode _episode({required int id, DateTime? publishedAt}) => Episode(
  id: id,
  podcastId: 1,
  guid: 'guid-$id',
  title: 'Episode $id',
  audioUrl: 'https://example.com/$id.mp3',
  publishedAt: publishedAt,
);

SmartPlaylistEpisodeData _data({required int id, DateTime? publishedAt}) =>
    SmartPlaylistEpisodeData(
      episode: _episode(id: id, publishedAt: publishedAt),
    );

void main() {
  group('sortEpisodeDataByPublishDate', () {
    test('sorts episodes oldest first', () {
      final data = [
        _data(id: 1, publishedAt: DateTime(2025, 3, 1)),
        _data(id: 2, publishedAt: DateTime(2025, 1, 1)),
        _data(id: 3, publishedAt: DateTime(2025, 2, 1)),
      ];

      sortEpisodeDataByPublishDate(data);

      expect(data[0].episode.id, 2);
      expect(data[1].episode.id, 3);
      expect(data[2].episode.id, 1);
    });

    test('episodes with dates sort before null dates', () {
      final data = [
        _data(id: 1, publishedAt: null),
        _data(id: 2, publishedAt: DateTime(2025, 1, 1)),
        _data(id: 3, publishedAt: null),
      ];

      sortEpisodeDataByPublishDate(data);

      expect(data[0].episode.id, 2);
      expect(data[1].episode.id, 1);
      expect(data[2].episode.id, 3);
    });

    test('all null dates preserves relative order', () {
      final data = [_data(id: 1), _data(id: 2), _data(id: 3)];

      sortEpisodeDataByPublishDate(data);

      expect(data[0].episode.id, 1);
      expect(data[1].episode.id, 2);
      expect(data[2].episode.id, 3);
    });

    test('empty list does not throw', () {
      final data = <SmartPlaylistEpisodeData>[];
      sortEpisodeDataByPublishDate(data);
      expect(data, isEmpty);
    });

    test('single element list unchanged', () {
      final data = [_data(id: 1, publishedAt: DateTime(2025, 1, 1))];
      sortEpisodeDataByPublishDate(data);
      expect(data[0].episode.id, 1);
    });

    test('reversed list produces correct newest-first order', () {
      final data = [
        _data(id: 1, publishedAt: DateTime(2025, 1, 1)),
        _data(id: 2, publishedAt: DateTime(2025, 2, 1)),
        _data(id: 3, publishedAt: DateTime(2025, 3, 1)),
      ];

      sortEpisodeDataByPublishDate(data);
      final newestFirst = data.reversed.toList();

      expect(newestFirst[0].episode.id, 3);
      expect(newestFirst[1].episode.id, 2);
      expect(newestFirst[2].episode.id, 1);
    });
  });
}
