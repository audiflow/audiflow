import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../errors/podcast_parse_error.dart';
import '../models/podcast_entity.dart';
import '../models/podcast_feed.dart';
import '../models/podcast_item.dart';

/// Streaming XML parser that processes RSS feeds in streaming mode
/// and emits Feed and Item entities as they are parsed.
class StreamingXmlParser {
  final StreamController<PodcastEntity> _controller =
      StreamController<PodcastEntity>();
  final ParsingState _state = ParsingState();

  /// Stream of parsed podcast entities (Feed and Item objects)
  Stream<PodcastEntity> get entityStream => _controller.stream;

  /// Parse XML content from a stream of bytes using streaming approach
  Future<void> parseXmlStream(
    Stream<List<int>> inputStream, {
    String? sourceUrl,
  }) async {
    try {
      _state.sourceUrl = sourceUrl;

      // Accumulate content in chunks and process items as they become available
      final xmlBuffer = StringBuffer();
      var processedItems = 0;

      await for (final chunk in inputStream) {
        final chunkString = utf8.decode(chunk);
        xmlBuffer.write(chunkString);

        // Process complete items as they become available
        final currentContent = xmlBuffer.toString();
        final newItemCount = await _processAvailableItems(
          currentContent,
          processedItems,
        );
        processedItems = newItemCount;
      }

      // Process any remaining content
      final finalContent = xmlBuffer.toString();
      await _processFinalContent(finalContent);
    } catch (e) {
      _controller.addError(
        XmlParsingError(
          parsedAt: DateTime.now(),
          sourceUrl: sourceUrl ?? '',
          message: 'Failed to parse XML stream: $e',
          originalException: e is Exception ? e : Exception(e.toString()),
        ),
      );
    } finally {
      await _controller.close();
    }
  }

  /// Process items that are available in the current content
  Future<int> _processAvailableItems(
    String content,
    int alreadyProcessed,
  ) async {
    // Find all complete <item>...</item> blocks
    final itemRegex = RegExp(r'<item[^>]*>.*?</item>', dotAll: true);
    final matches = itemRegex.allMatches(content);

    var itemCount = 0;
    for (final match in matches) {
      itemCount++;

      // Only process new items
      if (alreadyProcessed < itemCount) {
        // Emit feed heuristically when first item is encountered
        if (!_state.feedEmitted) {
          await _extractAndEmitFeed(content);
        }

        final itemXml = match.group(0)!;
        await _processItemXml(itemXml);
      }
    }

    return itemCount;
  }

  /// Extract feed information and emit it
  Future<void> _extractAndEmitFeed(String content) async {
    try {
      // Extract channel information without parsing the entire document
      // Look for channel start and extract content up to first item
      final channelStartMatch = RegExp(r'<channel[^>]*>').firstMatch(content);
      if (channelStartMatch != null) {
        final channelStart = channelStartMatch.end;
        final firstItemMatch = RegExp(
          r'<item[^>]*>',
        ).firstMatch(content.substring(channelStart));

        String channelContent;
        if (firstItemMatch != null) {
          // Extract channel content up to first item
          channelContent = content.substring(
            channelStart,
            channelStart + firstItemMatch.start,
          );
        } else {
          // No items found yet, extract what we have
          final channelEndMatch = RegExp(r'</channel>').firstMatch(content);
          if (channelEndMatch != null) {
            channelContent = content.substring(
              channelStart,
              channelEndMatch.start,
            );
          } else {
            // Channel not complete yet, extract what we have
            channelContent = content.substring(channelStart);
          }
        }

        await _extractChannelData(channelContent);
        await _emitFeedEntity();
      }
    } catch (e) {
      // Continue processing even if feed extraction fails
    }
  }

