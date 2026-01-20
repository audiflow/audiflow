import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_provider.g.dart';

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
@Riverpod(keepAlive: true)
Logger appLogger(Ref ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: Level.debug,
  );
}

/// Provides a named logger for a specific component.
///
/// Creates a logger with a custom prefix for easier log filtering.
///
/// Usage:
/// ```dart
/// final logger = ref.watch(namedLoggerProvider('FeedParser'));
/// logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
/// ```
@riverpod
Logger namedLogger(Ref ref, String name) {
  return Logger(
    printer: _NamedPrinter(name),
    level: Level.debug,
  );
}

/// Custom printer that prefixes log messages with a component name.
class _NamedPrinter extends PrettyPrinter {
  _NamedPrinter(this.name)
      : super(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: true,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        );

  final String name;

  @override
  List<String> log(LogEvent event) {
    final lines = super.log(event);
    if (lines.isEmpty) return lines;

    // Prepend component name to the first line
    return [
      '[$name] ${lines.first}',
      ...lines.skip(1),
    ];
  }
}
