// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transcript _$TranscriptFromJson(Map<String, dynamic> json) {
  return _Transcript.fromJson(json);
}

/// @nodoc
mixin _$Transcript {
  int? get id => throw _privateConstructorUsedError;
  String get pguid => throw _privateConstructorUsedError;
  String get guid => throw _privateConstructorUsedError;
  List<Subtitle> get subtitles => throw _privateConstructorUsedError;
  bool get filtered => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TranscriptCopyWith<Transcript> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptCopyWith<$Res> {
  factory $TranscriptCopyWith(
          Transcript value, $Res Function(Transcript) then) =
      _$TranscriptCopyWithImpl<$Res, Transcript>;
  @useResult
  $Res call(
      {int? id,
      String pguid,
      String guid,
      List<Subtitle> subtitles,
      bool filtered});
}

/// @nodoc
class _$TranscriptCopyWithImpl<$Res, $Val extends Transcript>
    implements $TranscriptCopyWith<$Res> {
  _$TranscriptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? pguid = null,
    Object? guid = null,
    Object? subtitles = null,
    Object? filtered = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      subtitles: null == subtitles
          ? _value.subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      filtered: null == filtered
          ? _value.filtered
          : filtered // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranscriptImplCopyWith<$Res>
    implements $TranscriptCopyWith<$Res> {
  factory _$$TranscriptImplCopyWith(
          _$TranscriptImpl value, $Res Function(_$TranscriptImpl) then) =
      __$$TranscriptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String pguid,
      String guid,
      List<Subtitle> subtitles,
      bool filtered});
}

/// @nodoc
class __$$TranscriptImplCopyWithImpl<$Res>
    extends _$TranscriptCopyWithImpl<$Res, _$TranscriptImpl>
    implements _$$TranscriptImplCopyWith<$Res> {
  __$$TranscriptImplCopyWithImpl(
      _$TranscriptImpl _value, $Res Function(_$TranscriptImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? pguid = null,
    Object? guid = null,
    Object? subtitles = null,
    Object? filtered = null,
  }) {
    return _then(_$TranscriptImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      subtitles: null == subtitles
          ? _value._subtitles
          : subtitles // ignore: cast_nullable_to_non_nullable
              as List<Subtitle>,
      filtered: null == filtered
          ? _value.filtered
          : filtered // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptImpl with DiagnosticableTreeMixin implements _Transcript {
  const _$TranscriptImpl(
      {this.id,
      required this.pguid,
      required this.guid,
      final List<Subtitle> subtitles = const <Subtitle>[],
      this.filtered = false})
      : _subtitles = subtitles;

  factory _$TranscriptImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptImplFromJson(json);

  @override
  final int? id;
  @override
  final String pguid;
  @override
  final String guid;
  final List<Subtitle> _subtitles;
  @override
  @JsonKey()
  List<Subtitle> get subtitles {
    if (_subtitles is EqualUnmodifiableListView) return _subtitles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtitles);
  }

  @override
  @JsonKey()
  final bool filtered;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Transcript(id: $id, pguid: $pguid, guid: $guid, subtitles: $subtitles, filtered: $filtered)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Transcript'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('pguid', pguid))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('subtitles', subtitles))
      ..add(DiagnosticsProperty('filtered', filtered));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            const DeepCollectionEquality()
                .equals(other._subtitles, _subtitles) &&
            (identical(other.filtered, filtered) ||
                other.filtered == filtered));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, pguid, guid,
      const DeepCollectionEquality().hash(_subtitles), filtered);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptImplCopyWith<_$TranscriptImpl> get copyWith =>
      __$$TranscriptImplCopyWithImpl<_$TranscriptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptImplToJson(
      this,
    );
  }
}

abstract class _Transcript implements Transcript {
  const factory _Transcript(
      {final int? id,
      required final String pguid,
      required final String guid,
      final List<Subtitle> subtitles,
      final bool filtered}) = _$TranscriptImpl;

