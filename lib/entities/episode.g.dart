// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EpisodeImpl _$$EpisodeImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeImpl(
      id: json['id'] as int?,
      guid: json['guid'] as String,
      pguid: json['pguid'] as String,
      filepath: json['filepath'] as String?,
      filename: json['filename'] as String?,
      podcast: json['podcast'] as String,
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
      duration: json['duration'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      played: json['played'] as bool? ?? false,
      chaptersUrl: json['chaptersUrl'] as String?,
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      chapterIndex: json['chapterIndex'] as int?,
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
      'id': instance.id,
      'guid': instance.guid,
      'pguid': instance.pguid,
      'filepath': instance.filepath,
      'filename': instance.filename,
      'podcast': instance.podcast,
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
      'duration': instance.duration,
      'position': instance.position,
      'played': instance.played,
      'chaptersUrl': instance.chaptersUrl,
      'chapters': instance.chapters,
      'chapterIndex': instance.chapterIndex,
      'transcriptUrls': instance.transcriptUrls,
      'persons': instance.persons,
    };
