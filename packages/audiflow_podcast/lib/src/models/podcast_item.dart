import 'podcast_chapter.dart';
import 'podcast_entity.dart';
import 'podcast_image.dart';
import 'podcast_transcript.dart';

/// Represents individual podcast episodes with full podcast RSS specification support.
class PodcastItem extends PodcastEntity {
  const PodcastItem({
    required super.parsedAt,
    required super.sourceUrl,
    required this.title,
    required this.description,
    this.publishDate,
    this.duration,
    this.enclosureUrl,
    this.enclosureType,
    this.enclosureLength,
    this.episodeNumber,
    this.seasonNumber,
    this.episodeType,
    this.guid,
    this.subtitle,
    this.summary,
    this.author,
    this.isExplicit,
    this.images = const [],
    this.link,
    this.categories = const [],
    this.comments,
    this.source,
    this.isPermaLink,
    this.contentEncoded,
    this.chapters,
    this.transcripts,
  });

  /// Factory constructor that creates a PodcastItem from a map of parsed data.
  factory PodcastItem.fromMap(Map<String, dynamic> data, String? sourceUrl) {
    // Extract images from various sources
    final images = <PodcastImage>[];

    // Add iTunes image
    final itunesImage = data['itunesImage'] as String?;
    if (itunesImage != null && itunesImage.isNotEmpty) {
      images.add(PodcastImage(url: itunesImage));
    }

    // Extract enclosure information
    final enclosure = data['enclosure'] as Map<String, dynamic>?;
    final enclosureUrl = enclosure?['url'] as String?;
    final enclosureType = enclosure?['type'] as String?;
    final enclosureLength = enclosure?['length'] as int?;

    // Extract categories
    final categories = data['categories'] as List<String>? ?? <String>[];

    return PodcastItem.fromData(
      parsedAt: DateTime.now(),
      sourceUrl: sourceUrl ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      publishDate: data['pubDate'] as DateTime?,
      duration: data['itunesDuration'] as Duration?,
      enclosureUrl: enclosureUrl,
      enclosureType: enclosureType,
      enclosureLength: enclosureLength,
      episodeNumber: data['itunesEpisode'] as int?,
      seasonNumber: data['itunesSeason'] as int?,
      episodeType: data['itunesEpisodeType'] as String?,
      guid: data['guid'] as String?,
      subtitle: data['itunesSubtitle'] as String?,
      summary: data['itunesSummary'] as String?,
      author: data['itunesAuthor'] as String?,
      isExplicit: data['itunesExplicit'] as bool?,
      images: images,
      link: data['link'] as String?,
      categories: categories,
      comments: data['comments'] as String?,
      source: data['source'] as String?,
      isPermaLink: data['isPermaLink'] as bool?,
      contentEncoded: data['contentEncoded'] as String?,
    );
  }

