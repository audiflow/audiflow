import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';

/// App-layer reasons a caller may request a gate unlock.
///
/// Carries UI copy labels and analytics vocabulary. Intentionally mirrors
/// [UnlockReason] values (minus `unspecified`) so each app-layer reason has an
/// unambiguous domain-layer counterpart via [gateReasonToUnlock].
enum GateReason {
  subscribe,
  unsubscribe,
  opmlImport,
  deepLink,
  parentalSettings,
  developerSettings,
}

/// Maps an app-layer [GateReason] to the domain-layer [UnlockReason] used for
/// audit logging.
UnlockReason gateReasonToUnlock(GateReason r) => switch (r) {
  GateReason.subscribe => UnlockReason.subscribe,
  GateReason.unsubscribe => UnlockReason.unsubscribe,
  GateReason.opmlImport => UnlockReason.opmlImport,
  GateReason.deepLink => UnlockReason.deepLink,
  GateReason.parentalSettings => UnlockReason.parentalSettings,
  GateReason.developerSettings => UnlockReason.developerSettings,
};

abstract class GateGuard {
  /// Returns true if the action may proceed.
  ///
  /// - Restricted Mode off -> true immediately.
  /// - Restricted Mode on + already unlocked -> extends idle, returns true.
  /// - Otherwise shows the PIN entry sheet and awaits the result.
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  });
}
