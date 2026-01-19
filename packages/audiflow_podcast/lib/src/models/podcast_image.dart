/// Represents podcast artwork with size information and convenience methods.
class PodcastImage {
  const PodcastImage({
    required this.url,
    this.width,
    this.height,
    this.title,
    this.description,
  });
  final String url;
  final int? width;
  final int? height;
  final String? title;
  final String? description;

  bool get isSmall => width != null && width! <= 300;
  bool get isMedium => width != null && 300 < width! && width! <= 600;
  bool get isLarge => width != null && 600 < width!;

  String get sizeCategory {
    if (isSmall) return 'small';
    if (isMedium) return 'medium';
    if (isLarge) return 'large';
    return 'unknown';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode =>
      url.hashCode ^
      width.hashCode ^
      height.hashCode ^
      title.hashCode ^
      description.hashCode;

  @override
  String toString() {
    return 'PodcastImage{url: $url, width: $width, height: $height, title: $title, description: $description}';
  }
}
