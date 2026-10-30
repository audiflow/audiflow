import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_link.freezed.dart';

/// A link the user pasted or typed that points at a podcast, classified by
/// how its RSS feed can be found.
@freezed
sealed class FeedLink with _$FeedLink {
  /// A URL to fetch directly: an RSS feed, or a web page that may announce
  /// one. Always `https`.
  const factory FeedLink.direct({required String url}) = DirectFeedLink;

  /// A podcast app link that carries an Apple Podcasts ID; its feed URL
  /// comes from the iTunes lookup API.
  const factory FeedLink.itunes({required String itunesId}) = ItunesFeedLink;

  /// A podcast app's share page (an Overcast episode, a Castro show or
  /// episode) that names no Apple Podcasts ID in its URL; the show comes
  /// from the "listen on" badges on the page. Always `https`.
  const factory FeedLink.appPage({
    required String url,
    required String platformName,
  }) = AppPageFeedLink;

  /// A link from a service whose links do not lead to an RSS feed.
  const factory FeedLink.unsupported({required String platformName}) =
      UnsupportedFeedLink;
}
