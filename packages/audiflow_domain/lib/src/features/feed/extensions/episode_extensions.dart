import 'package:audiflow_core/audiflow_core.dart';

import '../models/episode.dart';

/// Extension to convert [Episode] to [EpisodeData] interface.
extension EpisodeToEpisodeData on Episode {
  /// Converts this Episode to an EpisodeData for use with pattern extractors.
  EpisodeData toEpisodeData() {
    return SimpleEpisodeData(
      title: title,
      description: description,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );
  }
}
