// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EpisodeImpl _$$EpisodeImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeImpl(
      guid: json['guid'] as String,
      pguid: json['pguid'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String?,
      link: json['link'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbImageUrl: json['thumbImageUrl'] as String?,
      publicationDate: json['publicationDate'] == null
          ? null
          : DateTime.parse(json['publicationDate'] as String),
      contentUrl: json['contentUrl'] as String?,
      author: json['author'] as String?,
      season: json['season'] as int?,
      episode: json['episode'] as int?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      chaptersUrl: json['chaptersUrl'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transcriptUrls: (json['transcriptUrls'] as List<dynamic>?)
              ?.map((e) => TranscriptUrl.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      persons: (json['persons'] as List<dynamic>?)
              ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EpisodeImplToJson(_$EpisodeImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'pguid': instance.pguid,
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'link': instance.link,
      'imageUrl': instance.imageUrl,
      'thumbImageUrl': instance.thumbImageUrl,
      'publicationDate': instance.publicationDate?.toIso8601String(),
      'contentUrl': instance.contentUrl,
      'author': instance.author,
      'season': instance.season,
      'episode': instance.episode,
      'duration': instance.duration?.inMicroseconds,
      'chaptersUrl': instance.chaptersUrl,
      'chapters': instance.chapters,
      'transcriptUrls': instance.transcriptUrls,
      'persons': instance.persons,
    };

_$EpisodeStatsImpl _$$EpisodeStatsImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeStatsImpl(
      id: json['id'] as int? ?? 0,
      guid: json['guid'] as String,
      position: json['position'] == null
          ? Duration.zero
          : Duration(microseconds: json['position'] as int),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      played: json['played'] as bool? ?? false,
      playCount: json['playCount'] as int? ?? 0,
      playTotal: json['playTotal'] == null
          ? Duration.zero
          : Duration(microseconds: json['playTotal'] as int),
      inQueue: json['inQueue'] as bool? ?? false,
      downloaded: json['downloaded'] as bool? ?? false,
    );

Map<String, dynamic> _$$EpisodeStatsImplToJson(_$EpisodeStatsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'position': instance.position.inMicroseconds,
      'duration': instance.duration?.inMicroseconds,
      'played': instance.played,
      'playCount': instance.playCount,
      'playTotal': instance.playTotal.inMicroseconds,
      'inQueue': instance.inQueue,
      'downloaded': instance.downloaded,
    };
