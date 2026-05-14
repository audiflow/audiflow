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

/// Happy path: app is up-to-date and not in maintenance.
class NoUpdate extends UpdateDecision {
  const NoUpdate();

  @override
  bool operator ==(Object other) => other is NoUpdate;

  @override
  int get hashCode => 0;
}

/// Shared shape for decisions that carry a user-facing message payload.
///
/// Subclasses keep the runtime type so consumers can pattern-match on
/// the concrete decision while sharing the message resolution code.
@immutable
sealed class ActionableUpdateDecision extends UpdateDecision {
  final String messageKey;
  final Map<String, String>? messageOverride;
  final String? updateUrl;

  const ActionableUpdateDecision({
    required this.messageKey,
    this.messageOverride,
    this.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is ActionableUpdateDecision &&
      other.runtimeType == runtimeType &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    messageKey,
    _mapHash(messageOverride),
    updateUrl,
  );
}

/// Recommended-version not met: show a dismissible banner.
class SoftUpdate extends ActionableUpdateDecision {
  const SoftUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });
}

/// Minimum-version not met: full-screen splash, no dismiss.
class HardUpdate extends ActionableUpdateDecision {
  const HardUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });
}

/// Server-declared outage: full-screen splash with a retry control.
class Maintenance extends ActionableUpdateDecision {
  const Maintenance({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });
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

int _mapHash(Map<String, String>? map) {
  if (map == null) return 0;
  final entryHashes = map.entries.map((e) => Object.hash(e.key, e.value));
  return Object.hashAllUnordered(entryHashes);
}
