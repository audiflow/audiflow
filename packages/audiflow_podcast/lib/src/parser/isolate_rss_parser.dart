import 'dart:async';
import 'dart:isolate';

import 'package:xml/xml.dart';

import 'parse_progress.dart';

/// Parses RSS feeds in a separate isolate to prevent UI freezes.
///
/// Supports early-stop optimization: stops parsing when a known episode GUID
/// is encountered, reducing parse time for subscribed podcasts from O(n) to O(new).
class IsolateRssParser {
  IsolateRssParser._();

  /// Parses the given XML in a background isolate.
  ///
  /// - [feedXml]: Raw XML content of the RSS feed
  /// - [knownGuids]: Set of episode GUIDs already in the database
  /// - [maxNewEpisodes]: Safety limit to prevent runaway parsing (default: 500)
  ///
  /// Returns a stream of [ParseProgress] events.
  static Stream<ParseProgress> parse({
    required String feedXml,
    required Set<String> knownGuids,
    int maxNewEpisodes = 500,
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
        params.sendPort.send(_IsolateError('No RSS or Atom feed found'));
        params.sendPort.send(
          const ParseComplete(totalParsed: 0, stoppedEarly: false),
        );
        return;
      }

      final channelElement = rssElement.findElements('channel').firstOrNull;
      if (channelElement == null) {
        params.sendPort.send(_IsolateError('No channel element found'));
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

        // Safety limit
        if (params.maxNewEpisodes <= parsedCount) {
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
    );
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
      // Try common RSS date formats
      try {
        // RFC 2822 simplified parsing
        return DateTime.tryParse(dateString);
      } catch (_) {
        return null;
      }
    }
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
  final int maxNewEpisodes;
  final SendPort sendPort;
}

class _IsolateError {
  const _IsolateError(this.error);
  final String error;
}
