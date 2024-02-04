// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastImpl _$$PodcastImplFromJson(Map<String, dynamic> json) =>
    _$PodcastImpl(
      id: json['id'] as int?,
      guid: json['guid'] as String,
      url: json['url'] as String,
      link: json['link'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbImageUrl: json['thumbImageUrl'] as String?,
      copyright: json['copyright'] as String?,
      subscribedDate: json['subscribedDate'] == null
          ? null
          : DateTime.parse(json['subscribedDate'] as String),
      funding: (json['funding'] as List<dynamic>?)
              ?.map((e) => Funding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      persons: (json['persons'] as List<dynamic>?)
              ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$PodcastImplToJson(_$PodcastImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'url': instance.url,
      'link': instance.link,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'thumbImageUrl': instance.thumbImageUrl,
      'copyright': instance.copyright,
      'subscribedDate': instance.subscribedDate?.toIso8601String(),
      'funding': instance.funding,
      'seasons': instance.seasons,
      'episodes': instance.episodes,
      'persons': instance.persons,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