  /// Factory constructor that creates a PodcastItem with validation and default values.
  factory PodcastItem.fromData({
    required DateTime parsedAt,
    required String sourceUrl,
    required String title,
    required String description,
    DateTime? publishDate,
    Duration? duration,
    String? enclosureUrl,
    String? enclosureType,
    int? enclosureLength,
    int? episodeNumber,
    int? seasonNumber,
    String? episodeType,
    String? guid,
    String? subtitle,
    String? summary,
    String? author,
    bool? isExplicit,
    List<PodcastImage>? images,
    String? link,
    List<String>? categories,
    String? comments,
    String? source,
    bool? isPermaLink,
    String? contentEncoded,
    List<PodcastChapter>? chapters,
    List<PodcastTranscript>? transcripts,
  }) {
    // Validate required fields
    if (title.trim().isEmpty) {
      throw ArgumentError('Episode title cannot be empty');
    }
    // Description can be empty in some RSS feeds

    // Validate and normalize episode type
    final normalizedEpisodeType = episodeType?.toLowerCase();
    if (normalizedEpisodeType != null &&
        normalizedEpisodeType != 'full' &&
        normalizedEpisodeType != 'trailer' &&
        normalizedEpisodeType != 'bonus') {
      throw ArgumentError('Episode type must be "full", "trailer", or "bonus"');
    }

    // Validate episode and season numbers
    if (episodeNumber != null && episodeNumber < 0) {
      throw ArgumentError('Episode number must be non-negative');
    }
    if (seasonNumber != null && seasonNumber < 0) {
      throw ArgumentError('Season number must be non-negative');
    }

    // Validate enclosure length
    if (enclosureLength != null && enclosureLength < 0) {
      throw ArgumentError('Enclosure length must be non-negative');
    }

    // Validate URLs (only if not empty after trimming)
    final trimmedEnclosureUrl = enclosureUrl?.trim();
    final trimmedLink = link?.trim();
    final trimmedComments = comments?.trim();

    if (trimmedEnclosureUrl != null &&
        trimmedEnclosureUrl.isNotEmpty &&
        !_isValidUrl(trimmedEnclosureUrl)) {
      throw ArgumentError('Invalid enclosure URL: $trimmedEnclosureUrl');
    }
    if (trimmedLink != null &&
        trimmedLink.isNotEmpty &&
        !_isValidUrl(trimmedLink)) {
      throw ArgumentError('Invalid link URL: $trimmedLink');
    }
    if (trimmedComments != null &&
        trimmedComments.isNotEmpty &&
        !_isValidUrl(trimmedComments)) {
      throw ArgumentError('Invalid comments URL: $trimmedComments');
    }

    // Validate MIME type (only if not empty after trimming)
    final trimmedEnclosureType = enclosureType?.trim();
    if (trimmedEnclosureType != null &&
        trimmedEnclosureType.isNotEmpty &&
        !_isValidMimeType(trimmedEnclosureType)) {
      throw ArgumentError('Invalid MIME type: $trimmedEnclosureType');
    }

    return PodcastItem(
      parsedAt: parsedAt,
      sourceUrl: sourceUrl,
      title: title.trim(),
      description: description.trim(),
      publishDate: publishDate,
      duration: duration,
      enclosureUrl: enclosureUrl?.trim().isEmpty == true
          ? null
          : enclosureUrl?.trim(),
      enclosureType: enclosureType?.trim().isEmpty == true
          ? null
          : enclosureType?.trim(),
      enclosureLength: enclosureLength,
      episodeNumber: episodeNumber,
      seasonNumber: seasonNumber,
      episodeType: normalizedEpisodeType,
      guid: guid?.trim().isEmpty == true ? null : guid?.trim(),
      subtitle: subtitle?.trim().isEmpty == true ? null : subtitle?.trim(),
      summary: summary?.trim().isEmpty == true ? null : summary?.trim(),
      author: author?.trim().isEmpty == true ? null : author?.trim(),
      isExplicit: isExplicit,
      images: images ?? const [],
      link: link?.trim().isEmpty == true ? null : link?.trim(),
      categories: categories ?? const [],
      comments: comments?.trim().isEmpty == true ? null : comments?.trim(),
      source: source?.trim().isEmpty == true ? null : source?.trim(),
      isPermaLink: isPermaLink,
      contentEncoded: contentEncoded?.trim().isEmpty == true
          ? null
          : contentEncoded?.trim(),
      chapters: chapters,
      transcripts: transcripts,
    );
  }

  /// The title of the episode.
  final String title;

  /// The description of the episode.
  final String description;

  /// Publication date of the episode.
  final DateTime? publishDate;

  /// Duration of the episode.
  final Duration? duration;

  /// URL of the episode's media file.
  final String? enclosureUrl;

  /// MIME type of the episode's media file.
  final String? enclosureType;

  /// Size of the episode's media file in bytes.
  final int? enclosureLength;

  /// Episode number.
  final int? episodeNumber;

  /// Season number.
  final int? seasonNumber;

  /// Type of episode (full, trailer, bonus).
  final String? episodeType;

  /// Globally unique identifier for the episode.
  final String? guid;

  /// Short subtitle for the episode.
  final String? subtitle;

  /// Extended summary of the episode.
  final String? summary;

  /// Author of the episode.
  final String? author;

  /// Whether the episode contains explicit content.
  final bool? isExplicit;

  /// List of episode images with different sizes.
  final List<PodcastImage> images;

  /// Episode webpage URL.
  final String? link;

  /// Episode-specific categories.
  final List<String> categories;

  /// Comments URL.
  final String? comments;

  /// Source attribution.
  final String? source;

  /// Whether GUID is a permalink.
  final bool? isPermaLink;

  /// Rich HTML content.
  final String? contentEncoded;

  /// Chapter markers.
  final List<PodcastChapter>? chapters;

  /// Transcript links.
  final List<PodcastTranscript>? transcripts;

  /// Returns the primary image for the episode (largest available).
  PodcastImage? get primaryImage {
    if (images.isEmpty) return null;

    // Find the largest image by width
    PodcastImage? largest;
    var maxWidth = 0;

    for (final image in images) {
      if (image.width != null && maxWidth < image.width!) {
        maxWidth = image.width!;
        largest = image;
      }
    }

    // If no image has width info, return the first one
    return largest ?? images.first;
  }

  /// Returns images filtered by size category.
  List<PodcastImage> getImagesBySize(String sizeCategory) {
    return images.where((image) => image.sizeCategory == sizeCategory).toList();
  }

  /// Returns true if this is a full episode.
  bool get isFullEpisode => episodeType == 'full' || episodeType == null;

  /// Returns true if this is a trailer episode.
  bool get isTrailer => episodeType == 'trailer';

  /// Returns true if this is a bonus episode.
  bool get isBonus => episodeType == 'bonus';

  /// Returns true if the episode has media enclosure.
  bool get hasEnclosure => enclosureUrl != null && enclosureUrl!.isNotEmpty;

  /// Returns true if the episode has chapter markers.
  bool get hasChapters => chapters != null && chapters!.isNotEmpty;

