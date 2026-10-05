import '../../feed/models/episode.dart';

/// The `<podcast:chapters>` JSON file an episode links, if any.
extension EpisodeJsonChaptersLink on Episode {
  /// The chapters URL when it points at a JSON chapters file, else null.
  String? get jsonChaptersUrl {
    final type = chaptersType;
    // Feeds declare `application/json+chapters`, but some use plain
    // `application/json` for the same file.
    if (type == null || !type.toLowerCase().contains('json')) return null;
    return chaptersUrl;
  }
}