  /// Extract channel data from channel content
  Future<void> _extractChannelData(String channelContent) async {
    // Extract basic channel elements using regex (simple approach for streaming)
    _extractSimpleElement(channelContent, 'title', 'title');
    _extractSimpleElement(channelContent, 'description', 'description');
    _extractSimpleElement(channelContent, 'link', 'link');
    _extractSimpleElement(channelContent, 'language', 'language');
    _extractSimpleElement(channelContent, 'copyright', 'copyright');
    _extractSimpleElement(channelContent, 'managingEditor', 'managingEditor');
    _extractSimpleElement(channelContent, 'webMaster', 'webMaster');
    _extractSimpleElement(channelContent, 'generator', 'generator');

    // Extract dates
    final lastBuildDate = _extractElementText(channelContent, 'lastBuildDate');
    if (lastBuildDate != null) {
      _state.currentFeedData['lastBuildDate'] = _parseDate(lastBuildDate);
    }

    final pubDate = _extractElementText(channelContent, 'pubDate');
    if (pubDate != null) {
      _state.currentFeedData['pubDate'] = _parseDate(pubDate);
    }

    // Extract TTL
    final ttl = _extractElementText(channelContent, 'ttl');
    if (ttl != null) {
      _state.currentFeedData['ttl'] = int.tryParse(ttl);
    }

    // Extract iTunes elements
    _extractSimpleElement(channelContent, 'itunes:author', 'itunesAuthor');
    _extractSimpleElement(channelContent, 'itunes:subtitle', 'itunesSubtitle');
    _extractSimpleElement(channelContent, 'itunes:summary', 'itunesSummary');
    _extractSimpleElement(channelContent, 'itunes:type', 'itunesType');

    final itunesExplicit = _extractElementText(
      channelContent,
      'itunes:explicit',
    );
    if (itunesExplicit != null) {
      _state.currentFeedData['itunesExplicit'] = _parseBoolean(itunesExplicit);
    }

    final itunesComplete = _extractElementText(
      channelContent,
      'itunes:complete',
    );
    if (itunesComplete != null) {
      _state.currentFeedData['itunesComplete'] = _parseBoolean(itunesComplete);
    }

    // Extract iTunes image
    final itunesImageMatch = RegExp(
      r'<itunes:image[^>]*href="([^"]*)"',
    ).firstMatch(channelContent);
    if (itunesImageMatch != null) {
      _state.currentFeedData['itunesImage'] = itunesImageMatch.group(1);
    }

    // Extract categories
    final categoryMatches = RegExp(
      r'<category[^>]*>([^<]*)</category>',
    ).allMatches(channelContent);
    final categories = <String>[];
    for (final match in categoryMatches) {
      final category = match.group(1)?.trim();
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    if (categories.isNotEmpty) {
      _state.currentFeedData['categories'] = categories;
    }

    // Extract iTunes categories
    final itunesCategoryMatches = RegExp(
      r'<itunes:category[^>]*text="([^"]*)"',
    ).allMatches(channelContent);
    final itunesCategories = <String>[];
    for (final match in itunesCategoryMatches) {
      final category = match.group(1)?.trim();
      if (category != null && category.isNotEmpty) {
        itunesCategories.add(category);
      }
    }
    if (itunesCategories.isNotEmpty) {
      _state.currentFeedData['itunesCategories'] = itunesCategories;
    }
  }

  /// Extract simple element text content
  void _extractSimpleElement(
    String content,
    String elementName,
    String dataKey,
  ) {
    final text = _extractElementText(content, elementName);
    if (text != null) {
      _state.currentFeedData[dataKey] = text;
    }
  }

  /// Extract element text using regex
  String? _extractElementText(String content, String elementName) {
    final regex = RegExp('<$elementName[^>]*>([^<]*)</$elementName>');
    final match = regex.firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// Process a single item XML
  Future<void> _processItemXml(String itemXml) async {
    try {
      // Parse just the item element
      final itemElement = XmlDocument.parse(itemXml).rootElement;
      await _processItemElement(itemElement);
    } catch (e) {
      // Skip malformed items but continue processing
    }
  }

  /// Process final content when stream is complete
  Future<void> _processFinalContent(String content) async {
    // Emit Feed if no items were found
    if (!_state.feedEmitted && _state.currentFeedData.isEmpty) {
      await _extractAndEmitFeed(content);
    }

    if (!_state.feedEmitted && _state.currentFeedData.isNotEmpty) {
      await _emitFeedEntity();
    }
  }

  /// Parse complete XML string content using streaming approach
  Future<void> parseXmlString(String xmlContent, {String? sourceUrl}) async {
    try {
      _state.sourceUrl = sourceUrl;

      // For string content, we can use the existing DOM approach but process it in a streaming manner
      await _parseCompleteXml(xmlContent, sourceUrl);
    } catch (e) {
      _controller.addError(
        XmlParsingError(
          parsedAt: DateTime.now(),
          sourceUrl: sourceUrl ?? '',
          message: 'Failed to parse XML string: $e',
          originalException: e is Exception ? e : Exception(e.toString()),
        ),
      );
    } finally {
      await _controller.close();
    }
  }

  /// Parse complete XML content
  Future<void> _parseCompleteXml(String xmlContent, String? sourceUrl) async {
    try {
      final document = XmlDocument.parse(xmlContent);
      final rssElement =
          document.findElements('rss').firstOrNull ??
          document.findElements('feed').firstOrNull;

      if (rssElement == null) {
        throw XmlParserException('No RSS or Atom feed found in XML');
      }

      _state.sourceUrl = sourceUrl;
      await _processRssElement(rssElement);
    } catch (e) {
      if (e is XmlParserException) {
        _controller.addError(
          XmlParsingError(
            parsedAt: DateTime.now(),
            sourceUrl: sourceUrl ?? '',
            message: 'XML parsing error: ${e.message}',
            originalException: e,
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  /// Process individual item elements
  Future<void> _processItemElement(XmlElement itemElement) async {
    final itemData = <String, dynamic>{};

    // Process direct children only
    for (final child in itemElement.children) {
      if (child is XmlElement) {
        await _processItemChildElement(child, itemData);
      }
    }

    // Emit the item entity
    await _emitItemEntity(itemData);
  }

  /// Process individual item child elements
  Future<void> _processItemChildElement(
    XmlElement element,
    Map<String, dynamic> itemData,
  ) async {
    final elementName = element.localName;
    final elementData = element.innerText.trim();

    // Handle RSS 2.0 standard elements
    switch (elementName) {
      case 'title':
        itemData['title'] = elementData;
      case 'description':
        itemData['description'] = elementData;
      case 'link':
        itemData['link'] = elementData;
      case 'guid':
        itemData['guid'] = elementData;
        itemData['isPermaLink'] =
            element.getAttribute('isPermaLink') != 'false';
      case 'pubDate':
        itemData['pubDate'] = _parseDate(elementData);
      case 'enclosure':
        itemData['enclosure'] = _parseEnclosureElement(element);
      case 'category':
        _addToList(itemData, 'categories', elementData);
      case 'comments':
        itemData['comments'] = elementData;
      case 'source':
        itemData['source'] = elementData;
    }

    // Handle iTunes namespace elements
    await _handleItunesItemElement(element, elementData, itemData);

    // Handle content:encoded
    if (element.name.qualified == 'content:encoded') {
      itemData['contentEncoded'] = elementData;
    }

    // Handle podcast:transcript
    if (element.name.qualified == 'podcast:transcript') {
      _addTranscriptToItemData(element, itemData);
    }

    // Handle psc:chapters (Podlove Simple Chapters)
    if (element.localName == 'chapters' &&
        (element.namespaceUri == 'http://podlove.org/simple-chapters' ||
            element.name.qualified.startsWith('psc:'))) {
      _extractPscChapters(element, itemData);
    }
  }

  /// Handle iTunes namespace elements for items
  Future<void> _handleItunesItemElement(
    XmlElement element,
    String elementData,
    Map<String, dynamic> itemData,
  ) async {
    final elementName = element.localName;
    final namespaceUri = element.namespaceUri;

    if (namespaceUri == 'http://www.itunes.com/dtds/podcast-1.0.dtd' ||
        element.name.qualified.startsWith('itunes:')) {
      switch (elementName) {
        case 'author':
          itemData['itunesAuthor'] = elementData;
        case 'subtitle':
          itemData['itunesSubtitle'] = elementData;
        case 'summary':
          itemData['itunesSummary'] = elementData;
        case 'explicit':
          itemData['itunesExplicit'] = _parseBoolean(elementData);
        case 'duration':
          itemData['itunesDuration'] = _parseDuration(elementData);
        case 'image':
          final href = element.getAttribute('href');
          if (href != null) {
            itemData['itunesImage'] = href;
          }
        case 'episode':
          itemData['itunesEpisode'] = int.tryParse(elementData);
        case 'season':
          itemData['itunesSeason'] = int.tryParse(elementData);
        case 'episodeType':
          itemData['itunesEpisodeType'] = elementData;
      }
    }
  }

  /// Process the RSS root element using event-driven approach
  Future<void> _processRssElement(XmlElement rssElement) async {
    final channelElement = rssElement.findElements('channel').firstOrNull;
    if (channelElement == null) {
      throw XmlParserException('No channel element found in RSS feed');
    }

    // Start processing with event-driven approach
    await _processElementRecursively(channelElement);

    // Emit Feed if no items were found
    if (!_state.feedEmitted && _state.currentFeedData.isNotEmpty) {
      await _emitFeedEntity();
    }
  }

  /// Process XML element recursively with proper state management
  Future<void> _processElementRecursively(XmlElement element) async {
    final elementName = element.localName;
    final attributes = <String, String>{};

    // Extract attributes
    for (final attr in element.attributes) {
      attributes[attr.localName] = attr.value;
    }

    // Handle start element
    await _handleStartElement(elementName, attributes, element);

    // Process child elements
    for (final child in element.children) {
      if (child is XmlElement) {
        await _processElementRecursively(child);
      } else if (child is XmlText) {
        await _handleCharacterData(child.innerText);
      }
    }

    // Handle end element
    await _handleEndElement(elementName, element);
  }

  /// Handle start element event
  Future<void> _handleStartElement(
    String elementName,
    Map<String, String> attributes,
    XmlElement element,
  ) async {
    _state.pushElement(elementName, attributes);

    // Heuristic: Emit Feed when first Item element starts
    if (elementName == 'item' && _state.shouldEmitFeed()) {
      await _emitFeedEntity();
    }

    // Handle special elements that need immediate processing
    if (elementName == 'enclosure') {
      await _handleEnclosureElement(element);
    }
  }

  /// Handle character data
  Future<void> _handleCharacterData(String data) async {
    if (data.trim().isNotEmpty) {
      _state.addCharacterData(data);
    }
  }

  /// Handle end element event
  Future<void> _handleEndElement(String elementName, XmlElement element) async {
    // Use the element's innerText instead of trying to accumulate character data
    final elementData = element.innerText.trim();

    // Process the completed element based on context
    if (_state.inItem) {
      await _handleItemElementEnd(elementName, elementData, element);
    } else if (_state.inChannel) {
      await _handleChannelElementEnd(elementName, elementData, element);
    }

    // Special handling for item completion
    if (elementName == 'item') {
      await _emitItemEntity(_state.currentItemData);
      _state.currentItemData.clear();
    }

    _state.popElement(elementName);
  }

  /// Handle channel element completion
  Future<void> _handleChannelElementEnd(
    String elementName,
    String elementData,
    XmlElement element,
  ) async {
    // Skip item elements - they're processed separately
    if (elementName == 'item') return;

    // Only process direct channel children for title and description to avoid conflicts
    final isDirectChannelChild =
        _state.elementStack.length == 2 && _state.elementStack[0] == 'channel';

    // Handle RSS 2.0 standard elements
    switch (elementName) {
      case 'title':
        if (isDirectChannelChild) {
          _state.currentFeedData['title'] = elementData;
        }
      case 'description':
        if (isDirectChannelChild) {
          _state.currentFeedData['description'] = elementData;
        }
      case 'link':
        _state.currentFeedData['link'] = elementData;
      case 'language':
        _state.currentFeedData['language'] = elementData;
      case 'copyright':
        _state.currentFeedData['copyright'] = elementData;
      case 'managingEditor':
        _state.currentFeedData['managingEditor'] = elementData;
      case 'webMaster':
        _state.currentFeedData['webMaster'] = elementData;
      case 'generator':
        _state.currentFeedData['generator'] = elementData;
      case 'lastBuildDate':
        _state.currentFeedData['lastBuildDate'] = _parseDate(elementData);
      case 'pubDate':
        _state.currentFeedData['pubDate'] = _parseDate(elementData);
      case 'ttl':
        _state.currentFeedData['ttl'] = int.tryParse(elementData);
      case 'image':
        _state.currentFeedData['image'] = _parseImageElement(element);
      case 'category':
        _addToList(_state.currentFeedData, 'categories', elementData);
    }

    // Handle iTunes namespace elements
    await _handleItunesChannelElementEnd(elementName, elementData, element);
  }

  /// Handle iTunes channel element completion
  Future<void> _handleItunesChannelElementEnd(
    String elementName,
    String elementData,
    XmlElement element,
  ) async {
    final namespaceUri = element.namespaceUri;

    if (namespaceUri == 'http://www.itunes.com/dtds/podcast-1.0.dtd' ||
        element.name.qualified.startsWith('itunes:')) {
      switch (elementName) {
        case 'author':
          _state.currentFeedData['itunesAuthor'] = elementData;
        case 'subtitle':
          _state.currentFeedData['itunesSubtitle'] = elementData;
        case 'summary':
          _state.currentFeedData['itunesSummary'] = elementData;
        case 'explicit':
          _state.currentFeedData['itunesExplicit'] = _parseBoolean(elementData);
        case 'image':
          final href = element.getAttribute('href');
          if (href != null) {
            _state.currentFeedData['itunesImage'] = href;
          }
        case 'category':
          final category = element.getAttribute('text');
          if (category != null) {
            _addToList(_state.currentFeedData, 'itunesCategories', category);
          }
        case 'owner':
          final ownerData = _parseOwnerElement(element);
          if (ownerData != null) {
            _state.currentFeedData['itunesOwner'] = ownerData;
          }
        case 'type':
          _state.currentFeedData['itunesType'] = elementData;
        case 'complete':
          _state.currentFeedData['itunesComplete'] = _parseBoolean(elementData);
        case 'new-feed-url':
          _state.currentFeedData['itunesNewFeedUrl'] = elementData;
      }
    }
  }

  /// Handle item element completion
  Future<void> _handleItemElementEnd(
    String elementName,
    String elementData,
    XmlElement element,
  ) async {
    // Handle RSS 2.0 standard elements
    switch (elementName) {
      case 'title':
        _state.currentItemData['title'] = elementData;
      case 'description':
        _state.currentItemData['description'] = elementData;
      case 'link':
        _state.currentItemData['link'] = elementData;
      case 'guid':
        _state.currentItemData['guid'] = elementData;
        _state.currentItemData['isPermaLink'] =
            element.getAttribute('isPermaLink') != 'false';
      case 'pubDate':
        _state.currentItemData['pubDate'] = _parseDate(elementData);
      case 'category':
        _addToList(_state.currentItemData, 'categories', elementData);
      case 'comments':
        _state.currentItemData['comments'] = elementData;
      case 'source':
        _state.currentItemData['source'] = elementData;
    }

    // Handle iTunes namespace elements
    await _handleItunesItemElementEnd(elementName, elementData, element);

    // Handle content:encoded
    if (element.name.qualified == 'content:encoded') {
      _state.currentItemData['contentEncoded'] = elementData;
    }

    // Handle podcast:transcript
    if (element.name.qualified == 'podcast:transcript') {
      _addTranscriptToItemData(element, _state.currentItemData);
    }

    // Handle psc:chapters (Podlove Simple Chapters)
    if (element.localName == 'chapters' &&
        (element.namespaceUri == 'http://podlove.org/simple-chapters' ||
            element.name.qualified.startsWith('psc:'))) {
      _extractPscChapters(element, _state.currentItemData);
    }
  }

  /// Handle iTunes item element completion
  Future<void> _handleItunesItemElementEnd(
    String elementName,
    String elementData,
    XmlElement element,
  ) async {
    final namespaceUri = element.namespaceUri;

    if (namespaceUri == 'http://www.itunes.com/dtds/podcast-1.0.dtd' ||
        element.name.qualified.startsWith('itunes:')) {
      switch (elementName) {
        case 'author':
          _state.currentItemData['itunesAuthor'] = elementData;
        case 'subtitle':
          _state.currentItemData['itunesSubtitle'] = elementData;
        case 'summary':
          _state.currentItemData['itunesSummary'] = elementData;
        case 'explicit':
          _state.currentItemData['itunesExplicit'] = _parseBoolean(elementData);
        case 'duration':
          _state.currentItemData['itunesDuration'] = _parseDuration(
            elementData,
          );
        case 'image':
          final href = element.getAttribute('href');
          if (href != null) {
            _state.currentItemData['itunesImage'] = href;
          }
        case 'episode':
          _state.currentItemData['itunesEpisode'] = int.tryParse(elementData);
        case 'season':
          _state.currentItemData['itunesSeason'] = int.tryParse(elementData);
        case 'episodeType':
          _state.currentItemData['itunesEpisodeType'] = elementData;
      }
    }
  }

  /// Handle enclosure element
  Future<void> _handleEnclosureElement(XmlElement element) async {
    final enclosureData = _parseEnclosureElement(element);
    if (enclosureData != null) {
      _state.currentItemData['enclosure'] = enclosureData;
    }
  }

  /// Emit a Feed entity using heuristic approach
  Future<void> _emitFeedEntity() async {
    if (_state.feedEmitted) return;

    try {
      final feed = PodcastFeed.fromMap(
        _state.currentFeedData,
        _state.sourceUrl,
      );
      _controller.add(feed);
      _state.markFeedEmitted();
    } catch (e) {
      _controller.addError(
        EntityValidationError(
          parsedAt: DateTime.now(),
          sourceUrl: _state.sourceUrl ?? '',
          message: 'Failed to create Feed entity: $e',
          entityType: 'Feed',
          validationErrors: [],
          originalException: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Emit an Item entity
  Future<void> _emitItemEntity(Map<String, dynamic> itemData) async {
    try {
      final item = PodcastItem.fromMap(itemData, _state.sourceUrl);
      _controller.add(item);
    } catch (e) {
      _controller.addError(
        EntityValidationError(
          parsedAt: DateTime.now(),
          sourceUrl: _state.sourceUrl ?? '',
          message: 'Failed to create Item entity: $e',
          entityType: 'Item',
          validationErrors: [],
          originalException: e is Exception ? e : Exception(e.toString()),
        ),
      );
    }
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    try {
      // Try RFC 2822 format first (common in RSS feeds)
      // Format: "Mon, 01 Jan 2024 12:00:00 GMT"
      final rfc2822Format = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return rfc2822Format.parse(dateString);
    } catch (e) {
      try {
        // Try ISO 8601 format
        return DateTime.parse(dateString);
      } catch (e) {
        try {
          // Try DateTime.tryParse as fallback
          return DateTime.tryParse(dateString);
        } catch (e) {
          // Return null for invalid dates instead of throwing
          return null;
        }
      }
    }
  }

  /// Parse duration string to Duration
  Duration? _parseDuration(String durationString) {
    if (durationString.isEmpty) return null;

    try {
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

  /// Parse boolean string
  bool _parseBoolean(String value) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == 'yes' || lower == '1';
  }

  /// Parse image element
  Map<String, dynamic>? _parseImageElement(XmlElement element) {
    final url = element.findElements('url').firstOrNull?.innerText;
    if (url == null) return null;

    return {
      'url': url,
      'title': element.findElements('title').firstOrNull?.innerText,
      'link': element.findElements('link').firstOrNull?.innerText,
      'width': int.tryParse(
        element.findElements('width').firstOrNull?.innerText ?? '',
      ),
      'height': int.tryParse(
        element.findElements('height').firstOrNull?.innerText ?? '',
      ),
    };
  }

  /// Parse enclosure element
  Map<String, dynamic>? _parseEnclosureElement(XmlElement element) {
    final url = element.getAttribute('url');
    if (url == null) return null;

    return {
      'url': url,
      'type': element.getAttribute('type'),
      'length': int.tryParse(element.getAttribute('length') ?? ''),
    };
  }

  /// Parse owner element
  Map<String, dynamic>? _parseOwnerElement(XmlElement element) {
    // Try both with and without iTunes namespace
    final name =
        element.findElements('name').firstOrNull?.innerText ??
        element.findElements('itunes:name').firstOrNull?.innerText;
    final email =
        element.findElements('email').firstOrNull?.innerText ??
        element.findElements('itunes:email').firstOrNull?.innerText;

    if (name == null && email == null) return null;

    return {'name': name, 'email': email};
  }

  /// Add item to list in map
  void _addToList(Map<String, dynamic> map, String key, String value) {
    if (value.isEmpty) return;

    final list = map[key] as List<String>? ?? <String>[];
    if (!list.contains(value)) {
      list.add(value);
    }
    map[key] = list;
  }

  /// Extract transcript attributes and add to itemData['transcripts'] list.
  ///
  /// Skips elements missing required `url` or `type` attributes.
  void _addTranscriptToItemData(
    XmlElement element,
    Map<String, dynamic> itemData,
  ) {
    final url = element.getAttribute('url');
    final type = element.getAttribute('type');
    if (url == null || type == null) return;

    final transcripts =
        itemData['transcripts'] as List<Map<String, dynamic>>? ??
        <Map<String, dynamic>>[];
    transcripts.add({
      'url': url,
      'type': type,
      'language': element.getAttribute('language'),
      'rel': element.getAttribute('rel'),
    });
    itemData['transcripts'] = transcripts;
  }

  /// Extract Podlove Simple Chapters from a `<psc:chapters>` element.
  ///
  /// Iterates child `<psc:chapter>` elements, extracts attributes,
  /// and stores valid chapters in `itemData['chapters']`.
  /// Skips chapters missing required `start` or `title` attributes.
  void _extractPscChapters(
    XmlElement element,
    Map<String, dynamic> itemData,
  ) {
    final chapters =
        itemData['chapters'] as List<Map<String, dynamic>>? ??
        <Map<String, dynamic>>[];

    for (final child in element.children) {
      if (child is! XmlElement) continue;
      if (child.localName != 'chapter') continue;

      final start = child.getAttribute('start');
      final title = child.getAttribute('title');
      if (start == null || title == null) continue;

      final startTime = _parseChapterTimestamp(start);
      if (startTime == null) continue;

      chapters.add({
        'title': title,
        'startTime': startTime,
        'url': child.getAttribute('href'),
        'imageUrl': child.getAttribute('image'),
      });
    }

    if (chapters.isNotEmpty) {
      itemData['chapters'] = chapters;
    }
  }

  /// Parse a Podlove Simple Chapters timestamp to [Duration].
  ///
  /// Supports `HH:MM:SS.mmm` and `HH:MM:SS` formats.
  /// Returns null for unparseable timestamps.
  Duration? _parseChapterTimestamp(String timestamp) {
    final parts = timestamp.split(':');
    if (parts.length != 3) return null;

    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);

      // Handle optional milliseconds in seconds part
      final secondsParts = parts[2].split('.');
      final seconds = int.parse(secondsParts[0]);
      final milliseconds = 1 < secondsParts.length
          ? int.parse(secondsParts[1])
          : 0;

      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds,
      );
    } catch (_) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _controller.close();
  }
}

/// Parsing state management for streaming XML parser
class ParsingState {
  String currentElement = '';
  Map<String, String> currentAttributes = {};
  StringBuffer characterData = StringBuffer();
  Map<String, dynamic> currentFeedData = {};
  Map<String, dynamic> currentItemData = {};
  bool inItem = false;
  bool feedEmitted = false;
  String? sourceUrl;

  // Element nesting tracking
  final List<String> elementStack = [];

  // Context tracking for better parsing
  bool inChannel = false;
  bool inImage = false;
  bool inOwner = false;
  bool inEnclosure = false;

  // Character data accumulation for current element
  final Map<String, StringBuffer> elementData = {};

  void reset() {
    currentElement = '';
    currentAttributes.clear();
    characterData.clear();
    currentFeedData.clear();
    currentItemData.clear();
    inItem = false;
    feedEmitted = false;
    sourceUrl = null;
    elementStack.clear();
    inChannel = false;
    inImage = false;
    inOwner = false;
    inEnclosure = false;
    elementData.clear();
  }

  /// Push element onto the stack and update context
  void pushElement(String elementName, Map<String, String> attributes) {
    elementStack.add(elementName);
    currentElement = elementName;
    currentAttributes = Map.from(attributes);

    // Update context flags
    switch (elementName) {
      case 'channel':
        inChannel = true;
      case 'item':
        inItem = true;
      case 'image':
        inImage = true;
      case 'owner':
        inOwner = true;
      case 'enclosure':
        inEnclosure = true;
    }

    // Initialize character data buffer for this element
    elementData[elementName] = StringBuffer();
  }

  /// Pop element from the stack and update context
  void popElement(String elementName) {
    if (elementStack.isNotEmpty && elementStack.last == elementName) {
      elementStack.removeLast();
    }

    // Update context flags
    switch (elementName) {
      case 'channel':
        inChannel = false;
      case 'item':
        inItem = false;
      case 'image':
        inImage = false;
      case 'owner':
        inOwner = false;
      case 'enclosure':
        inEnclosure = false;
    }

    // Update current element to parent
    currentElement = elementStack.isNotEmpty ? elementStack.last : '';
    currentAttributes.clear();

    // Clean up character data buffer
    elementData.remove(elementName);
  }

  /// Add character data to the current element
  void addCharacterData(String data) {
    if (currentElement.isNotEmpty && elementData.containsKey(currentElement)) {
      elementData[currentElement]!.write(data);
    }
    characterData.write(data);
  }

  /// Get accumulated character data for an element
  String getElementData(String elementName) {
    return elementData[elementName]?.toString().trim() ?? '';
  }

  /// Get current element path (for debugging)
  String get elementPath => elementStack.join(' > ');

  /// Check if we're in a specific context
  bool isInContext(String context) {
    return elementStack.contains(context);
  }

  /// Check if we should emit feed (heuristic: when first item starts)
  bool shouldEmitFeed() {
    return !feedEmitted && inItem && currentFeedData.isNotEmpty;
  }

  /// Mark feed as emitted
  void markFeedEmitted() {
    feedEmitted = true;
  }
}
