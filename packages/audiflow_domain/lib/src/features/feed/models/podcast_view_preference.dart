import 'package:isar_community/isar.dart';

part 'podcast_view_preference.g.dart';

@collection
class PodcastViewPreference {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int podcastId;

  String viewMode = 'episodes';
  String episodeFilter = 'all';
  String episodeSortOrder = 'desc';
  String seasonSortField = 'seasonNumber';
  String seasonSortOrder = 'desc';
  String? selectedPlaylistId;

  String? autoPlayOrder;
}
