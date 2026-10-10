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
  return NamedLogger(name);
}

/// A [Logger] that knows its component name.
///
/// [LogEvent] carries no logger identity, so global listeners registered
/// with [Logger.addLogListener] (e.g. error reporting) cannot tell which
/// component logged. [NamedLogger] exposes its name through
/// [dispatchingName] for the duration of each synchronous dispatch.
class NamedLogger extends Logger {
  NamedLogger(this.name)
    : super(printer: _NamedPrinter(name), level: Level.debug);

  /// Component name, also used as the printed prefix.
  final String name;

  static String? _dispatchingName;

  /// Name of the [NamedLogger] whose event is being dispatched to log
  /// listeners right now, or null outside such a dispatch.
  ///
  /// Safe as a static: [Logger.log] runs listeners synchronously and an
  /// isolate is single-threaded, so no other dispatch can interleave.
  static String? get dispatchingName => _dispatchingName;

  @override
  void log(
    Level level,
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final previous = _dispatchingName;
    _dispatchingName = name;
    try {
      super.log(
        level,
        message,
        time: time,
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _dispatchingName = previous;
    }
  }
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
    return ['[$name] ${lines.first}', ...lines.skip(1)];
  }
}
