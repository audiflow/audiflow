import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/feed_parse_progress.dart';

/// The subscription fields an RSS channel can supply.
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
/// fills them in. The channel element supplies all three.
///
/// Author and description follow the feed: a non-empty channel value replaces
/// the stored one, so a show that renames itself stays current. Artwork is
/// only ever filled in when missing — the channel image is 1400-3000 px per
/// Apple's spec while a search-sourced `artworkUrl` is 600 px, and artwork is
/// decoded at its intrinsic size, so replacing a stored URL would multiply
/// decoded image memory across the whole library.
///
/// A blank channel value is never written, so a sparse feed cannot erase
/// metadata that a podcast search already supplied.
class SubscriptionMetadataUpdater {
  const SubscriptionMetadataUpdater(this._repository);

  final SubscriptionRepository _repository;

  /// Applies the channel metadata carried by a parse-progress event.
  Future<void> applyFeedMeta(Subscription sub, FeedMetaReady meta) {
    return apply(
      sub,
      imageUrl: meta.imageUrl,
      author: meta.author,
      description: meta.description,
    );
  }

  /// Writes the channel values that differ from what [sub] already stores.
  Future<void> apply(
    Subscription sub, {
    String? imageUrl,
    String? author,
    String? description,
  }) async {
    final update = diff(
      sub,
      imageUrl: imageUrl,
      author: author,
      description: description,
    );
    if (update.isEmpty) return;

    await _repository.updateFeedMetadata(
      sub.id,
      artworkUrl: update.artworkUrl,
      artistName: update.artistName,
      description: update.description,
    );
  }

  /// Computes which fields the channel would change on [sub].
  static SubscriptionMetadataUpdate diff(
    Subscription sub, {
    String? imageUrl,
    String? author,
    String? description,
  }) {
    return SubscriptionMetadataUpdate(
      artworkUrl: _isBlank(sub.artworkUrl)
          ? _changedValue(imageUrl, sub.artworkUrl)
          : null,
      artistName: _changedValue(author, sub.artistName),
      description: _changedValue(description, sub.description),
    );
  }

  /// Whether [sub] is still missing artwork that only its feed can supply.
  ///
  /// Such a subscription has to parse its feed to get one, so callers skip
  /// conditional request headers for it: a 304 skips the parse, which would
  /// leave an OPML-imported podcast blank forever on a show that never
  /// publishes again.
  static bool needsArtworkBackfill(Subscription sub) =>
      _isBlank(sub.artworkUrl);

  /// Returns the trimmed [feedValue] when it carries new information, or
  /// null when it is blank or already equal to [storedValue].
  static String? _changedValue(String? feedValue, String? storedValue) {
    final trimmed = feedValue?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed == storedValue?.trim()) return null;
    return trimmed;
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;
}
