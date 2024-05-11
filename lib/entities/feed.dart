import 'package:audiflow/entities/podcast.dart';

/// This class is used when loading a [Podcast] feed.
///
/// The key information is contained within the [Podcast] instance, but as the
/// iTunes API also returns large and thumbnail artwork within its search
/// results this class also contains properties to represent those.
class Feed {
  Feed({
    required this.podcastUrl,
    this.imageUrl,
    this.thumbnailUrl,
    this.refresh = false,
    this.backgroundFresh = false,
    this.silently = false,
  });

  /// The podcast to load
  final String podcastUrl;

  /// The full-size artwork for the podcast.
  String? imageUrl;

  /// The thumbnail artwork for the podcast,
  String? thumbnailUrl;

  /// If true the podcast is loaded regardless of if it's currently cached.
  bool refresh;

  /// If true, will also perform an additional background refresh.
  bool backgroundFresh;

  /// If true any error can be ignored.
  bool silently;
}
