import 'gemma_model_variant.dart';

/// Whether on-device Gemma 4 voice commands can run on the current device,
/// and which variants are offerable if so.
sealed class GemmaVoiceCapability {
  const GemmaVoiceCapability();

  /// Voice commands cannot run on this device. [reason] is a stable token
  /// (not a localized string) for telemetry and UI key lookup.
  const factory GemmaVoiceCapability.unsupported({required String reason}) =
      _Unsupported;

  /// Voice commands can run; [available] lists the offerable variants
  /// ordered from smallest to largest.
  const factory GemmaVoiceCapability.supported({
    required List<GemmaModelVariant> available,
  }) = _Supported;
}

class _Unsupported extends GemmaVoiceCapability {
  const _Unsupported({required this.reason});
  final String reason;

  @override
  bool operator ==(Object other) =>
      other is _Unsupported && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'GemmaVoiceCapability.unsupported($reason)';
}

class _Supported extends GemmaVoiceCapability {
  const _Supported({required this.available});
  final List<GemmaModelVariant> available;

  @override
  bool operator ==(Object other) =>
      other is _Supported &&
      other.available.length == available.length &&
      _listsEqual(other.available, available);

  @override
  int get hashCode => Object.hashAll(available);

  @override
  String toString() => 'GemmaVoiceCapability.supported($available)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

/// Pure capability check. Caller (audiflow_app) collects [deviceTotalRamMb]
/// via `device_info_plus` and passes [isMobilePlatform] explicitly so this
/// package stays Flutter-pure with no platform calls of its own.
GemmaVoiceCapability detectGemmaVoiceCapability({
  required int deviceTotalRamMb,
  required bool isMobilePlatform,
}) {
  if (!isMobilePlatform) {
    return const GemmaVoiceCapability.unsupported(reason: 'non_mobile');
  }
  final available = <GemmaModelVariant>[];
  for (final variant in GemmaModelVariant.values) {
    if (variant.minimumDeviceRamMb <= deviceTotalRamMb) {
      available.add(variant);
    }
  }
  if (available.isEmpty) {
    return const GemmaVoiceCapability.unsupported(reason: 'insufficient_ram');
  }
  return GemmaVoiceCapability.supported(available: available);
}