  /// Returns true if the episode has transcripts.
  bool get hasTranscripts => transcripts != null && transcripts!.isNotEmpty;

  /// Returns true if the episode has episode/season numbering.
  bool get hasNumbering => episodeNumber != null || seasonNumber != null;

  /// Returns true if the GUID is a permalink.
  bool get guidIsPermaLink => isPermaLink == true;

  /// Returns the file size in a human-readable format.
  String? get formattedFileSize {
    if (enclosureLength == null) return null;

    final bytes = enclosureLength!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Returns the duration in a human-readable format (HH:MM:SS).
  String? get formattedDuration {
    if (duration == null) return null;

    final totalSeconds = duration!.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (0 < hours) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Returns transcripts filtered by type.
  List<PodcastTranscript> getTranscriptsByType(String type) {
    if (transcripts == null) return [];
    return transcripts!.where((transcript) => transcript.type == type).toList();
  }

  /// Returns transcripts filtered by relationship (captions vs transcript).
  List<PodcastTranscript> getTranscriptsByRel(String rel) {
    if (transcripts == null) return [];
    return transcripts!.where((transcript) => transcript.rel == rel).toList();
  }

  /// Validates the episode data and returns a list of validation errors.
  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Episode title is required');
    }

    if (description.trim().isEmpty) {
      errors.add('Episode description is required');
    }

    if (episodeType != null &&
        episodeType != 'full' &&
        episodeType != 'trailer' &&
        episodeType != 'bonus') {
      errors.add('Episode type must be "full", "trailer", or "bonus"');
    }

    if (episodeNumber != null && episodeNumber! < 0) {
      errors.add('Episode number must be non-negative');
    }

    if (seasonNumber != null && seasonNumber! < 0) {
      errors.add('Season number must be non-negative');
    }

    if (enclosureLength != null && enclosureLength! < 0) {
      errors.add('Enclosure length must be non-negative');
    }

    if (enclosureUrl != null &&
        enclosureUrl!.isNotEmpty &&
        !_isValidUrl(enclosureUrl!)) {
      errors.add('Invalid enclosure URL');
    }

    if (link != null && link!.isNotEmpty && !_isValidUrl(link!)) {
      errors.add('Invalid link URL');
    }

    if (comments != null && comments!.isNotEmpty && !_isValidUrl(comments!)) {
      errors.add('Invalid comments URL');
    }

    if (enclosureType != null &&
        enclosureType!.isNotEmpty &&
        !_isValidMimeType(enclosureType!)) {
      errors.add('Invalid MIME type');
    }

    return errors;
  }

  /// Returns true if the episode data is valid.
  bool get isValid => validate().isEmpty;

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool _isValidMimeType(String mimeType) {
    // Basic MIME type validation (type/subtype)
    final parts = mimeType.split('/');
    return parts.length == 2 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty &&
        !parts[0].contains(' ') &&
        !parts[1].contains(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastItem &&
          runtimeType == other.runtimeType &&
          parsedAt == other.parsedAt &&
          sourceUrl == other.sourceUrl &&
          title == other.title &&
          description == other.description &&
          publishDate == other.publishDate &&
          duration == other.duration &&
          enclosureUrl == other.enclosureUrl &&
          enclosureType == other.enclosureType &&
          enclosureLength == other.enclosureLength &&
          episodeNumber == other.episodeNumber &&
          seasonNumber == other.seasonNumber &&
          episodeType == other.episodeType &&
          guid == other.guid &&
          subtitle == other.subtitle &&
          summary == other.summary &&
          author == other.author &&
          isExplicit == other.isExplicit &&
          _listEquals(images, other.images) &&
          link == other.link &&
          _listEquals(categories, other.categories) &&
          comments == other.comments &&
          source == other.source &&
          isPermaLink == other.isPermaLink &&
          contentEncoded == other.contentEncoded &&
          _listEquals(chapters, other.chapters) &&
          _listEquals(transcripts, other.transcripts);

  @override
  int get hashCode =>
      parsedAt.hashCode ^
      sourceUrl.hashCode ^
      title.hashCode ^
      description.hashCode ^
      publishDate.hashCode ^
      duration.hashCode ^
      enclosureUrl.hashCode ^
      enclosureType.hashCode ^
      enclosureLength.hashCode ^
      episodeNumber.hashCode ^
      seasonNumber.hashCode ^
      episodeType.hashCode ^
      guid.hashCode ^
      subtitle.hashCode ^
      summary.hashCode ^
      author.hashCode ^
      isExplicit.hashCode ^
      images.hashCode ^
      link.hashCode ^
      categories.hashCode ^
      comments.hashCode ^
      source.hashCode ^
      isPermaLink.hashCode ^
      contentEncoded.hashCode ^
      chapters.hashCode ^
      transcripts.hashCode;

  @override
  String toString() {
    return 'PodcastItem{title: $title, episodeNumber: $episodeNumber, seasonNumber: $seasonNumber, duration: $formattedDuration, publishDate: $publishDate}';
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
