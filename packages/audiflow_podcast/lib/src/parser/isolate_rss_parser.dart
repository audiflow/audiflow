import 'dart:async';
import 'dart:isolate';

import 'package:xml/xml.dart';

import 'parse_progress.dart';

/// Trims whitespace and returns null for blank strings.
String? _nullIfBlank(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Parses RSS feeds in a separate isolate to prevent UI freezes.
///
/// Supports early-stop optimization: stops parsing when a known episode GUID
/// is encountered, reducing parse time for subscribed podcasts from O(n) to O(new).
/// Result of parsing a complete feed in an isolate.
class IsolateParsedFeed {
  const IsolateParsedFeed({
    required this.meta,
    required this.episodes,
    required this.stoppedEarly,
  });

  final ParsedPodcastMeta meta;
  final List<ParsedEpisode> episodes;
  final bool stoppedEarly;
}

class IsolateRssParser {
  IsolateRssParser._();

  /// Parses the feed in an isolate and returns metadata + episodes at once.
  ///
  /// Pass [knownGuids], [knownNewestPubDate], and/or [knownNewestGuid] to
  /// enable early-stop optimization for incremental updates.
  /// Omit all cutoff parameters to parse the entire feed.
  static Future<IsolateParsedFeed> parseFeed({
    required String feedXml,
    Set<String> knownGuids = const {},
    DateTime? knownNewestPubDate,
    String? knownNewestGuid,
  }) async {
    ParsedPodcastMeta? meta;
    final episodes = <ParsedEpisode>[];
    var didStopEarly = false;

    await for (final progress in parse(
      feedXml: feedXml,
      knownGuids: knownGuids,
      knownNewestPubDate: knownNewestPubDate,
      knownNewestGuid: knownNewestGuid,
    )) {
      switch (progress) {
        case ParsedPodcastMeta():
          meta = progress;
        case ParsedEpisode():
          episodes.add(progress);
        case ParseComplete(:final stoppedEarly):
          didStopEarly = stoppedEarly;
      }
    }

    if (meta == null) {
      throw Exception('No podcast metadata found in feed');
    }

    return IsolateParsedFeed(
      meta: meta,
      episodes: episodes,
      stoppedEarly: didStopEarly,
    );
  }

  /// Parses the given XML in a background isolate.
  ///
  /// - [feedXml]: Raw XML content of the RSS feed
  /// - [knownGuids]: Set of episode GUIDs already in the database
  /// - [maxNewEpisodes]: Optional limit on episodes to parse (null = unlimited)
  ///
  /// Returns a stream of [ParseProgress] events. The isolate is spawned
  /// lazily when the first listener attaches.
  ///
  /// Cancelling the stream subscription kills the background isolate
  /// immediately, freeing resources.
  static Stream<ParseProgress> parse({
    required String feedXml,
    required Set<String> knownGuids,
    int? maxNewEpisodes,
    DateTime? knownNewestPubDate,
    String? knownNewestGuid,
  }) {
    final receivePort = ReceivePort();
    Isolate? isolate;
    StreamSubscription<dynamic>? portSub;
    var cancelled = false;

    late final StreamController<ParseProgress> controller;
    controller = StreamController<ParseProgress>(
      onListen: () {
        Isolate.spawn(
              _parseInIsolate,
              _IsolateParams(
                feedXml: feedXml,
                knownGuids: knownGuids,
                maxNewEpisodes: maxNewEpisodes,
                sendPort: receivePort.sendPort,
                knownNewestPubDate: knownNewestPubDate,
                knownNewestGuid: knownNewestGuid,
              ),
            )
            .then((spawned) {
              if (cancelled) {
                // Stream was cancelled while the isolate was spawning.
                spawned.kill(priority: Isolate.immediate);
                receivePort.close();
                if (!controller.isClosed) controller.close();
                return;
              }
              isolate = spawned;
              portSub = receivePort.listen(
                (message) {
                  if (cancelled || controller.isClosed) return;
                  if (message is ParseProgress) {
                    controller.add(message);
                    if (message is ParseComplete) {
                      isolate = null;
                      portSub?.cancel();
                      receivePort.close();
                      controller.close();
                    }
                  } else if (message is _IsolateError) {
                    controller.addError(Exception(message.error));
                  }
                },
                onDone: () {
                  if (!controller.isClosed) controller.close();
                },
              );
            })
            .catchError((Object e) {
              controller.addError(e);
              receivePort.close();
              controller.close();
            });
      },
      onCancel: () {
        cancelled = true;
        isolate?.kill(priority: Isolate.immediate);
        isolate = null;
        portSub?.cancel();
        receivePort.close();
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );

    return controller.stream;
  }

  static void _parseInIsolate(_IsolateParams params) {
    try {
      final xml = params.feedXml;

      // --- Metadata: parse only the channel header (before first <item>) ---
      final firstItemIdx = xml.indexOf('<item');
      if (firstItemIdx == -1) {
        // No items at all — emit metadata from whatever we have
        params.sendPort.send(_parseMetadataFromString(xml));
        params.sendPort.send(
          const ParseComplete(totalParsed: 0, stoppedEarly: false),
        );
        return;
      }

      final header = xml.substring(0, firstItemIdx);
      params.sendPort.send(_parseMetadataFromString(header));

      // --- Episodes: scan for <item>...</item> blocks incrementally ---
      var parsedCount = 0;
      var stoppedEarly = false;
      final cutoff = params.knownNewestPubDate;
      final cutoffGuid = params.knownNewestGuid;
      final itemOpenTag = RegExp(r'<item[\s>]');
      const itemCloseTag = '</item>';

      final itemMatches = itemOpenTag.allMatches(xml, firstItemIdx).iterator;

      while (itemMatches.moveNext()) {
        final itemStart = itemMatches.current.start;
        final closeIdx = xml.indexOf(itemCloseTag, itemStart);
        if (closeIdx == -1) break;

        final itemEnd = closeIdx + itemCloseTag.length;
        final itemXml = xml.substring(itemStart, itemEnd);

        // Quick-check guid and pubDate via lightweight regex before DOM-parsing
        final guid = _extractTagText(itemXml, 'guid');

        // Early stop: GUID-set match (legacy path, used by parseWithProgress)
        if (guid != null && params.knownGuids.contains(guid)) {
          stoppedEarly = true;
          break;
        }

        // Early stop: pubDate-based cutoff
        if (cutoff != null) {
          final pubDateStr = _extractTagText(itemXml, 'pubDate');
          final pubDate = _parseDate(pubDateStr);
          if (pubDate != null && !cutoff.isBefore(pubDate)) {
            if (cutoffGuid == null || cutoffGuid == guid) {
              stoppedEarly = true;
              break;
            }
          }
        }

        // Only DOM-parse items we actually need
        final itemElement = XmlDocument.parse(itemXml).rootElement;
        final episode = _parseEpisode(itemElement);
        params.sendPort.send(episode);
        parsedCount++;

        // Optional limit
        final limit = params.maxNewEpisodes;
        if (limit != null && limit <= parsedCount) {
          break;
        }
      }

      params.sendPort.send(
        ParseComplete(totalParsed: parsedCount, stoppedEarly: stoppedEarly),
      );
    } catch (e) {
      params.sendPort.send(_IsolateError(e.toString()));
      params.sendPort.send(
        const ParseComplete(totalParsed: 0, stoppedEarly: false),
      );
    }
  }

  /// Extracts channel metadata from the header portion of the XML
  /// (everything before the first <item>) using lightweight regex.
  /// No DOM allocation needed for the header.
  static ParsedPodcastMeta _parseMetadataFromString(String headerXml) {
    final title = _extractTagText(headerXml, 'title') ?? 'Untitled Podcast';

    // itunes:image uses an href attribute, not text content
    final itunesImageMatch = RegExp(
      r'''<itunes:image[^>]+href=["']([^"']+)["']''',
    ).firstMatch(headerXml);

    return ParsedPodcastMeta(
      title: title,
      description: _extractTagText(headerXml, 'description') ?? '',
      author: _extractTagText(headerXml, 'itunes:author'),
      imageUrl: _nullIfBlank(itunesImageMatch?.group(1)),
      language: _extractTagText(headerXml, 'language'),
    );
  }

  /// Lightweight tag text extraction using regex — no DOM allocation.
  /// Handles both plain text and CDATA content.
  static final _tagTextCache = <String, RegExp>{};

  static String? _extractTagText(String xml, String tagName) {
    final re = _tagTextCache.putIfAbsent(
      tagName,
      () => RegExp(
        '<$tagName[^>]*>'
        r'(?:<!\[CDATA\[)?' // optional CDATA start
        r'([\s\S]*?)' // content (non-greedy)
        r'(?:\]\]>)?' // optional CDATA end
        '</$tagName>',
        caseSensitive: false,
      ),
    );
    final match = re.firstMatch(xml);
    return _nullIfBlank(match?.group(1));
  }

  static ParsedEpisode _parseEpisode(XmlElement item) {
    final enclosure = item.findElements('enclosure').firstOrNull;

    return ParsedEpisode(
      guid: _extractText(item, 'guid'),
      title: _extractText(item, 'title') ?? 'Untitled Episode',
      description: _extractText(item, 'description'),
      enclosureUrl: enclosure?.getAttribute('url'),
      enclosureType: enclosure?.getAttribute('type'),
      enclosureLength: int.tryParse(enclosure?.getAttribute('length') ?? ''),
      publishDate: _parseDate(_extractText(item, 'pubDate')),
      duration: _parseDuration(_extractItunesText(item, 'duration')),
      episodeNumber: int.tryParse(_extractItunesText(item, 'episode') ?? ''),
      seasonNumber: int.tryParse(_extractItunesText(item, 'season') ?? ''),
      imageUrl: _extractItunesImageUrl(item),
      transcripts: _extractTranscripts(item),
      chapters: _extractChapters(item),
    );
  }

  static List<ParsedTranscript>? _extractTranscripts(XmlElement item) {
    final transcripts = <ParsedTranscript>[];
    for (final element in item.children.whereType<XmlElement>()) {
      if (element.localName != 'transcript') continue;
      final url = _nullIfBlank(element.getAttribute('url'));
      final type = _nullIfBlank(element.getAttribute('type'));
      if (url == null || type == null) continue;
      transcripts.add(
        ParsedTranscript(
          url: url,
          type: type,
          language: _nullIfBlank(element.getAttribute('language')),
          rel: _nullIfBlank(element.getAttribute('rel')),
        ),
      );
    }
    return transcripts.isEmpty ? null : transcripts;
  }

  static List<ParsedChapter>? _extractChapters(XmlElement item) {
    // Find psc:chapters container element
    XmlElement? chaptersElement;
    for (final element in item.children.whereType<XmlElement>()) {
      if (element.localName == 'chapters') {
        chaptersElement = element;
        break;
      }
    }
    if (chaptersElement == null) return null;

    final chapters = <ParsedChapter>[];
    for (final element in chaptersElement.children.whereType<XmlElement>()) {
      if (element.localName != 'chapter') continue;
      final title = _nullIfBlank(element.getAttribute('title'));
      final startStr = _nullIfBlank(element.getAttribute('start'));
      if (title == null || startStr == null) continue;
      final startTime = _parseChapterTimestamp(startStr);
      if (startTime == null) continue;
      chapters.add(
        ParsedChapter(
          title: title,
          startTime: startTime,
          url: _nullIfBlank(element.getAttribute('href')),
          imageUrl: _nullIfBlank(element.getAttribute('image')),
        ),
      );
    }
    return chapters.isEmpty ? null : chapters;
  }

  static Duration? _parseChapterTimestamp(String timestamp) {
    // Format: HH:MM:SS.mmm or HH:MM:SS
    final parts = timestamp.split(':');
    if (parts.length != 3) return null;
    try {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secondsParts = parts[2].split('.');
      final seconds = int.parse(secondsParts[0]);
      final millis = secondsParts.length == 2
          ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
          : 0;
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
        milliseconds: millis,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _extractText(XmlElement parent, String elementName) {
    return _nullIfBlank(
      parent.findElements(elementName).firstOrNull?.innerText,
    );
  }

  static String? _extractItunesText(XmlElement parent, String localName) {
    for (final element in parent.children.whereType<XmlElement>()) {
      if (element.localName == localName &&
          (element.name.qualified.startsWith('itunes:') ||
              element.namespaceUri ==
                  'http://www.itunes.com/dtds/podcast-1.0.dtd')) {
        return _nullIfBlank(element.innerText);
      }
    }
    return null;
  }

  static String? _extractItunesImageUrl(XmlElement parent) {
    for (final element in parent.children.whereType<XmlElement>()) {
      if (element.localName == 'image' &&
          (element.name.qualified.startsWith('itunes:') ||
              element.namespaceUri ==
                  'http://www.itunes.com/dtds/podcast-1.0.dtd')) {
        return _nullIfBlank(element.getAttribute('href'));
      }
    }
    return null;
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      // Try RFC 2822 format: "Wed, 28 Jan 2026 20:00:00 GMT"
      return _parseRfc2822(dateString);
    }
  }

  static final _rfc2822Re = RegExp(
    r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\s*(\S+)?',
  );

  static const _months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  static DateTime? _parseRfc2822(String dateString) {
    final match = _rfc2822Re.firstMatch(dateString);
    if (match == null) return null;

    final day = int.parse(match.group(1)!);
    final month = _months[match.group(2)!];
    if (month == null) return null;
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);
    final tz = match.group(7);

    final dt = DateTime.utc(year, month, day, hour, minute, second);

    // Apply timezone offset
    if (tz != null && tz != 'GMT' && tz != 'UTC' && tz != 'UT') {
      final tzMatch = RegExp(r'^([+-])(\d{2})(\d{2})$').firstMatch(tz);
      if (tzMatch != null) {
        final sign = tzMatch.group(1) == '+' ? 1 : -1;
        final tzHours = int.parse(tzMatch.group(2)!);
        final tzMinutes = int.parse(tzMatch.group(3)!);
        return dt.subtract(
          Duration(hours: sign * tzHours, minutes: sign * tzMinutes),
        );
      }
    }

    return dt;
  }

  static Duration? _parseDuration(String? durationString) {
    if (durationString == null || durationString.isEmpty) return null;

    final parts = durationString.split(':');
    try {
      if (parts.length == 3) {
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(parts[2]),
        );
      } else if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      } else {
        return Duration(seconds: int.parse(durationString));
      }
    } catch (_) {
      return null;
    }
  }
}

class _IsolateParams {
  const _IsolateParams({
    required this.feedXml,
    required this.knownGuids,
    required this.maxNewEpisodes,
    required this.sendPort,
    this.knownNewestPubDate,
    this.knownNewestGuid,
  });

  final String feedXml;
  final Set<String> knownGuids;
  final int? maxNewEpisodes;
  final SendPort sendPort;

  /// Newest episode publish date already in the database.
  /// When set, parsing stops at the first episode whose pubDate
  /// is at or before this date (confirmed by GUID match if available).
  final DateTime? knownNewestPubDate;

  /// GUID of the newest known episode, used to confirm the pubDate-based
  /// early-stop when both are provided.
  final String? knownNewestGuid;
}

class _IsolateError {
  const _IsolateError(this.error);
  final String error;
}
