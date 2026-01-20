// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a configured [Logger] instance for the application.
///
/// The logger is configured with:
/// - [PrettyPrinter] for development with colored output
/// - Appropriate log level based on build mode
///
/// Usage:
/// ```dart
/// final logger = ref.watch(appLoggerProvider);
/// logger.i('Information message');
/// logger.w('Warning message');
/// logger.e('Error message', error: exception, stackTrace: stack);
/// ```

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// Provides a configured [Logger] instance for the application.
///
/// The logger is configured with:
/// - [PrettyPrinter] for development with colored output
/// - Appropriate log level based on build mode
///
/// Usage:
/// ```dart
/// final logger = ref.watch(appLoggerProvider);
/// logger.i('Information message');
/// logger.w('Warning message');
/// logger.e('Error message', error: exception, stackTrace: stack);
/// ```

final class AppLoggerProvider
    extends $FunctionalProvider<Logger, Logger, Logger>
    with $Provider<Logger> {
  /// Provides a configured [Logger] instance for the application.
  ///
  /// The logger is configured with:
  /// - [PrettyPrinter] for development with colored output
  /// - Appropriate log level based on build mode
  ///
  /// Usage:
  /// ```dart
  /// final logger = ref.watch(appLoggerProvider);
  /// logger.i('Information message');
  /// logger.w('Warning message');
  /// logger.e('Error message', error: exception, stackTrace: stack);
  /// ```
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<Logger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Logger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Logger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Logger>(value),
    );
  }
}

String _$appLoggerHash() => r'd7571c37245cf667c5c00c6b0e9f32356b405af3';

/// Provides a named logger for a specific component.
///
/// Creates a logger with a custom prefix for easier log filtering.
///
/// Usage:
/// ```dart
/// final logger = ref.watch(namedLoggerProvider('FeedParser'));
/// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
/// ```

@ProviderFor(namedLogger)
final namedLoggerProvider = NamedLoggerFamily._();

/// Provides a named logger for a specific component.
///
/// Creates a logger with a custom prefix for easier log filtering.
///
/// Usage:
/// ```dart
/// final logger = ref.watch(namedLoggerProvider('FeedParser'));
/// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
/// ```

final class NamedLoggerProvider
    extends $FunctionalProvider<Logger, Logger, Logger>
    with $Provider<Logger> {
  /// Provides a named logger for a specific component.
  ///
  /// Creates a logger with a custom prefix for easier log filtering.
  ///
  /// Usage:
  /// ```dart
  /// final logger = ref.watch(namedLoggerProvider('FeedParser'));
  /// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
  /// ```
  NamedLoggerProvider._({
    required NamedLoggerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'namedLoggerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$namedLoggerHash();

  @override
  String toString() {
    return r'namedLoggerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Logger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Logger create(Ref ref) {
    final argument = this.argument as String;
    return namedLogger(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Logger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Logger>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NamedLoggerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$namedLoggerHash() => r'e37c771f8ef5ac82743c87e909aeca15d24ba015';

/// Provides a named logger for a specific component.
///
/// Creates a logger with a custom prefix for easier log filtering.
///
/// Usage:
/// ```dart
/// final logger = ref.watch(namedLoggerProvider('FeedParser'));
/// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
/// ```

final class NamedLoggerFamily extends $Family
    with $FunctionalFamilyOverride<Logger, String> {
  NamedLoggerFamily._()
    : super(
        retry: null,
        name: r'namedLoggerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides a named logger for a specific component.
  ///
  /// Creates a logger with a custom prefix for easier log filtering.
  ///
  /// Usage:
  /// ```dart
  /// final logger = ref.watch(namedLoggerProvider('FeedParser'));
  /// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
  /// ```

  NamedLoggerProvider call(String name) =>
      NamedLoggerProvider._(argument: name, from: this);

  @override
  String toString() => r'namedLoggerProvider';
}
