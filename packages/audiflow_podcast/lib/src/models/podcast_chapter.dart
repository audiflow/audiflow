/// Represents chapter markers within podcast episodes.
class PodcastChapter {
  const PodcastChapter({
    required this.title,
    required this.startTime,
    this.endTime,
    this.url,
    this.imageUrl,
  });
  final String title;
  final Duration startTime;
  final Duration? endTime;
  final String? url;
  final String? imageUrl;

  Duration? get duration {
    if (endTime != null) {
      return endTime! - startTime;
    }
    return null;
  }

  bool get hasEndTime => endTime != null;
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastChapter &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          url == other.url &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      title.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      url.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() {
    return 'PodcastChapter{title: $title, startTime: $startTime, endTime: $endTime, url: $url, imageUrl: $imageUrl}';
  }
}
