import 'package:pub_semver/pub_semver.dart';

import '../constants.dart';
import '../models/force_update_config.dart';
import '../models/update_decision.dart';

/// Reasons a [ForceUpdateConfig] should be rejected at parse time.
enum ForceUpdateConfigInvalidReason {
  unsupportedSchemaVersion,
  unparseableMinVersion,
  unparseableRecommendedVersion,
  recommendedBelowMin,
}

/// Returns the specific reason a config is invalid, or null when it passes.
///
/// Callers use this to decide whether to drop a fetched config (fail-open)
/// and to surface telemetry for the failure mode.
ForceUpdateConfigInvalidReason? configValidationFailure(
  ForceUpdateConfig config,
) {
  if (forceUpdateSupportedSchemaVersion < config.schemaVersion) {
    return ForceUpdateConfigInvalidReason.unsupportedSchemaVersion;
  }
  final Version min;
  try {
    min = Version.parse(config.minVersion);
  } on FormatException {
    return ForceUpdateConfigInvalidReason.unparseableMinVersion;
  }
  final Version rec;
  try {
    rec = Version.parse(config.recommendedVersion);
  } on FormatException {
    return ForceUpdateConfigInvalidReason.unparseableRecommendedVersion;
  }
  if (rec < min) {
    return ForceUpdateConfigInvalidReason.recommendedBelowMin;
  }
  return null;
}

/// Convenience wrapper for callers that only need a yes/no answer.
bool configIsValid(ForceUpdateConfig config) =>
    configValidationFailure(config) == null;

/// Pure decision function. Caller MUST validate the config via
/// [configValidationFailure] (or [configIsValid]) first.
///
/// Passing an invalid config will throw [FormatException] when the
/// version strings cannot be parsed; debug builds assert validity to
/// surface misuse in tests.
UpdateDecision evaluate({
  required ForceUpdateConfig config,
  required Version currentVersion,
}) {
  assert(
    configIsValid(config),
    'evaluate called with invalid config; call configValidationFailure first',
  );
  if (config.maintenanceMode) {
    return Maintenance(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }

  final min = Version.parse(config.minVersion);
  final rec = Version.parse(config.recommendedVersion);

  if (currentVersion < min) {
    return HardUpdate(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }
  if (currentVersion < rec) {
    return SoftUpdate(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }
  return const NoUpdate();
}
