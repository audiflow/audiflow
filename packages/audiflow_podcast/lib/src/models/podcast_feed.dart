import 'podcast_entity.dart';
import 'podcast_image.dart';

/// Represents podcast-level metadata and information.
class PodcastFeed extends PodcastEntity {
  /// The title of the podcast.
  final String title;

  /// The description of the podcast.
  final String description;

  /// The author of the podcast.
  final String? author;

  /// List of podcast images with different sizes.
  final List<PodcastImage> images;

  /// The language of the podcast content.
  final String? language;

  /// Categories that the podcast belongs to.
  final List<String> categories;

  /// Whether the podcast contains explicit content.
  final bool isExplicit;

  /// Short subtitle for the podcast.
  final String? subtitle;

  /// Extended summary of the podcast.
  final String? summary;

  /// Name of the podcast owner.
  final String? ownerName;

  /// Email of the podcast owner.
  final String? ownerEmail;

  /// Website URL for the podcast.
  final String? link;

  /// Copyright notice.
  final String? copyright;

  /// Last build date of the feed.
  final DateTime? lastBuildDate;

  /// Publication date of the feed.
  final DateTime? pubDate;

  /// Software that generated the feed.
  final String? generator;

  /// Editorial contact.
  final String? managingEditor;

  /// Technical contact.
  final String? webMaster;

  /// Time to live (cache duration in minutes).
  final int? ttl;

  /// iTunes type (episodic or serial).
  final String? type;

  /// Whether the podcast is complete.
  final bool? isComplete;

  /// New feed URL for migration.
  final String? newFeedUrl;

  const PodcastFeed({
    required super.parsedAt,
    required super.sourceUrl,
    required this.title,
    required this.description,
    this.author,
    this.images = const [],
    this.language,
    this.categories = const [],
    this.isExplicit = false,
    this.subtitle,
    this.summary,
    this.ownerName,
    this.ownerEmail,
    this.link,
    this.copyright,
    this.lastBuildDate,
    this.pubDate,
    this.generator,
    this.managingEditor,
    this.webMaster,
    this.ttl,
    this.type,
    this.isComplete,
    this.newFeedUrl,
  });

