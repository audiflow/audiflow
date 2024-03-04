// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastPreviewImpl _$$PodcastPreviewImplFromJson(Map<String, dynamic> json) =>
    _$PodcastPreviewImpl(
      guid: json['guid'] as String,
      collectionId: json['collectionId'] as int,
      feedUrl: json['feedUrl'] as String?,
      title: json['title'] as String,
      thumbImageUrl: json['thumbImageUrl'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$PodcastPreviewImplToJson(
        _$PodcastPreviewImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'collectionId': instance.collectionId,
      'feedUrl': instance.feedUrl,
      'title': instance.title,
      'thumbImageUrl': instance.thumbImageUrl,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

_$PodcastMetadataImpl _$$PodcastMetadataImplFromJson(
        Map<String, dynamic> json) =>
    _$PodcastMetadataImpl(
      guid: json['guid'] as String,
      collectionId: json['collectionId'] as int,
      feedUrl: json['feedUrl'] as String?,
      title: json['title'] as String,
      thumbImageUrl: json['thumbImageUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      copyright: json['copyright'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
    );

Map<String, dynamic> _$$PodcastMetadataImplToJson(
        _$PodcastMetadataImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'collectionId': instance.collectionId,
      'feedUrl': instance.feedUrl,
      'title': instance.title,
      'thumbImageUrl': instance.thumbImageUrl,
      'imageUrl': instance.imageUrl,
      'copyright': instance.copyright,
      'releaseDate': instance.releaseDate.toIso8601String(),
    };

_$PodcastImpl _$$PodcastImplFromJson(Map<String, dynamic> json) =>
    _$PodcastImpl(
      guid: json['guid'] as String,
      collectionId: json['collectionId'] as int,
      feedUrl: json['feedUrl'] as String?,
      linkUrl: json['linkUrl'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      copyright: json['copyright'] as String,
      thumbImageUrl: json['thumbImageUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      funding: (json['funding'] as List<dynamic>?)
              ?.map((e) => Funding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      persons: (json['persons'] as List<dynamic>?)
              ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PodcastImplToJson(_$PodcastImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'collectionId': instance.collectionId,
      'feedUrl': instance.feedUrl,
      'linkUrl': instance.linkUrl,
      'title': instance.title,
      'description': instance.description,
      'copyright': instance.copyright,
      'thumbImageUrl': instance.thumbImageUrl,
      'imageUrl': instance.imageUrl,
      'releaseDate': instance.releaseDate.toIso8601String(),
      'funding': instance.funding.map((e) => e.toJson()).toList(),
      'persons': instance.persons.map((e) => e.toJson()).toList(),
    };

_$PodcastStatsImpl _$$PodcastStatsImplFromJson(Map<String, dynamic> json) =>
    _$PodcastStatsImpl(
      guid: json['guid'] as String,
      subscribedDate: json['subscribedDate'] == null
          ? null
          : DateTime.parse(json['subscribedDate'] as String),
      viewMode: $enumDecodeNullable(
              _$PodcastDetailViewModeEnumMap, json['viewMode']) ??
          PodcastDetailViewMode.episodes,
      ascend: json['ascend'] as bool? ?? false,
      lastCheckedAt: json['lastCheckedAt'] == null
          ? null
          : DateTime.parse(json['lastCheckedAt'] as String),
    );

Map<String, dynamic> _$$PodcastStatsImplToJson(_$PodcastStatsImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'subscribedDate': instance.subscribedDate?.toIso8601String(),
      'viewMode': _$PodcastDetailViewModeEnumMap[instance.viewMode]!,
      'ascend': instance.ascend,
      'lastCheckedAt': instance.lastCheckedAt?.toIso8601String(),
    };

const _$PodcastDetailViewModeEnumMap = {
  PodcastDetailViewMode.episodes: 'episodes',
  PodcastDetailViewMode.seasons: 'seasons',
  PodcastDetailViewMode.played: 'played',
  PodcastDetailViewMode.unplayed: 'unplayed',
  PodcastDetailViewMode.downloaded: 'downloaded',
};
