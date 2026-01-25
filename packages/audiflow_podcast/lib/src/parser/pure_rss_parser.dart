import 'dart:async';
import 'dart:convert';

import '../errors/podcast_parse_error.dart';
import '../models/podcast_entity.dart';
import 'streaming_xml_parser.dart';

/// Pure-Dart RSS parser without Flutter dependencies.
///
/// This parser supports parsing from strings and byte streams only.
/// For URL fetching with caching, use [PodcastRssParser] from the main library.
class PureRssParser {
  /// Parses a podcast RSS feed from the given XML string.
  ///
  /// Returns a stream of [PodcastEntity] objects as they are parsed.
  Stream<PodcastEntity> parseFromString(String xmlContent) async* {
    if (xmlContent.trim().isEmpty) {
      yield* Stream.error(
        XmlParsingError(
          parsedAt: DateTime.now(),
          sourceUrl: 'string',
          message: 'XML content is empty',
        ),
      );
      return;
    }

    // Convert string to byte stream
    final bytes = utf8.encode(xmlContent);
    final byteStream = Stream.value(bytes);

    yield* parseFromStream(byteStream);
  }

  /// Parses a podcast RSS feed from the given stream of bytes.
  ///
  /// Returns a stream of [PodcastEntity] objects as they are parsed.
  Stream<PodcastEntity> parseFromStream(Stream<List<int>> xmlStream) async* {
    StreamingXmlParser? parser;
    late StreamController<PodcastEntity> controller;
    StreamSubscription<PodcastEntity>? entitySubscription;

    try {
      parser = StreamingXmlParser();
      controller = StreamController<PodcastEntity>();

      // Forward entities from parser to controller
      entitySubscription = parser.entityStream.listen(
        controller.add,
        onError: (Object error) => controller.addError(
          error is PodcastParseError
              ? error
              : XmlParsingError(
                  parsedAt: DateTime.now(),
                  sourceUrl: 'stream',
                  message: 'Entity parsing error: $error',
                  originalException: error is Exception
                      ? error
                      : Exception(error.toString()),
                ),
        ),
        onDone: controller.close,
      );

      // Start parsing with proper error handling
      try {
        await parser.parseXmlStream(xmlStream, sourceUrl: 'stream');
      } catch (e) {
        controller.addError(
          e is PodcastParseError
              ? e
              : XmlParsingError(
                  parsedAt: DateTime.now(),
                  sourceUrl: 'stream',
                  message: 'XML stream parsing error: $e',
                  originalException: e is Exception
                      ? e
                      : Exception(e.toString()),
                ),
        );
      }

      // Yield entities from the controller
      yield* controller.stream;
    } catch (e) {
      yield* Stream.error(
        e is PodcastParseError
            ? e
            : XmlParsingError(
                parsedAt: DateTime.now(),
                sourceUrl: 'stream',
                message: 'Stream setup error: $e',
                originalException: e is Exception ? e : Exception(e.toString()),
              ),
      );
    } finally {
      // Ensure proper cleanup
      await entitySubscription?.cancel();
      parser?.dispose();
      try {
        await controller.close();
      } catch (_) {
        // Controller might not be initialized if early failure
      }
    }
  }
}