  factory _Transcript.fromJson(Map<String, dynamic> json) =
      _$TranscriptImpl.fromJson;

  @override
  int? get id;
  @override
  String get pguid;
  @override
  String get guid;
  @override
  List<Subtitle> get subtitles;
  @override
  bool get filtered;
  @override
  @JsonKey(ignore: true)
  _$$TranscriptImplCopyWith<_$TranscriptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Subtitle _$SubtitleFromJson(Map<String, dynamic> json) {
  return _Subtitle.fromJson(json);
}

/// @nodoc
mixin _$Subtitle {
  int get index => throw _privateConstructorUsedError;
  Duration get start => throw _privateConstructorUsedError;
  Duration? get end => throw _privateConstructorUsedError;
  String? get data => throw _privateConstructorUsedError;
  String get speaker => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubtitleCopyWith<Subtitle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleCopyWith<$Res> {
  factory $SubtitleCopyWith(Subtitle value, $Res Function(Subtitle) then) =
      _$SubtitleCopyWithImpl<$Res, Subtitle>;
  @useResult
  $Res call(
      {int index, Duration start, Duration? end, String? data, String speaker});
}

/// @nodoc
class _$SubtitleCopyWithImpl<$Res, $Val extends Subtitle>
    implements $SubtitleCopyWith<$Res> {
  _$SubtitleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? start = null,
    Object? end = freezed,
    Object? data = freezed,
    Object? speaker = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String?,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubtitleImplCopyWith<$Res>
    implements $SubtitleCopyWith<$Res> {
  factory _$$SubtitleImplCopyWith(
          _$SubtitleImpl value, $Res Function(_$SubtitleImpl) then) =
      __$$SubtitleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int index, Duration start, Duration? end, String? data, String speaker});
}

/// @nodoc
class __$$SubtitleImplCopyWithImpl<$Res>
    extends _$SubtitleCopyWithImpl<$Res, _$SubtitleImpl>
    implements _$$SubtitleImplCopyWith<$Res> {
  __$$SubtitleImplCopyWithImpl(
      _$SubtitleImpl _value, $Res Function(_$SubtitleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? start = null,
    Object? end = freezed,
    Object? data = freezed,
    Object? speaker = null,
  }) {
    return _then(_$SubtitleImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as Duration,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as Duration?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String?,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtitleImpl with DiagnosticableTreeMixin implements _Subtitle {
  const _$SubtitleImpl(
      {required this.index,
      required this.start,
      this.end,
      this.data,
      this.speaker = ''});

  factory _$SubtitleImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtitleImplFromJson(json);

  @override
  final int index;
  @override
  final Duration start;
  @override
  final Duration? end;
  @override
  final String? data;
  @override
  @JsonKey()
  final String speaker;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Subtitle(index: $index, start: $start, end: $end, data: $data, speaker: $speaker)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Subtitle'))
      ..add(DiagnosticsProperty('index', index))
      ..add(DiagnosticsProperty('start', start))
      ..add(DiagnosticsProperty('end', end))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('speaker', speaker));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.speaker, speaker) || other.speaker == speaker));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, index, start, end, data, speaker);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleImplCopyWith<_$SubtitleImpl> get copyWith =>
      __$$SubtitleImplCopyWithImpl<_$SubtitleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtitleImplToJson(
      this,
    );
  }
}

abstract class _Subtitle implements Subtitle {
  const factory _Subtitle(
      {required final int index,
      required final Duration start,
      final Duration? end,
      final String? data,
      final String speaker}) = _$SubtitleImpl;

  factory _Subtitle.fromJson(Map<String, dynamic> json) =
      _$SubtitleImpl.fromJson;

  @override
  int get index;
  @override
  Duration get start;
  @override
  Duration? get end;
  @override
  String? get data;
  @override
  String get speaker;
  @override
  @JsonKey(ignore: true)
  _$$SubtitleImplCopyWith<_$SubtitleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
