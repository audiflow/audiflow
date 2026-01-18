import '../models/podcast_entity.dart';

/// Base class for all podcast parsing errors.
abstract class PodcastParseError extends PodcastEntity {
  /// The error message describing what went wrong.
  final String message;

  /// The XML element name where the error occurred, if applicable.
  final String? elementName;

  /// The original exception that caused this error, if any.
  final Exception? originalException;

  const PodcastParseError({
    required super.parsedAt,
    required super.sourceUrl,
    required this.message,
    this.elementName,
    this.originalException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (elementName != null) {
      buffer.write(' (element: $elementName)');
    }
    if (originalException != null) {
      buffer.write(' - Original: $originalException');
    }
    return buffer.toString();
  }
}

/// Error that occurs during XML parsing (malformed XML, invalid structure).
class XmlParsingError extends PodcastParseError {
  const XmlParsingError({
    required super.parsedAt,
    required super.sourceUrl,
    required super.message,
    super.elementName,
    super.originalException,
  });
}

/// Error that occurs during entity validation (missing required fields, invalid data).
class EntityValidationError extends PodcastParseError {
  /// The type of entity that failed validation (Feed or Item).
  final String entityType;

  /// List of specific validation errors.
  final List<String> validationErrors;

  const EntityValidationError({
    required super.parsedAt,
    required super.sourceUrl,
    required super.message,
    required this.entityType,
    required this.validationErrors,
    super.elementName,
    super.originalException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('EntityValidationError: $message');
    buffer.write(' (entityType: $entityType)');
    if (elementName != null) {
      buffer.write(' (element: $elementName)');
    }
    if (validationErrors.isNotEmpty) {
      buffer.write(' - Errors: ${validationErrors.join(', ')}');
    }
    if (originalException != null) {
      buffer.write(' - Original: $originalException');
    }
    return buffer.toString();
  }
}

/// Error that occurs during network operations (HTTP errors, timeouts).
class NetworkError extends PodcastParseError {
  /// HTTP status code, if applicable.
  final int? statusCode;

  const NetworkError({
    required super.parsedAt,
    required super.sourceUrl,
    required super.message,
    this.statusCode,
    super.originalException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('NetworkError: $message');
    if (statusCode != null) {
      buffer.write(' (status: $statusCode)');
    }
    if (originalException != null) {
      buffer.write(' - Original: $originalException');
    }
    return buffer.toString();
  }
}

/// Error that occurs during cache operations (read/write failures).
class CacheError extends PodcastParseError {
  /// The cache operation that failed (read, write, delete, etc.).
  final String operation;

  const CacheError({
    required super.parsedAt,
    required super.sourceUrl,
    required super.message,
    required this.operation,
    super.originalException,
  });

  @override
  String toString() {
    final buffer = StringBuffer('CacheError: $message');
    buffer.write(' (operation: $operation)');
    if (originalException != null) {
      buffer.write(' - Original: $originalException');
    }
    return buffer.toString();
  }
}

/// Warning for recoverable parsing issues that don't prevent entity creation.
class PodcastParseWarning extends PodcastEntity {
  /// The warning message describing the issue.
  final String message;

  /// The XML element name where the warning occurred, if applicable.
  final String? elementName;

  /// The type of entity being parsed when the warning occurred.
  final String? entityType;

  const PodcastParseWarning({
    required super.parsedAt,
    required super.sourceUrl,
    required this.message,
    this.elementName,
    this.entityType,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PodcastParseWarning: $message');
    if (entityType != null) {
      buffer.write(' (entityType: $entityType)');
    }
    if (elementName != null) {
      buffer.write(' (element: $elementName)');
    }
    return buffer.toString();
  }
}
