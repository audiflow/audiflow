import 'package:audiflow_search/audiflow_search.dart' show StatusCode;

import 'package:audiflow_search/src/exceptions/status_code.dart'
    show StatusCode;

import '../exceptions/search_exception.dart';

/// Parses iTunes RSS feed JSON responses to extract podcast IDs.
///
/// This parser handles the transformation of iTunes top charts RSS feed
/// responses (in JSON format) to extract podcast IDs.
class FeedResponseParser {
  static const String _providerId = 'itunes_charts';

  /// Extracts podcast IDs from RSS feed response.
  ///
  /// Returns ordered list of podcast IDs corresponding to chart ranking.
  ///
  /// Throws [SearchException] with [StatusCode.internal] if:
  /// - `feed` field is missing or not a map
  /// - `entry` field exists but is not a list
  /// - Any entry is missing the `id.attributes.im:id` path
  List<String> extractPodcastIds(Map<String, dynamic> json) {
    try {
      final feed = json['feed'];
      if (feed == null) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'Missing feed field in RSS response',
          details: {'json': json},
        );
      }

      if (feed is! Map) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'feed field is not a valid JSON object',
          details: {'feedType': feed.runtimeType, 'json': json},
        );
      }

      final entry = feed['entry'];
      if (entry == null) {
        // No entries is valid - return empty list
        return [];
      }

      if (entry is! List) {
        throw SearchException.internal(
          providerId: _providerId,
          message: 'entry field is not a list',
          details: {'entryType': entry.runtimeType, 'json': json},
        );
      }

      if (entry.isEmpty) {
        return [];
      }

      final ids = <String>[];
      for (var i = 0; i < entry.length; i++) {
        final item = entry[i];
        if (item is! Map) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'Entry item at index $i is not a valid JSON object',
            details: {'index': i, 'item': item},
          );
        }

        final id = item['id'];
        if (id == null) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'Missing id field in entry at index $i',
            details: {'index': i, 'item': item},
          );
        }

        if (id is! Map) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'id field at index $i is not a valid JSON object',
            details: {'index': i, 'idType': id.runtimeType},
          );
        }

        final attributes = id['attributes'];
        if (attributes == null) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'Missing attributes field in id at index $i',
            details: {'index': i, 'id': id},
          );
        }

        if (attributes is! Map) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'attributes field at index $i is not a valid JSON object',
            details: {'index': i, 'attributesType': attributes.runtimeType},
          );
        }

        final imId = attributes['im:id'];
        if (imId == null) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'Missing im:id field in attributes at index $i',
            details: {'index': i, 'attributes': attributes},
          );
        }

        final imIdStr = imId.toString();
        if (imIdStr.isEmpty) {
          throw SearchException.internal(
            providerId: _providerId,
            message: 'im:id field at index $i is empty',
            details: {'index': i, 'im:id': imId},
          );
        }

        ids.add(imIdStr);
      }

      return ids;
    } catch (e) {
      if (e is SearchException) {
        rethrow;
      }
      throw SearchException.internal(
        providerId: _providerId,
        message: 'Failed to extract podcast IDs from feed: $e',
        details: {'error': e.toString(), 'json': json},
      );
    }
  }
}
