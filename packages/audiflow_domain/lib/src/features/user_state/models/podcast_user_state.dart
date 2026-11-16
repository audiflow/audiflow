import 'package:isar_community/isar.dart';

part 'podcast_user_state.g.dart';

/// What the user chose for one podcast, keyed so every device names it the
/// same way (docs/architecture/user-data-sync.md, "Local storage").
///
/// Replaces `PodcastViewPreference`, `PodcastAudioPreference`, the
/// smart playlist and group play order rows, and `PodcastParentalFlags`,
/// which point at the podcast by local id. The subscription fields join in
/// a later step.
///
/// Each value carries the [Hlc] of its last change (`*Hlc`, packed). Each
/// old row maps to a section whose `has*` flag says whether the row would
/// exist; a deleted row keeps its section with the flag false and a
/// timestamp, so a removal can win a merge.
@collection
class PodcastUserState {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String podcastKey;

  // -- View (PodcastViewPreference) --

  bool hasView = false;
  int hasViewHlc = 0;

  String viewMode = 'episodes';
  int viewModeHlc = 0;

  String episodeFilter = 'all';
  int episodeFilterHlc = 0;

  String episodeSortOrder = 'desc';
  int episodeSortOrderHlc = 0;

  String seasonSortField = 'seasonNumber';
  int seasonSortFieldHlc = 0;

  String seasonSortOrder = 'desc';
  int seasonSortOrderHlc = 0;

  String? selectedPlaylistId;
  int selectedPlaylistIdHlc = 0;

  /// The podcast-level play order, stored with the view as before.
  String? autoPlayOrder;
  int autoPlayOrderHlc = 0;

  // -- Audio override (PodcastAudioPreference) --

  bool hasAudio = false;
  int hasAudioHlc = 0;

  double speed = 1;
  int speedHlc = 0;

  bool? skipSilence;
  int skipSilenceHlc = 0;

  bool? voiceBoost;
  int voiceBoostHlc = 0;

  // -- Parental flags (PodcastParentalFlags) --

  bool hasParental = false;
  int hasParentalHlc = 0;

  bool hideExplicitEpisodes = false;
  int hideExplicitEpisodesHlc = 0;

  // -- Play order per smart playlist and group --

  /// One entry per playlist or group whose play order was ever set. A
  /// cleared order stays as an entry with a null [PlayOrderEntry.order].
  List<PlayOrderEntry> playOrders = [];
}

/// The play order of one smart playlist, or of one group in it.
@embedded
class PlayOrderEntry {
  String playlistId = '';

  /// Null for the playlist itself.
  String? groupId;

  /// The order, or null once cleared.
  String? order;

  int hlc = 0;
}
