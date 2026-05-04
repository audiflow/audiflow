// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForceUpdateConfig _$ForceUpdateConfigFromJson(Map<String, dynamic> json) =>
    _ForceUpdateConfig(
      schemaVersion: (json['schema_version'] as num).toInt(),
      minVersion: json['min_version'] as String,
      recommendedVersion: json['recommended_version'] as String,
      maintenanceMode: json['maintenance_mode'] as bool,
      messageKey: json['message_key'] as String,
      messageOverride: (json['message_override'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      updateUrl: json['update_url'] as String?,
    );

Map<String, dynamic> _$ForceUpdateConfigToJson(_ForceUpdateConfig instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'min_version': instance.minVersion,
      'recommended_version': instance.recommendedVersion,
      'maintenance_mode': instance.maintenanceMode,
      'message_key': instance.messageKey,
      'message_override': instance.messageOverride,
      'update_url': instance.updateUrl,
    };
