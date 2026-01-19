import 'package:audiflow_core/audiflow_core.dart';

import 'podcast_parse_error.dart';

/// Application-level exception for podcast operations.
///
/// Bridges [PodcastParseError] from the streaming parser to the
/// application's [AppException] hierarchy for unified error handling.
class PodcastException extends AppException {
  PodcastException({
    required String message,
    String? code,
    this.parseError,
    this.sourceUrl,
  }) : super(message, code ?? _inferCode(parseError));

  /// Creates a [PodcastException] from a [PodcastParseError].
  factory PodcastException.fromParseError(PodcastParseError error) {
    return PodcastException(
      message: error.message,
      parseError: error,
      sourceUrl: error.sourceUrl,
    );
  }

  /// Creates a [PodcastException] for network-related issues.
  factory PodcastException.network(
    String message, {
    int? statusCode,
    String? sourceUrl,
  }) {
    final code = statusCode != null
        ? 'PODCAST_NETWORK_$statusCode'
        : 'PODCAST_NETWORK_ERROR';
    return PodcastException(
      message: message,
      code: code,
      sourceUrl: sourceUrl,
    );
  }

  /// Creates a [PodcastException] for parsing-related issues.
  factory PodcastException.parsing(
    String message, {
    String? elementName,
    String? sourceUrl,
  }) {
    return PodcastException(
      message: elementName != null
          ? '$message (element: $elementName)'
          : message,
      code: 'PODCAST_PARSE_ERROR',
      sourceUrl: sourceUrl,
    );
  }

  /// Creates a [PodcastException] for validation-related issues.
  factory PodcastException.validation(
    String message, {
    List<String>? errors,
    String? sourceUrl,
  }) {
    final errorDetails = errors != null && errors.isNotEmpty
        ? ' [${errors.join(', ')}]'
        : '';
    return PodcastException(
      message: '$message$errorDetails',
      code: 'PODCAST_VALIDATION_ERROR',
      sourceUrl: sourceUrl,
    );
  }

  /// Creates a [PodcastException] for cache-related issues.
  factory PodcastException.cache(
    String message, {
    String? operation,
    String? sourceUrl,
  }) {
    return PodcastException(
      message: operation != null ? '$message (operation: $operation)' : message,
      code: 'PODCAST_CACHE_ERROR',
      sourceUrl: sourceUrl,
    );
  }

  /// The original parsing error, if this exception was created from one.
  final PodcastParseError? parseError;

  /// The source URL where the error occurred.
  final String? sourceUrl;

  static String _inferCode(PodcastParseError? error) {
    if (error == null) return 'PODCAST_ERROR';
    return switch (error) {
      NetworkError() => 'PODCAST_NETWORK_ERROR',
      XmlParsingError() => 'PODCAST_PARSE_ERROR',
      EntityValidationError() => 'PODCAST_VALIDATION_ERROR',
      CacheError() => 'PODCAST_CACHE_ERROR',
      _ => 'PODCAST_ERROR',
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (sourceUrl != null) {
      buffer.write(' (url: $sourceUrl)');
    }
    return buffer.toString();
  }
}