  /// Factory constructor that creates a PodcastFeed from a map of parsed data.
  factory PodcastFeed.fromMap(Map<String, dynamic> data, String? sourceUrl) {
    // Extract images from various sources
    final images = <PodcastImage>[];

    // Add RSS image
    final rssImage = data['image'] as Map<String, dynamic>?;
    if (rssImage != null && rssImage['url'] != null) {
      images.add(
        PodcastImage(
          url: rssImage['url'] as String,
          width: rssImage['width'] as int?,
          height: rssImage['height'] as int?,
          title: rssImage['title'] as String?,
          description: rssImage['description'] as String?,
        ),
      );
    }

    // Add iTunes image
    final itunesImage = data['itunesImage'] as String?;
    if (itunesImage != null && itunesImage.isNotEmpty) {
      images.add(PodcastImage(url: itunesImage));
    }

    // Extract owner information
    final owner = data['itunesOwner'] as Map<String, dynamic>?;
    final ownerName = owner?['name'] as String?;
    final ownerEmail = owner?['email'] as String?;

    // Combine categories from different sources
    final categories = <String>[];
    final rssCategories = data['categories'] as List<String>?;
    final itunesCategories = data['itunesCategories'] as List<String>?;

    if (rssCategories != null) categories.addAll(rssCategories);
    if (itunesCategories != null) {
      for (final category in itunesCategories) {
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }

    return PodcastFeed.fromData(
      parsedAt: DateTime.now(),
      sourceUrl: sourceUrl ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      author:
          data['itunesAuthor'] as String? ?? data['managingEditor'] as String?,
      images: images,
      language: data['language'] as String?,
      categories: categories,
      isExplicit: data['itunesExplicit'] as bool? ?? false,
      subtitle: data['itunesSubtitle'] as String?,
      summary: data['itunesSummary'] as String?,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      link: data['link'] as String?,
      copyright: data['copyright'] as String?,
      lastBuildDate: data['lastBuildDate'] as DateTime?,
      pubDate: data['pubDate'] as DateTime?,
      generator: data['generator'] as String?,
      managingEditor: data['managingEditor'] as String?,
      webMaster: data['webMaster'] as String?,
      ttl: data['ttl'] as int?,
      type: data['itunesType'] as String?,
      isComplete: data['itunesComplete'] as bool?,
      newFeedUrl: data['itunesNewFeedUrl'] as String?,
    );
  }

  /// Factory constructor that creates a PodcastFeed with validation and default values.
  factory PodcastFeed.fromData({
    required DateTime parsedAt,
    required String sourceUrl,
    required String title,
    required String description,
    String? author,
    List<PodcastImage>? images,
    String? language,
    List<String>? categories,
    bool? isExplicit,
    String? subtitle,
    String? summary,
    String? ownerName,
    String? ownerEmail,
    String? link,
    String? copyright,
    DateTime? lastBuildDate,
    DateTime? pubDate,
    String? generator,
    String? managingEditor,
    String? webMaster,
    int? ttl,
    String? type,
    bool? isComplete,
    String? newFeedUrl,
  }) {
    // Validate required fields
    if (title.trim().isEmpty) {
      throw ArgumentError('Feed title cannot be empty');
    }
    // Description can be empty in some RSS feeds

    // Validate and normalize optional fields
    final normalizedType = type?.toLowerCase();
    if (normalizedType != null &&
        normalizedType != 'episodic' &&
        normalizedType != 'serial') {
      throw ArgumentError('Feed type must be either "episodic" or "serial"');
    }

    // Validate TTL
    if (ttl != null && ttl < 0) {
      throw ArgumentError('TTL must be non-negative');
    }

    // Validate URLs
    if (link != null && link.isNotEmpty && !_isValidUrl(link)) {
      throw ArgumentError('Invalid link URL: $link');
    }
    if (newFeedUrl != null &&
        newFeedUrl.isNotEmpty &&
        !_isValidUrl(newFeedUrl)) {
      throw ArgumentError('Invalid new feed URL: $newFeedUrl');
    }

    // Validate email
    if (ownerEmail != null &&
        ownerEmail.isNotEmpty &&
        !_isValidEmail(ownerEmail)) {
      throw ArgumentError('Invalid owner email: $ownerEmail');
    }

    return PodcastFeed(
      parsedAt: parsedAt,
      sourceUrl: sourceUrl,
      title: title.trim(),
      description: description.trim(),
      author: author?.trim().isEmpty == true ? null : author?.trim(),
      images: images ?? const [],
      language: language?.trim().isEmpty == true ? null : language?.trim(),
      categories: categories ?? const [],
      isExplicit: isExplicit ?? false,
      subtitle: subtitle?.trim().isEmpty == true ? null : subtitle?.trim(),
      summary: summary?.trim().isEmpty == true ? null : summary?.trim(),
      ownerName: ownerName?.trim().isEmpty == true ? null : ownerName?.trim(),
      ownerEmail:
          ownerEmail?.trim().isEmpty == true ? null : ownerEmail?.trim(),
      link: link?.trim().isEmpty == true ? null : link?.trim(),
      copyright: copyright?.trim().isEmpty == true ? null : copyright?.trim(),
      lastBuildDate: lastBuildDate,
      pubDate: pubDate,
      generator: generator?.trim().isEmpty == true ? null : generator?.trim(),
      managingEditor: managingEditor?.trim().isEmpty == true
          ? null
          : managingEditor?.trim(),
      webMaster: webMaster?.trim().isEmpty == true ? null : webMaster?.trim(),
      ttl: ttl,
      type: normalizedType,
      isComplete: isComplete,
      newFeedUrl:
          newFeedUrl?.trim().isEmpty == true ? null : newFeedUrl?.trim(),
    );
  }

  /// Returns the primary image for the podcast (largest available).
  PodcastImage? get primaryImage {
    if (images.isEmpty) return null;

    // Find the largest image by width
    PodcastImage? largest;
    int maxWidth = 0;

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

  /// Returns true if this is an episodic podcast.
  bool get isEpisodic => type == 'episodic';

  /// Returns true if this is a serial podcast.
  bool get isSerial => type == 'serial';

  /// Returns true if the podcast has owner information.
  bool get hasOwnerInfo => ownerName != null || ownerEmail != null;

  /// Returns true if the podcast has been marked as complete.
  bool get isMarkedComplete => isComplete == true;

  /// Returns the cache duration based on TTL, with a default of 60 minutes.
  Duration get cacheDuration => Duration(minutes: ttl ?? 60);

  /// Validates the feed data and returns a list of validation errors.
  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Feed title is required');
    }

    if (description.trim().isEmpty) {
      errors.add('Feed description is required');
    }

    if (type != null && type != 'episodic' && type != 'serial') {
      errors.add('Feed type must be either "episodic" or "serial"');
    }

    if (ttl != null && ttl! < 0) {
      errors.add('TTL must be non-negative');
    }

    if (link != null && link!.isNotEmpty && !_isValidUrl(link!)) {
      errors.add('Invalid link URL');
    }

    if (newFeedUrl != null &&
        newFeedUrl!.isNotEmpty &&
        !_isValidUrl(newFeedUrl!)) {
      errors.add('Invalid new feed URL');
    }

    if (ownerEmail != null &&
        ownerEmail!.isNotEmpty &&
        !_isValidEmail(ownerEmail!)) {
      errors.add('Invalid owner email');
    }

    return errors;
  }

