// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DownloadableImpl _$$DownloadableImplFromJson(Map<String, dynamic> json) =>
    _$DownloadableImpl(
      id: json['id'] as int?,
      pguid: json['pguid'] as String,
      guid: json['guid'] as String,
      url: json['url'] as String,
      directory: json['directory'] as String,
      filename: json['filename'] as String,
      taskId: json['taskId'] as String,
      state: $enumDecode(_$DownloadStateEnumMap, json['state']),
      percentage: json['percentage'] as int? ?? 0,
    );

Map<String, dynamic> _$$DownloadableImplToJson(_$DownloadableImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pguid': instance.pguid,
      'guid': instance.guid,
      'url': instance.url,
      'directory': instance.directory,
      'filename': instance.filename,
      'taskId': instance.taskId,
      'state': _$DownloadStateEnumMap[instance.state]!,
      'percentage': instance.percentage,
    };

const _$DownloadStateEnumMap = {
  DownloadState.none: 'none',
  DownloadState.queued: 'queued',
  DownloadState.downloading: 'downloading',
  DownloadState.failed: 'failed',
  DownloadState.cancelled: 'cancelled',
  DownloadState.paused: 'paused',
  DownloadState.downloaded: 'downloaded',
};
