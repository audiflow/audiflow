// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChapterImpl _$$ChapterImplFromJson(Map<String, dynamic> json) =>
    _$ChapterImpl(
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      url: json['url'] as String?,
      toc: json['toc'] as bool? ?? true,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ChapterImplToJson(_$ChapterImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'url': instance.url,
      'toc': instance.toc,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };
