/// Sort order for episodes within a station.
enum StationEpisodeSort {
  newest,
  oldest;

  static StationEpisodeSort fromString(String value) => switch (value) {
    'oldest' => StationEpisodeSort.oldest,
    _ => StationEpisodeSort.newest,
  };
}
