import 'dart:async';
import 'dart:isolate';

import 'package:xml/xml.dart';

import 'parse_progress.dart';

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

  /// Parses the complete feed in an isolate and returns all data at once.
  ///
  /// Use this for initial load when you need all episodes.
  /// For incremental updates, use [parse] which streams events.
  static Future<IsolateParsedFeed> parseFeed({
    required String feedXml,
  }) async {
    ParsedPodcastMeta? meta;
    final episodes = <ParsedEpisode>[];
    var didStopEarly = false;

    await for (final progress in parse(
      feedXml: feedXml,
      knownGuids: const {},
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
  /// Returns a stream of [ParseProgress] events.
  static Stream<ParseProgress> parse({
    required String feedXml,
    required Set<String> knownGuids,
    int? maxNewEpisodes,
  }) async* {
    final receivePort = ReceivePort();

    try {
      await Isolate.spawn(
        _parseInIsolate,
        _IsolateParams(
          feedXml: feedXml,
          knownGuids: knownGuids,
          maxNewEpisodes: maxNewEpisodes,
          sendPort: receivePort.sendPort,
        ),
      );

      await for (final message in receivePort) {
        if (message is ParseProgress) {
          yield message;
          if (message is ParseComplete) {
            break;
          }
        } else if (message is _IsolateError) {
          throw Exception(message.error);
        }
      }
    } finally {
      receivePort.close();
    }
  }

  static void _parseInIsolate(_IsolateParams params) {
    try {
      final document = XmlDocument.parse(params.feedXml);
      final rssElement =
          document.findElements('rss').firstOrNull ??
          document.findElements('feed').firstOrNull;

      if (rssElement == null) {
        params.sendPort.send(const _IsolateError('No RSS or Atom feed found'));
        params.sendPort.send(
          const ParseComplete(totalParsed: 0, stoppedEarly: false),
        );
        return;
      }

      final channelElement = rssElement.findElements('channel').firstOrNull;
      if (channelElement == null) {
        params.sendPort.send(const _IsolateError('No channel element found'));
        params.sendPort.send(
          const ParseComplete(totalParsed: 0, stoppedEarly: false),
        );
        return;
      }

      // Parse and emit metadata
      final meta = _parseMetadata(channelElement);
      params.sendPort.send(meta);

      // Parse episodes with early-stop
      var parsedCount = 0;
      var stoppedEarly = false;

      for (final itemElement in channelElement.findElements('item')) {
        final guid = _extractText(itemElement, 'guid');

        // Early stop: if we hit a known GUID, stop parsing
        if (guid != null && params.knownGuids.contains(guid)) {
          stoppedEarly = true;
          break;
        }

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
        ParseComplete(
          totalParsed: parsedCount,
          stoppedEarly: stoppedEarly,
        ),
      );
    } catch (e) {
      params.sendPort.send(_IsolateError(e.toString()));
      params.sendPort.send(
        const ParseComplete(totalParsed: 0, stoppedEarly: false),
      );
    }
  }

  static ParsedPodcastMeta _parseMetadata(XmlElement channel) {
    return ParsedPodcastMeta(
      title: _extractText(channel, 'title') ?? 'Untitled Podcast',
      description: _extractText(channel, 'description') ?? '',
      author: _extractItunesText(channel, 'author'),
      imageUrl: _extractItunesImageUrl(channel),
      language: _extractText(channel, 'language'),
    );
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
      final url = element.getAttribute('url');
      final type = element.getAttribute('type');
      if (url == null || type == null) continue;
      transcripts.add(
        ParsedTranscript(
          url: url,
          type: type,
          language: element.getAttribute('language'),
          rel: element.getAttribute('rel'),
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
      final title = element.getAttribute('title');
      final startStr = element.getAttribute('start');
      if (title == null || startStr == null) continue;
      final startTime = _parseChapterTimestamp(startStr);
      if (startTime == null) continue;
      chapters.add(
        ParsedChapter(
          title: title,
          startTime: startTime,
          url: element.getAttribute('href'),
          imageUrl: element.getAttribute('image'),
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
    return parent.findElements(elementName).firstOrNull?.innerText.trim();
  }

  static String? _extractItunesText(XmlElement parent, String localName) {
    for (final element in parent.children.whereType<XmlElement>()) {
      if (element.localName == localName &&
          (element.name.qualified.startsWith('itunes:') ||
              element.namespaceUri ==
                  'http://www.itunes.com/dtds/podcast-1.0.dtd')) {
        return element.innerText.trim();
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
        return element.getAttribute('href');
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
  });

  final String feedXml;
  final Set<String> knownGuids;
  final int? maxNewEpisodes;
  final SendPort sendPort;
}

class _IsolateError {
  const _IsolateError(this.error);
  final String error;
}
