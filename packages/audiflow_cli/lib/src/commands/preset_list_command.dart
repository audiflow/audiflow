import '../presets/preset_registry.dart';

/// Command to list all available presets.
class PresetListCommand {
  PresetListCommand({StringSink? sink, PresetRegistry? registry})
    : _sink = sink ?? StringBuffer(),
      _registry = registry ?? PresetRegistry();

  final StringSink _sink;
  final PresetRegistry _registry;

  /// Runs the command and returns exit code.
  int run() {
    final presets = _registry.listPresets();

    if (presets.isEmpty) {
      _sink.writeln('No presets registered.');
      return 0;
    }

    _sink.writeln('Available presets:');
    _sink.writeln();

    for (final preset in presets) {
      final urls = preset.feedUrls?.join(', ') ?? '(no URLs)';
      _sink.writeln('  ${preset.id.padRight(20)} $urls');
    }

    return 0;
  }
}
