import 'package:meta/meta.dart';

/// Outcome of evaluating the remote force-update config against the
/// running app version.
///
/// Drives the gate widget: [HardUpdate] / [Maintenance] block the router,
/// [SoftUpdate] surfaces a dismissible banner, [NoUpdate] is the happy path.
@immutable
sealed class UpdateDecision {
  const UpdateDecision();
}

class NoUpdate extends UpdateDecision {
  const NoUpdate();

  @override
  bool operator ==(Object other) => other is NoUpdate;

  @override
  int get hashCode => 0;
}

abstract class _DecisionWithMessage extends UpdateDecision {
  final String messageKey;
  final Map<String, String>? messageOverride;
  final String? updateUrl;

  const _DecisionWithMessage({
    required this.messageKey,
    this.messageOverride,
    this.updateUrl,
  });
}

class SoftUpdate extends _DecisionWithMessage {
  const SoftUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is SoftUpdate &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

class HardUpdate extends _DecisionWithMessage {
  const HardUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is HardUpdate &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

class Maintenance extends _DecisionWithMessage {
  const Maintenance({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is Maintenance &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

bool _mapEq(Map<String, String>? a, Map<String, String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
