import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../settings/providers/settings_providers.dart';
import 'gemma_voice_command_route.dart';
import 'settings_metadata_registry.dart';

part 'gemma_voice_providers.g.dart';

/// Composition seam for the on-device Gemma 4 inference session.
///
/// The default implementation throws because the session is backed by the
/// `flutter_gemma` plugin, which lives in `audiflow_app` to keep the
/// platform-channel dependency out of the domain layer. The host app
/// overrides this provider at the root [ProviderScope] /
/// [ProviderContainer] with a real session.
@Riverpod(keepAlive: true)
GemmaInferenceSession gemmaInferenceSession(Ref ref) {
  throw UnimplementedError(
    'gemmaInferenceSessionProvider must be overridden at the composition '
    'root with a flutter_gemma-backed implementation.',
  );
}

@Riverpod(keepAlive: true)
GemmaVoiceCommandService gemmaVoiceCommandService(Ref ref) {
  return GemmaVoiceCommandService(
    session: ref.watch(gemmaInferenceSessionProvider),
  );
}

@Riverpod(keepAlive: true)
GemmaVoiceCommandRoute gemmaVoiceCommandRoute(Ref ref) {
  return GemmaVoiceCommandRoute(
    service: ref.watch(gemmaVoiceCommandServiceProvider),
    registry: SettingsMetadataRegistry(),
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
    logger: ref.watch(namedLoggerProvider('GemmaVoiceRoute')),
  );
}
