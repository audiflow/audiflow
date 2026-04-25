import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';

import '../../settings/repositories/app_settings_repository.dart';
import 'settings_metadata_registry.dart';

/// Composition-root entry point for the Gemma 4 voice command path.
///
/// Audio capture (host-side; lands in the audio-capture phase) calls
/// [dispatch] with raw mic bytes and gets a [VoiceCommand] back. The
/// existing `VoiceCommandExecutor` and `SettingsIntentResolver` then
/// take over -- this class only owns the Gemma-specific seam.
class GemmaVoiceCommandRoute {
  GemmaVoiceCommandRoute({
    required GemmaVoiceCommandService service,
    required SettingsMetadataRegistry registry,
    required AppSettingsRepository settingsRepository,
  }) : _service = service,
       _registry = registry,
       _settingsRepository = settingsRepository;

  final GemmaVoiceCommandService _service;
  final SettingsMetadataRegistry _registry;
  final AppSettingsRepository _settingsRepository;

  /// Run one voice command turn end to end.
  ///
  /// Builds the per-turn settings snapshot from the live registry +
  /// repository, hands it to [GemmaVoiceCommandService], and returns
  /// the parsed [VoiceCommand].
  Future<VoiceCommand> dispatch(Uint8List audio) {
    final snapshot = _buildSnapshot();
    return _service.dispatch(audio: audio, settingsSnapshot: snapshot);
  }

  List<SettingsSnapshotEntry> _buildSnapshot() {
    final raw = _registry.toJson(_settingsRepository)['settings'];
    if (raw is! List) {
      return const [];
    }
    return raw
        .whereType<Map<Object?, Object?>>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList(growable: false);
  }
}
