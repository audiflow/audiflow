import 'package:flutter/foundation.dart';

import 'gemma_model_variant.dart';

/// Stable reason tokens explaining why on-device voice commands cannot run
/// on the current device. Used for telemetry and to key UI messages.
enum GemmaVoiceUnsupportedReason { nonMobile, insufficientRam }

/// Whether on-device Gemma 4 voice commands can run on the current device,
/// and which variants are offerable if so.
@immutable
sealed class GemmaVoiceCapability {
  const GemmaVoiceCapability();

  /// Voice commands cannot run on this device.
  const factory GemmaVoiceCapability.unsupported({
    required GemmaVoiceUnsupportedReason reason,
  }) = GemmaVoiceCapabilityUnsupported;

  /// Voice commands can run; [available] lists the offerable variants
  /// ordered from smallest to largest.
  factory GemmaVoiceCapability.supported({
    required List<GemmaModelVariant> available,
  }) = GemmaVoiceCapabilitySupported;
}

/// The unsupported case; carries a stable reason token.
final class GemmaVoiceCapabilityUnsupported extends GemmaVoiceCapability {
  const GemmaVoiceCapabilityUnsupported({required this.reason});

  final GemmaVoiceUnsupportedReason reason;

  @override
  bool operator ==(Object other) =>
      other is GemmaVoiceCapabilityUnsupported && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'GemmaVoiceCapability.unsupported($reason)';
}

/// The supported case; [available] is unmodifiable so callers can't mutate
/// the offered variant list.
final class GemmaVoiceCapabilitySupported extends GemmaVoiceCapability {
  GemmaVoiceCapabilitySupported({required List<GemmaModelVariant> available})
    : assert(available.isNotEmpty, 'supported must offer at least one variant'),
      available = List.unmodifiable(available);

  final List<GemmaModelVariant> available;

  @override
  bool operator ==(Object other) =>
      other is GemmaVoiceCapabilitySupported &&
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
    return const GemmaVoiceCapability.unsupported(
      reason: GemmaVoiceUnsupportedReason.nonMobile,
    );
  }
  final available = <GemmaModelVariant>[];
  for (final variant in GemmaModelVariant.values) {
    if (variant.minimumDeviceRamMb <= deviceTotalRamMb) {
      available.add(variant);
    }
  }
  if (available.isEmpty) {
    return const GemmaVoiceCapability.unsupported(
      reason: GemmaVoiceUnsupportedReason.insufficientRam,
    );
  }
  return GemmaVoiceCapability.supported(available: available);
}
