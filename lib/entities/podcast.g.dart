// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastImpl _$$PodcastImplFromJson(Map<String, dynamic> json) =>
    _$PodcastImpl(
      guid: json['guid'] as String,
      collectionId: json['collectionId'] as int,
      feedUrl: json['feedUrl'] as String,
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

_$PodcastSearchResultItemImpl _$$PodcastSearchResultItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PodcastSearchResultItemImpl(
      guid: json['guid'] as String,
      collectionId: json['collectionId'] as int,
      feedUrl: json['feedUrl'] as String,
      title: json['title'] as String,
      thumbImageUrl: json['thumbImageUrl'] as String,
      imageUrl: json['imageUrl'] as String,
      copyright: json['copyright'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
    );

Map<String, dynamic> _$$PodcastSearchResultItemImplToJson(
        _$PodcastSearchResultItemImpl instance) =>
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

_$PodcastStatsImpl _$$PodcastStatsImplFromJson(Map<String, dynamic> json) =>
    _$PodcastStatsImpl(
      id: json['id'] as int? ?? 0,
      guid: json['guid'] as String,
      subscribedDate: json['subscribedDate'] == null
          ? null
          : DateTime.parse(json['subscribedDate'] as String),
      playTotal: json['playTotal'] == null
          ? Duration.zero
          : Duration(microseconds: json['playTotal'] as int),
      viewMode: $enumDecodeNullable(
              _$PodcastDetailViewModeEnumMap, json['viewMode']) ??
          PodcastDetailViewMode.episodes,
      ascend: json['ascend'] as bool? ?? false,
    );

Map<String, dynamic> _$$PodcastStatsImplToJson(_$PodcastStatsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'subscribedDate': instance.subscribedDate?.toIso8601String(),
      'playTotal': instance.playTotal.inMicroseconds,
      'viewMode': _$PodcastDetailViewModeEnumMap[instance.viewMode]!,
      'ascend': instance.ascend,
    };

const _$PodcastDetailViewModeEnumMap = {
  PodcastDetailViewMode.episodes: 'episodes',
  PodcastDetailViewMode.seasons: 'seasons',
  PodcastDetailViewMode.played: 'played',
  PodcastDetailViewMode.unplayed: 'unplayed',
  PodcastDetailViewMode.downloaded: 'downloaded',
};
