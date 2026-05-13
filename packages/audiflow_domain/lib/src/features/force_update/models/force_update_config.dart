// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'force_update_config.freezed.dart';
part 'force_update_config.g.dart';

/// Force-update configuration fetched from the remote endpoint.
///
/// Drives the force-update gate: when the running app version is below
/// [minVersion] (or [maintenanceMode] is true), the user is blocked until
/// they update. [recommendedVersion] is used to surface a non-blocking
/// "update available" hint.
@Freezed(toJson: true, fromJson: true)
abstract class ForceUpdateConfig with _$ForceUpdateConfig {
  const factory ForceUpdateConfig({
    required int schemaVersion,
    required String minVersion,
    required String recommendedVersion,
    required bool maintenanceMode,
    required String messageKey,
    Map<String, String>? messageOverride,
    String? updateUrl,
  }) = _ForceUpdateConfig;

  factory ForceUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$ForceUpdateConfigFromJson(json);
}
