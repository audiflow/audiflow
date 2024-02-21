// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueImpl _$$QueueImplFromJson(Map<String, dynamic> json) => _$QueueImpl(
      primary: (json['primary'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      adhoc:
          (json['adhoc'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
    );

Map<String, dynamic> _$$QueueImplToJson(_$QueueImpl instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'adhoc': instance.adhoc,
    };
