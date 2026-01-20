// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Represents the device's AI capability level.
enum AiCapability {
  /// Full AI capability available.
  full,

  /// Limited AI capability (some features may not work).
  limited,

  /// AI is not available on this device.
  unavailable,

  /// AI requires setup (e.g., AICore installation on Android).
  needsSetup,
}

/// Extension methods for [AiCapability].
extension AiCapabilityExtension on AiCapability {
  /// Returns true if AI features can be used.
  bool get isUsable =>
      this == AiCapability.full || this == AiCapability.limited;

  /// Returns true if user action is required before AI can be used.
  bool get requiresAction => this == AiCapability.needsSetup;

  /// Human-readable description of the capability.
  String get description => switch (this) {
    AiCapability.full => 'Full AI capability available',
    AiCapability.limited => 'Limited AI capability',
    AiCapability.unavailable => 'AI not available on this device',
    AiCapability.needsSetup => 'AI requires setup',
  };
}
