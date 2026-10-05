/// Reference to an external chapters file from `<podcast:chapters>`.
///
/// The feed only links the file; its content is fetched separately, so
/// parsing a feed never downloads chapter data.
class PodcastChaptersLink {
  const PodcastChaptersLink({required this.url, required this.type});

  /// URL of the chapters file.
  final String url;

  /// MIME type declared by the feed, e.g. `application/json+chapters`.
  final String type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastChaptersLink && url == other.url && type == other.type;

  @override
  int get hashCode => Object.hash(url, type);

  @override
  String toString() => 'PodcastChaptersLink{url: $url, type: $type}';
}
