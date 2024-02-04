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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TranscriptUrl _$TranscriptUrlFromJson(Map<String, dynamic> json) {
  return _TranscriptUrl.fromJson(json);
}

/// @nodoc
mixin _$TranscriptUrl {
  String get url => throw _privateConstructorUsedError;
  TranscriptFormat get type => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get rel => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TranscriptUrlCopyWith<TranscriptUrl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptUrlCopyWith<$Res> {
  factory $TranscriptUrlCopyWith(
          TranscriptUrl value, $Res Function(TranscriptUrl) then) =
      _$TranscriptUrlCopyWithImpl<$Res, TranscriptUrl>;
  @useResult
  $Res call(
      {String url,
      TranscriptFormat type,
      String language,
      String rel,
      DateTime? lastUpdated});
}

/// @nodoc
class _$TranscriptUrlCopyWithImpl<$Res, $Val extends TranscriptUrl>
    implements $TranscriptUrlCopyWith<$Res> {
  _$TranscriptUrlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? language = null,
    Object? rel = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TranscriptFormat,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      rel: null == rel
          ? _value.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TranscriptUrlImplCopyWith<$Res>
    implements $TranscriptUrlCopyWith<$Res> {
  factory _$$TranscriptUrlImplCopyWith(
          _$TranscriptUrlImpl value, $Res Function(_$TranscriptUrlImpl) then) =
      __$$TranscriptUrlImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String url,
      TranscriptFormat type,
      String language,
      String rel,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$TranscriptUrlImplCopyWithImpl<$Res>
    extends _$TranscriptUrlCopyWithImpl<$Res, _$TranscriptUrlImpl>
    implements _$$TranscriptUrlImplCopyWith<$Res> {
  __$$TranscriptUrlImplCopyWithImpl(
      _$TranscriptUrlImpl _value, $Res Function(_$TranscriptUrlImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? type = null,
    Object? language = null,
    Object? rel = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$TranscriptUrlImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TranscriptFormat,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      rel: null == rel
          ? _value.rel
          : rel // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptUrlImpl
    with DiagnosticableTreeMixin
    implements _TranscriptUrl {
  const _$TranscriptUrlImpl(
      {required this.url,
      required this.type,
      this.language = '',
      this.rel = '',
      this.lastUpdated});

  factory _$TranscriptUrlImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptUrlImplFromJson(json);

  @override
  final String url;
  @override
  final TranscriptFormat type;
  @override
  @JsonKey()
  final String language;
  @override
  @JsonKey()
  final String rel;
  @override
  final DateTime? lastUpdated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TranscriptUrl(url: $url, type: $type, language: $language, rel: $rel, lastUpdated: $lastUpdated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TranscriptUrl'))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('language', language))
      ..add(DiagnosticsProperty('rel', rel))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptUrlImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.rel, rel) || other.rel == rel) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, url, type, language, rel, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptUrlImplCopyWith<_$TranscriptUrlImpl> get copyWith =>
      __$$TranscriptUrlImplCopyWithImpl<_$TranscriptUrlImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranscriptUrlImplToJson(
      this,
    );
  }
}

abstract class _TranscriptUrl implements TranscriptUrl {
  const factory _TranscriptUrl(
      {required final String url,
      required final TranscriptFormat type,
      final String language,
      final String rel,
      final DateTime? lastUpdated}) = _$TranscriptUrlImpl;

  factory _TranscriptUrl.fromJson(Map<String, dynamic> json) =
      _$TranscriptUrlImpl.fromJson;

  @override
  String get url;
  @override
  TranscriptFormat get type;
  @override
  String get language;
  @override
  String get rel;
  @override
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$TranscriptUrlImplCopyWith<_$TranscriptUrlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Transcript _$TranscriptFromJson(Map<String, dynamic> json) {
  return _Transcript.fromJson(json);
}

/// @nodoc
mixin _$Transcript {
  int get id => throw _privateConstructorUsedError;
  String get guid => throw _privateConstructorUsedError;
  List<Subtitle> get subtitles => throw _privateConstructorUsedError;
  bool get filtered => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

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
      {int id,
      String guid,
      List<Subtitle> subtitles,
      bool filtered,
      DateTime? lastUpdated});
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
    Object? id = null,
    Object? guid = null,
    Object? subtitles = null,
    Object? filtered = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      {int id,
      String guid,
      List<Subtitle> subtitles,
      bool filtered,
      DateTime? lastUpdated});
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
    Object? id = null,
    Object? guid = null,
    Object? subtitles = null,
    Object? filtered = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$TranscriptImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TranscriptImpl with DiagnosticableTreeMixin implements _Transcript {
  const _$TranscriptImpl(
      {required this.id,
      required this.guid,
      final List<Subtitle> subtitles = const <Subtitle>[],
      this.filtered = false,
      this.lastUpdated})
      : _subtitles = subtitles;

  factory _$TranscriptImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranscriptImplFromJson(json);

  @override
  final int id;
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
  final DateTime? lastUpdated;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Transcript(id: $id, guid: $guid, subtitles: $subtitles, filtered: $filtered, lastUpdated: $lastUpdated)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Transcript'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('guid', guid))
      ..add(DiagnosticsProperty('subtitles', subtitles))
      ..add(DiagnosticsProperty('filtered', filtered))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            const DeepCollectionEquality()
                .equals(other._subtitles, _subtitles) &&
            (identical(other.filtered, filtered) ||
                other.filtered == filtered) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, guid,
      const DeepCollectionEquality().hash(_subtitles), filtered, lastUpdated);

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
      {required final int id,
      required final String guid,
      final List<Subtitle> subtitles,
      final bool filtered,
      final DateTime? lastUpdated}) = _$TranscriptImpl;

  factory _Transcript.fromJson(Map<String, dynamic> json) =
      _$TranscriptImpl.fromJson;

  @override
  int get id;
  @override
  String get guid;
  @override
  List<Subtitle> get subtitles;
  @override
  bool get filtered;
  @override
  DateTime? get lastUpdated;
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
