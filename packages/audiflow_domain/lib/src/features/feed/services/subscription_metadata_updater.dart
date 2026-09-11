import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/feed_parse_progress.dart';

/// The subscription fields an RSS channel is authoritative for.
///
/// A null field means the channel carries nothing new for it, so the stored
/// value must be left alone.
class SubscriptionMetadataUpdate {
  const SubscriptionMetadataUpdate({
    this.artworkUrl,
    this.artistName,
    this.description,
  });

  final String? artworkUrl;
  final String? artistName;
  final String? description;

  /// Whether the channel changes nothing, making a write unnecessary.
  bool get isEmpty =>
      artworkUrl == null && artistName == null && description == null;
}

/// Persists podcast metadata parsed from the RSS channel onto a subscription.
///
/// OPML carries only a title and a feed URL, so imported subscriptions start
/// with no artwork, no author, and no description, and nothing else ever
/// fills them in. The channel element supplies all three on every refresh.
///
/// The feed is treated as the source of truth: a non-empty channel value
/// replaces whatever is stored, which also keeps search-originated
/// subscriptions current when a show rebrands. A blank channel value is
/// ignored rather than written, so a sparse feed never erases metadata that
/// came from search.
class SubscriptionMetadataUpdater {
  const SubscriptionMetadataUpdater(this._repository);

  final SubscriptionRepository _repository;

  /// Writes the fields of [meta] that differ from what [sub] already stores.
  Future<void> applyFeedMeta(Subscription sub, FeedMetaReady meta) async {
    final update = diff(sub, meta);
    if (update.isEmpty) return;

    await _repository.updateFeedMetadata(
      sub.id,
      artworkUrl: update.artworkUrl,
      artistName: update.artistName,
      description: update.description,
    );
  }

  /// Computes which fields [meta] would change on [sub].
  static SubscriptionMetadataUpdate diff(Subscription sub, FeedMetaReady meta) {
    return SubscriptionMetadataUpdate(
      artworkUrl: _changedValue(meta.imageUrl, sub.artworkUrl),
      artistName: _changedValue(meta.author, sub.artistName),
      description: _changedValue(meta.description, sub.description),
    );
  }

  /// Returns the trimmed [feedValue] when it carries new information, or
  /// null when it is blank or already equal to [storedValue].
  static String? _changedValue(String? feedValue, String? storedValue) {
    final trimmed = feedValue?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed == storedValue?.trim()) return null;
    return trimmed;
  }
}
