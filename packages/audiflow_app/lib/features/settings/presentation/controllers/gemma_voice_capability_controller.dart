import 'dart:io';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemma_voice_capability_controller.g.dart';

/// Resolves the device's [GemmaVoiceCapability] from `device_info_plus`.
///
/// Cached for the lifetime of the process — RAM doesn't change at runtime,
/// and the underlying plugin call is cheap but synchronously async, which
/// would otherwise add a frame of jank to every settings rebuild.
@Riverpod(keepAlive: true)
Future<GemmaVoiceCapability> gemmaVoiceCapability(Ref ref) async {
  final info = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return detectGemmaVoiceCapability(
      deviceTotalRamMb: android.physicalRamSize,
      isMobilePlatform: true,
    );
  }
  if (Platform.isIOS) {
    final ios = await info.iosInfo;
    return detectGemmaVoiceCapability(
      deviceTotalRamMb: ios.physicalRamSize,
      isMobilePlatform: true,
    );
  }
  return const GemmaVoiceCapability.unsupported(
    reason: GemmaVoiceUnsupportedReason.nonMobile,
  );
}