  /// Returns true if the feed data is valid.
  bool get isValid => validate().isEmpty;

  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PodcastFeed &&
          runtimeType == other.runtimeType &&
          parsedAt == other.parsedAt &&
          sourceUrl == other.sourceUrl &&
          title == other.title &&
          description == other.description &&
          author == other.author &&
          _listEquals(images, other.images) &&
          language == other.language &&
          _listEquals(categories, other.categories) &&
          isExplicit == other.isExplicit &&
          subtitle == other.subtitle &&
          summary == other.summary &&
          ownerName == other.ownerName &&
          ownerEmail == other.ownerEmail &&
          link == other.link &&
          copyright == other.copyright &&
          lastBuildDate == other.lastBuildDate &&
          pubDate == other.pubDate &&
          generator == other.generator &&
          managingEditor == other.managingEditor &&
          webMaster == other.webMaster &&
          ttl == other.ttl &&
          type == other.type &&
          isComplete == other.isComplete &&
          newFeedUrl == other.newFeedUrl;

  @override
  int get hashCode =>
      parsedAt.hashCode ^
      sourceUrl.hashCode ^
      title.hashCode ^
      description.hashCode ^
      author.hashCode ^
      images.hashCode ^
      language.hashCode ^
      categories.hashCode ^
      isExplicit.hashCode ^
      subtitle.hashCode ^
      summary.hashCode ^
      ownerName.hashCode ^
      ownerEmail.hashCode ^
      link.hashCode ^
      copyright.hashCode ^
      lastBuildDate.hashCode ^
      pubDate.hashCode ^
      generator.hashCode ^
      managingEditor.hashCode ^
      webMaster.hashCode ^
      ttl.hashCode ^
      type.hashCode ^
      isComplete.hashCode ^
      newFeedUrl.hashCode;

  @override
  String toString() {
    return 'PodcastFeed{title: $title, description: ${50 < description.length ? '${description.substring(0, 50)}...' : description}, author: $author, language: $language, categories: $categories, isExplicit: $isExplicit}';
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
