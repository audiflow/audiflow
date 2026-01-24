import 'package:audiflow_search/audiflow_search.dart';

import '../../../common/database/app_database.dart';

/// Extension methods for [Subscription] model.
extension SubscriptionToPodcast on Subscription {
  /// Converts this subscription to a [Podcast] model.
  ///
  /// Useful for navigating to the podcast detail screen,
  /// which expects a [Podcast] object.
  Podcast toPodcast() {
    return Podcast(
      id: itunesId,
      name: title,
      artistName: artistName,
      feedUrl: feedUrl,
      artworkUrl: artworkUrl,
      description: description,
      genres: genres.isNotEmpty ? genres.split(',') : const <String>[],
      explicit: explicit,
    );
  }
}
