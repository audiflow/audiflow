/// Playback state filter for a station (exclusive selection).
enum StationPlaybackState {
  all,
  unplayed,
  inProgress;

  static StationPlaybackState fromString(String value) => switch (value) {
    'unplayed' => StationPlaybackState.unplayed,
    'inProgress' => StationPlaybackState.inProgress,
    _ => StationPlaybackState.all,
  };
}
