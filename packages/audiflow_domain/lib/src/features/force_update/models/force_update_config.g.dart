// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ForceUpdateConfig _$ForceUpdateConfigFromJson(Map<String, dynamic> json) =>
    _ForceUpdateConfig(
      schemaVersion: (json['schemaVersion'] as num).toInt(),
      minVersion: json['minVersion'] as String,
      recommendedVersion: json['recommendedVersion'] as String,
      maintenanceMode: json['maintenanceMode'] as bool,
      messageKey: json['messageKey'] as String,
      messageOverride: (json['messageOverride'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      updateUrl: json['updateUrl'] as String?,
    );

Map<String, dynamic> _$ForceUpdateConfigToJson(_ForceUpdateConfig instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'minVersion': instance.minVersion,
      'recommendedVersion': instance.recommendedVersion,
      'maintenanceMode': instance.maintenanceMode,
      'messageKey': instance.messageKey,
      'messageOverride': instance.messageOverride,
      'updateUrl': instance.updateUrl,
    };
