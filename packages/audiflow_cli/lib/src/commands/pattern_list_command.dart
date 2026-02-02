import '../patterns/pattern_registry.dart';

/// Command to list all available patterns.
class PatternListCommand {
  PatternListCommand({StringSink? sink, PatternRegistry? registry})
    : _sink = sink ?? StringBuffer(),
      _registry = registry ?? PatternRegistry();

  final StringSink _sink;
  final PatternRegistry _registry;

  /// Runs the command and returns exit code.
  int run() {
    final patterns = _registry.listPatterns();

    if (patterns.isEmpty) {
      _sink.writeln('No patterns registered.');
      return 0;
    }

    _sink.writeln('Available patterns:');
    _sink.writeln();

    for (final pattern in patterns) {
      final urls = pattern.feedUrlPatterns?.join(', ') ?? '(no URL patterns)';
      _sink.writeln('  ${pattern.id.padRight(20)} $urls');
    }

    return 0;
  }
}
