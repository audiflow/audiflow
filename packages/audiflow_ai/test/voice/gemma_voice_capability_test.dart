import 'package:audiflow_ai/src/voice/gemma_model_variant.dart';
import 'package:audiflow_ai/src/voice/gemma_voice_capability.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('detectGemmaVoiceCapability', () {
    test('returns unsupported on non-mobile platforms', () {
      final result = detectGemmaVoiceCapability(
        deviceTotalRamMb: 16000,
        isMobilePlatform: false,
      );
      check(result).equals(
        const GemmaVoiceCapability.unsupported(
          reason: GemmaVoiceUnsupportedReason.nonMobile,
        ),
      );
    });

    test('returns unsupported when RAM is below E2B threshold', () {
      final result = detectGemmaVoiceCapability(
        deviceTotalRamMb: 2000,
        isMobilePlatform: true,
      );
      check(result).equals(
        const GemmaVoiceCapability.unsupported(
          reason: GemmaVoiceUnsupportedReason.insufficientRam,
        ),
      );
    });

    test('returns E2B only for mid-range devices', () {
      final result = detectGemmaVoiceCapability(
        deviceTotalRamMb: 4000,
        isMobilePlatform: true,
      );
      check(result).equals(
        GemmaVoiceCapability.supported(
          available: const [GemmaModelVariant.e2b],
        ),
      );
    });

    test('returns E2B and E4B for flagship devices', () {
      final result = detectGemmaVoiceCapability(
        deviceTotalRamMb: 8000,
        isMobilePlatform: true,
      );
      check(result).equals(
        GemmaVoiceCapability.supported(
          available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
        ),
      );
    });

    test('exact threshold match qualifies', () {
      final result = detectGemmaVoiceCapability(
        deviceTotalRamMb: GemmaModelVariant.e4b.minimumDeviceRamMb,
        isMobilePlatform: true,
      );
      check(result).equals(
        GemmaVoiceCapability.supported(
          available: const [GemmaModelVariant.e2b, GemmaModelVariant.e4b],
        ),
      );
    });
  });
}
