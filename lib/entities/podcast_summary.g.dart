// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastSummaryImpl _$$PodcastSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PodcastSummaryImpl(
      id: json['id'] as int?,
      guid: json['guid'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      thumbImageUrl: json['thumbImageUrl'] as String,
      copyright: json['copyright'] as String,
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.parse(json['releaseDate'] as String),
      subscribedDate: json['subscribedDate'] == null
          ? null
          : DateTime.parse(json['subscribedDate'] as String),
    );

Map<String, dynamic> _$$PodcastSummaryImplToJson(
        _$PodcastSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'url': instance.url,
      'title': instance.title,
      'thumbImageUrl': instance.thumbImageUrl,
      'copyright': instance.copyright,
      'releaseDate': instance.releaseDate?.toIso8601String(),
      'subscribedDate': instance.subscribedDate?.toIso8601String(),
    };
