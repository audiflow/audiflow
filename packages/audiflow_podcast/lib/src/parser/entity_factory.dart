import 'dart:async';

import '../errors/podcast_parse_error.dart';
import '../models/podcast_chapter.dart';
import '../models/podcast_feed.dart';
import '../models/podcast_image.dart';
import '../models/podcast_item.dart';
import '../models/podcast_transcript.dart';

/// Factory class responsible for creating Feed and Item entities from parsed XML data.
/// Handles RSS 2.0 standard elements and iTunes namespace extensions.
///
/// Supports partial parsing by continuing when individual elements fail and
/// emitting warnings for recoverable issues.
class EntityFactory {
  /// Stream controller for emitting warnings during parsing.
  final StreamController<PodcastParseWarning> _warningController =
      StreamController<PodcastParseWarning>.broadcast();

  /// Stream of parsing warnings for recoverable issues.
  Stream<PodcastParseWarning> get warnings => _warningController.stream;

  /// Creates a PodcastFeed entity from accumulated RSS metadata.
  ///
  /// Handles missing required fields with sensible defaults and validates
  /// the data before creating the entity. Uses partial parsing to continue
  /// when individual elements fail.
  ///
  /// Returns null only if the feed data is completely unusable.
  PodcastFeed? createFeed(Map<String, dynamic> feedData, String? sourceUrl) {
    try {
      // Validate minimum required data
      if (!_hasMinimumFeedData(feedData)) {
        return null;
      }

      // Extract and process images from various sources with error handling
      final images = _extractFeedImagesWithErrorHandling(feedData, sourceUrl);

      // Extract owner information with error handling
      final ownerInfo = _extractOwnerInfoWithErrorHandling(feedData, sourceUrl);
      final ownerName = ownerInfo['name'] as String?;
      final ownerEmail = ownerInfo['email'] as String?;

      // Combine categories from different sources with error handling
      final categories = _extractFeedCategoriesWithErrorHandling(
        feedData,
        sourceUrl,
      );

      // Parse dates with error handling
      final lastBuildDate = _parseDateWithErrorHandling(
        feedData['lastBuildDate'],
        'lastBuildDate',
        sourceUrl,
      );
      final pubDate = _parseDateWithErrorHandling(
        feedData['pubDate'],
        'pubDate',
        sourceUrl,
      );

      // Parse TTL with validation and error handling
      final ttl = _parsePositiveIntWithErrorHandling(
        feedData['ttl'],
        'ttl',
        sourceUrl,
      );

      // Validate and normalize iTunes type with error handling
      final itunesType = _normalizeItunesTypeWithErrorHandling(
        feedData['itunesType'] as String?,
        sourceUrl,
      );

      return PodcastFeed.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: sourceUrl ?? '',
        title: _extractRequiredString(feedData, 'title', 'Untitled Podcast'),
        description: _extractRequiredString(
          feedData,
          'description',
          'No description available',
        ),
        author:
            _extractOptionalString(feedData, 'itunesAuthor') ??
            _extractOptionalString(feedData, 'managingEditor'),
        images: images,
        language: _extractOptionalString(feedData, 'language'),
        categories: categories,
        isExplicit: _parseBoolean(feedData['itunesExplicit']),
        subtitle: _extractOptionalString(feedData, 'itunesSubtitle'),
        summary: _extractOptionalString(feedData, 'itunesSummary'),
        ownerName: ownerName?.trim().isEmpty == true ? null : ownerName?.trim(),
        ownerEmail: ownerEmail?.trim().isEmpty == true
            ? null
            : ownerEmail?.trim(),
        link: _extractOptionalString(feedData, 'link'),
        copyright: _extractOptionalString(feedData, 'copyright'),
        lastBuildDate: lastBuildDate,
        pubDate: pubDate,
        generator: _extractOptionalString(feedData, 'generator'),
        managingEditor: _extractOptionalString(feedData, 'managingEditor'),
        webMaster: _extractOptionalString(feedData, 'webMaster'),
        ttl: ttl,
        type: itunesType,
        isComplete: _parseBoolean(feedData['itunesComplete']),
        newFeedUrl: _extractOptionalString(feedData, 'itunesNewFeedUrl'),
      );
    } catch (e) {
      // Emit error for feed creation failure but continue processing
      _emitWarning(
        'Failed to create feed entity: $e',
        sourceUrl,
        entityType: 'Feed',
      );
      return null;
    }
  }

  /// Creates a PodcastItem entity from episode XML elements.
  ///
  /// Handles enclosure parsing, media metadata extraction, and iTunes-specific
  /// fields like episode numbers and seasons. Uses partial parsing to continue
  /// when individual elements fail.
  ///
  /// Returns null only if the item data is completely unusable.
  PodcastItem? createItem(Map<String, dynamic> itemData, String? sourceUrl) {
    try {
      // Validate minimum required data
      if (!_hasMinimumItemData(itemData)) {
        return null;
      }

      // Extract and process images with error handling
      final images = _extractItemImagesWithErrorHandling(itemData, sourceUrl);

      // Extract enclosure information with error handling
      final enclosure = _extractEnclosureWithErrorHandling(itemData, sourceUrl);

      // Extract categories with error handling
      final categories = _extractItemCategoriesWithErrorHandling(
        itemData,
        sourceUrl,
      );

      // Parse dates with error handling
      final publishDate = _parseDateWithErrorHandling(
        itemData['pubDate'],
        'pubDate',
        sourceUrl,
      );

      // Parse duration with error handling
      final duration = _parseDurationWithErrorHandling(
        itemData['itunesDuration'],
        sourceUrl,
      );

      // Parse episode and season numbers with validation and error handling
      final episodeNumber = _parsePositiveIntWithErrorHandling(
        itemData['itunesEpisode'],
        'itunesEpisode',
        sourceUrl,
      );
      final seasonNumber = _parsePositiveIntWithErrorHandling(
        itemData['itunesSeason'],
        'itunesSeason',
        sourceUrl,
      );

      // Validate and normalize episode type with error handling
      final episodeType = _normalizeEpisodeTypeWithErrorHandling(
        itemData['itunesEpisodeType'] as String?,
        sourceUrl,
      );

      // Parse GUID permalink flag
      final isPermaLink = itemData['isPermaLink'] as bool?;

      // Extract chapters and transcripts (placeholder for future implementation)
      final chapters = _extractChapters(itemData);
      final transcripts = _extractTranscripts(itemData);

      return PodcastItem.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: sourceUrl ?? '',
        title: _extractRequiredString(itemData, 'title', 'Untitled Episode'),
        description: _extractRequiredString(
          itemData,
          'description',
          'No description available',
        ),
        publishDate: publishDate,
        duration: duration,
        enclosureUrl: enclosure?['url'] as String?,
        enclosureType: enclosure?['type'] as String?,
        enclosureLength: enclosure?['length'] as int?,
        episodeNumber: episodeNumber,
        seasonNumber: seasonNumber,
        episodeType: episodeType,
        guid: _extractOptionalString(itemData, 'guid'),
        subtitle: _extractOptionalString(itemData, 'itunesSubtitle'),
        summary: _extractOptionalString(itemData, 'itunesSummary'),
        author: _extractOptionalString(itemData, 'itunesAuthor'),
        isExplicit: itemData['itunesExplicit'] != null
            ? _parseBoolean(itemData['itunesExplicit'])
            : null,
        images: images,
        link: _extractOptionalString(itemData, 'link'),
        categories: categories,
        comments: _extractOptionalString(itemData, 'comments'),
        source: _extractOptionalString(itemData, 'source'),
        isPermaLink: isPermaLink,
        contentEncoded: _extractOptionalString(itemData, 'contentEncoded'),
        chapters: chapters,
        transcripts: transcripts,
      );
    } catch (e) {
      // Emit warning for item creation failure but continue processing
      _emitWarning(
        'Failed to create item entity: $e',
        sourceUrl,
        entityType: 'Item',
      );
      return null;
    }
  }

  /// Checks if feed data contains minimum required information.
  bool _hasMinimumFeedData(Map<String, dynamic> feedData) {
    // We can always create a feed with defaults, so return true
    // The factory methods will provide sensible defaults for missing data
    return true;
  }

  /// Checks if item data contains minimum required information.
  bool _hasMinimumItemData(Map<String, dynamic> itemData) {
    // We can always create an item with defaults, so return true
    // The factory methods will provide sensible defaults for missing data
    return true;
  }

  /// Extracts images from feed data, handling both RSS and iTunes sources.
  List<PodcastImage> _extractFeedImages(Map<String, dynamic> feedData) {
    final images = <PodcastImage>[];

    // Add RSS image
    final rssImage = feedData['image'] as Map<String, dynamic>?;
    if (rssImage != null && rssImage['url'] != null) {
      final url = rssImage['url'] as String;
      if (url.trim().isNotEmpty && _isValidUrl(url)) {
        images.add(
          PodcastImage(
            url: url.trim(),
            width: rssImage['width'] as int?,
            height: rssImage['height'] as int?,
            title: _extractOptionalString(rssImage, 'title'),
            description: _extractOptionalString(rssImage, 'description'),
          ),
        );
      }
    }

    // Add iTunes image
    final itunesImage = feedData['itunesImage'] as String?;
    if (itunesImage != null &&
        itunesImage.trim().isNotEmpty &&
        _isValidUrl(itunesImage)) {
      images.add(PodcastImage(url: itunesImage.trim()));
    }

    return images;
  }

  /// Extracts images from item data.
  List<PodcastImage> _extractItemImages(Map<String, dynamic> itemData) {
    final images = <PodcastImage>[];

    // Add iTunes image
    final itunesImage = itemData['itunesImage'] as String?;
    if (itunesImage != null &&
        itunesImage.trim().isNotEmpty &&
        _isValidUrl(itunesImage)) {
      images.add(PodcastImage(url: itunesImage.trim()));
    }

    return images;
  }

  /// Combines categories from RSS and iTunes sources.
  List<String> _extractFeedCategories(Map<String, dynamic> feedData) {
    final categories = <String>[];

    // Add RSS categories
    final rssCategories = feedData['categories'] as List<String>?;
    if (rssCategories != null) {
      for (final category in rssCategories) {
        final trimmed = category.trim();
        if (trimmed.isNotEmpty && !categories.contains(trimmed)) {
          categories.add(trimmed);
        }
      }
    }

    // Add iTunes categories
    final itunesCategories = feedData['itunesCategories'] as List<String>?;
    if (itunesCategories != null) {
      for (final category in itunesCategories) {
        final trimmed = category.trim();
        if (trimmed.isNotEmpty && !categories.contains(trimmed)) {
          categories.add(trimmed);
        }
      }
    }

    return categories;
  }

  /// Extracts enclosure information from item data.
  Map<String, dynamic>? _extractEnclosure(Map<String, dynamic> itemData) {
    final enclosure = itemData['enclosure'] as Map<String, dynamic>?;
    if (enclosure == null) return null;

    final url = enclosure['url'] as String?;
    if (url == null || url.trim().isEmpty || !_isValidUrl(url)) {
      return null;
    }

    return {
      'url': url.trim(),
      'type': _extractOptionalString(enclosure, 'type'),
      'length': _parsePositiveInt(enclosure['length']),
    };
  }

  /// Extracts chapters from item data.
  ///
  /// Reads `itemData['chapters']` as a list of maps, skipping entries
  /// that lack a required `title` or `startTime`.
  List<PodcastChapter>? _extractChapters(Map<String, dynamic> itemData) {
    final chapterMaps = itemData['chapters'] as List<Map<String, dynamic>>?;
    if (chapterMaps == null || chapterMaps.isEmpty) return null;

    final chapters = <PodcastChapter>[];
    for (final ch in chapterMaps) {
      final title = ch['title'] as String?;
      final startTime = ch['startTime'] as Duration?;
      if (title == null || startTime == null) continue;

      chapters.add(
        PodcastChapter(
          title: title,
          startTime: startTime,
          url: ch['url'] as String?,
          imageUrl: ch['imageUrl'] as String?,
        ),
      );
    }

    return chapters.isEmpty ? null : chapters;
  }

  /// Extracts transcripts from item data.
  ///
  /// Reads `itemData['transcripts']` as a list of maps, skipping entries
  /// that lack a required `url` or `type`.
  List<PodcastTranscript>? _extractTranscripts(
    Map<String, dynamic> itemData,
  ) {
    final transcriptMaps =
        itemData['transcripts'] as List<Map<String, dynamic>>?;
    if (transcriptMaps == null || transcriptMaps.isEmpty) return null;

    final transcripts = <PodcastTranscript>[];
    for (final tr in transcriptMaps) {
      final url = tr['url'] as String?;
      final type = tr['type'] as String?;
      if (url == null || type == null) continue;

      transcripts.add(
        PodcastTranscript(
          url: url,
          type: type,
          language: tr['language'] as String?,
          rel: tr['rel'] as String?,
        ),
      );
    }

    return transcripts.isEmpty ? null : transcripts;
  }

  /// Extracts a required string field with a default value.
  String _extractRequiredString(
    Map<String, dynamic> data,
    String key,
    String defaultValue,
  ) {
    final value = data[key] as String?;
    if (value == null || value.trim().isEmpty) {
      return defaultValue;
    }
    return value.trim();
  }

  /// Extracts an optional string field, returning null if empty or missing.
  String? _extractOptionalString(Map<String, dynamic> data, String key) {
    final value = data[key] as String?;
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  /// Parses a date value, handling various formats and returning null on failure.
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String && dateValue.trim().isNotEmpty) {
      try {
        // Try RFC 2822 format first (common in RSS)
        return DateTime.parse(dateValue.trim());
      } catch (e) {
        try {
          // Try other common formats
          return DateTime.tryParse(dateValue.trim());
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }

  /// Parses a duration value from various formats.
  Duration? _parseDuration(dynamic durationValue) {
    if (durationValue == null) return null;

    if (durationValue is Duration) return durationValue;

    if (durationValue is String && durationValue.trim().isNotEmpty) {
      try {
        final durationString = durationValue.trim();

        // Handle HH:MM:SS format
        final parts = durationString.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          return Duration(hours: hours, minutes: minutes, seconds: seconds);
        } else if (parts.length == 2) {
          final minutes = int.parse(parts[0]);
          final seconds = int.parse(parts[1]);
          return Duration(minutes: minutes, seconds: seconds);
        } else {
          // Assume seconds only
          final seconds = int.parse(durationString);
          return Duration(seconds: seconds);
        }
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Parses a boolean value from various formats.
  bool _parseBoolean(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is String) {
      final lower = value.toLowerCase().trim();
      return lower == 'true' || lower == 'yes' || lower == '1';
    }

    return false;
  }

  /// Parses a positive integer, returning null for invalid values.
  int? _parsePositiveInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return 0 <= value ? value : null;
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final parsed = int.parse(value.trim());
        return 0 <= parsed ? parsed : null;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Normalizes iTunes type to valid values.
  String? _normalizeItunesType(String? type) {
    if (type == null) return null;

    final normalized = type.toLowerCase().trim();
    if (normalized == 'episodic' || normalized == 'serial') {
      return normalized;
    }

    return null;
  }

  /// Normalizes episode type to valid values.
  String? _normalizeEpisodeType(String? type) {
    if (type == null) return null;

    final normalized = type.toLowerCase().trim();
    if (normalized == 'full' ||
        normalized == 'trailer' ||
        normalized == 'bonus') {
      return normalized;
    }

    return null;
  }

  /// Validates if a string is a valid URL.
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Error-handling wrapper methods

  /// Extracts feed images with error handling.
  List<PodcastImage> _extractFeedImagesWithErrorHandling(
    Map<String, dynamic> feedData,
    String? sourceUrl,
  ) {
    try {
      return _extractFeedImages(feedData);
    } catch (e) {
      _emitWarning(
        'Failed to extract feed images: $e',
        sourceUrl,
        entityType: 'Feed',
        elementName: 'image',
      );
      return <PodcastImage>[];
    }
  }

  /// Extracts item images with error handling.
  List<PodcastImage> _extractItemImagesWithErrorHandling(
    Map<String, dynamic> itemData,
    String? sourceUrl,
  ) {
    try {
      return _extractItemImages(itemData);
    } catch (e) {
      _emitWarning(
        'Failed to extract item images: $e',
        sourceUrl,
        entityType: 'Item',
        elementName: 'image',
      );
      return <PodcastImage>[];
    }
  }

  /// Extracts owner information with error handling.
  Map<String, dynamic> _extractOwnerInfoWithErrorHandling(
    Map<String, dynamic> feedData,
    String? sourceUrl,
  ) {
    try {
      final owner = feedData['itunesOwner'] as Map<String, dynamic>?;
      return {
        'name': owner?['name'] as String?,
        'email': owner?['email'] as String?,
      };
    } catch (e) {
      _emitWarning(
        'Failed to extract owner information: $e',
        sourceUrl,
        entityType: 'Feed',
        elementName: 'itunesOwner',
      );
      return {'name': null, 'email': null};
    }
  }

  /// Extracts feed categories with error handling.
  List<String> _extractFeedCategoriesWithErrorHandling(
    Map<String, dynamic> feedData,
    String? sourceUrl,
  ) {
    try {
      return _extractFeedCategories(feedData);
    } catch (e) {
      _emitWarning(
        'Failed to extract feed categories: $e',
        sourceUrl,
        entityType: 'Feed',
        elementName: 'category',
      );
      return <String>[];
    }
  }

  /// Extracts item categories with error handling.
  List<String> _extractItemCategoriesWithErrorHandling(
    Map<String, dynamic> itemData,
    String? sourceUrl,
  ) {
    try {
      return itemData['categories'] as List<String>? ?? <String>[];
    } catch (e) {
      _emitWarning(
        'Failed to extract item categories: $e',
        sourceUrl,
        entityType: 'Item',
        elementName: 'category',
      );
      return <String>[];
    }
  }

  /// Extracts enclosure with error handling.
  Map<String, dynamic>? _extractEnclosureWithErrorHandling(
    Map<String, dynamic> itemData,
    String? sourceUrl,
  ) {
    try {
      return _extractEnclosure(itemData);
    } catch (e) {
      _emitWarning(
        'Failed to extract enclosure: $e',
        sourceUrl,
        entityType: 'Item',
        elementName: 'enclosure',
      );
      return null;
    }
  }

  /// Parses date with error handling.
  DateTime? _parseDateWithErrorHandling(
    dynamic dateValue,
    String elementName,
    String? sourceUrl,
  ) {
    try {
      return _parseDate(dateValue);
    } catch (e) {
      _emitWarning(
        'Failed to parse date for $elementName: $e',
        sourceUrl,
        elementName: elementName,
      );
      return null;
    }
  }

  /// Parses duration with error handling.
  Duration? _parseDurationWithErrorHandling(
    dynamic durationValue,
    String? sourceUrl,
  ) {
    try {
      return _parseDuration(durationValue);
    } catch (e) {
      _emitWarning(
        'Failed to parse duration: $e',
        sourceUrl,
        entityType: 'Item',
        elementName: 'itunesDuration',
      );
      return null;
    }
  }

  /// Parses positive integer with error handling.
  int? _parsePositiveIntWithErrorHandling(
    dynamic value,
    String elementName,
    String? sourceUrl,
  ) {
    try {
      return _parsePositiveInt(value);
    } catch (e) {
      _emitWarning(
        'Failed to parse positive integer for $elementName: $e',
        sourceUrl,
        elementName: elementName,
      );
      return null;
    }
  }

  /// Normalizes iTunes type with error handling.
  String? _normalizeItunesTypeWithErrorHandling(
    String? type,
    String? sourceUrl,
  ) {
    try {
      final normalized = _normalizeItunesType(type);
      if (type != null && type.trim().isNotEmpty && normalized == null) {
        _emitWarning(
          'Invalid iTunes type "$type", must be "episodic" or "serial"',
          sourceUrl,
          entityType: 'Feed',
          elementName: 'itunesType',
        );
      }
      return normalized;
    } catch (e) {
      _emitWarning(
        'Failed to normalize iTunes type: $e',
        sourceUrl,
        entityType: 'Feed',
        elementName: 'itunesType',
      );
      return null;
    }
  }

  /// Normalizes episode type with error handling.
  String? _normalizeEpisodeTypeWithErrorHandling(
    String? type,
    String? sourceUrl,
  ) {
    try {
      final normalized = _normalizeEpisodeType(type);
      if (type != null && type.trim().isNotEmpty && normalized == null) {
        _emitWarning(
          'Invalid episode type "$type", must be "full", "trailer", or "bonus"',
          sourceUrl,
          entityType: 'Item',
          elementName: 'itunesEpisodeType',
        );
      }
      return normalized;
    } catch (e) {
      _emitWarning(
        'Failed to normalize episode type: $e',
        sourceUrl,
        entityType: 'Item',
        elementName: 'itunesEpisodeType',
      );
      return null;
    }
  }

  /// Emits a warning for recoverable parsing issues.
  void _emitWarning(
    String message,
    String? sourceUrl, {
    String? entityType,
    String? elementName,
  }) {
    final warning = PodcastParseWarning(
      parsedAt: DateTime.now(),
      sourceUrl: sourceUrl ?? '',
      message: message,
      entityType: entityType,
      elementName: elementName,
    );
    _warningController.add(warning);
  }

  /// Disposes resources used by the factory.
  void dispose() {
    _warningController.close();
  }
}
