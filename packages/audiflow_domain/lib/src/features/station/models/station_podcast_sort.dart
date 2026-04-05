/// Sort order for podcasts within a station's podcast list.
///
/// Also determines section ordering when [Station.groupByPodcast] is enabled.
enum StationPodcastSort {
  subscribeAsc('subscribe_asc'),
  subscribeDesc('subscribe_desc'),
  nameAsc('name_asc'),
  nameDesc('name_desc'),
  manual('manual');

  const StationPodcastSort(this.storedValue);

  /// The string persisted in Isar.
  final String storedValue;

  static StationPodcastSort fromString(String value) => switch (value) {
    'subscribe_asc' => StationPodcastSort.subscribeAsc,
    'subscribe_desc' => StationPodcastSort.subscribeDesc,
    'name_asc' => StationPodcastSort.nameAsc,
    'name_desc' => StationPodcastSort.nameDesc,
    'manual' => StationPodcastSort.manual,
    _ => StationPodcastSort.manual,
  };
}
