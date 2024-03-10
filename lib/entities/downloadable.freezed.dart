// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloadable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Downloadable _$DownloadableFromJson(Map<String, dynamic> json) {
  return _Downloadable.fromJson(json);
}

/// @nodoc
mixin _$Downloadable {
  /// The GUID for an associated podcast.
  String get pguid => throw _privateConstructorUsedError;

  /// Unique identifier for the episode.
  String get guid => throw _privateConstructorUsedError;

  /// Unique identifier for the download
  String get url => throw _privateConstructorUsedError;

  /// Destination directory
  String get directory => throw _privateConstructorUsedError;

  /// Name of file
  String get filename => throw _privateConstructorUsedError;

  /// Current task ID for the download
  String get taskId => throw _privateConstructorUsedError;

  /// Current state of the download
  DownloadState get state => throw _privateConstructorUsedError;

  /// Percentage of MP3 downloaded
  int get percentage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DownloadableCopyWith<Downloadable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadableCopyWith<$Res> {
  factory $DownloadableCopyWith(
          Downloadable value, $Res Function(Downloadable) then) =
      _$DownloadableCopyWithImpl<$Res, Downloadable>;
  @useResult
  $Res call(
      {String pguid,
      String guid,
      String url,
      String directory,
      String filename,
      String taskId,
      DownloadState state,
      int percentage});
}

/// @nodoc
class _$DownloadableCopyWithImpl<$Res, $Val extends Downloadable>
    implements $DownloadableCopyWith<$Res> {
  _$DownloadableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? guid = null,
    Object? url = null,
    Object? directory = null,
    Object? filename = null,
    Object? taskId = null,
    Object? state = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      directory: null == directory
          ? _value.directory
          : directory // ignore: cast_nullable_to_non_nullable
              as String,
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadableImplCopyWith<$Res>
    implements $DownloadableCopyWith<$Res> {
  factory _$$DownloadableImplCopyWith(
          _$DownloadableImpl value, $Res Function(_$DownloadableImpl) then) =
      __$$DownloadableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String pguid,
      String guid,
      String url,
      String directory,
      String filename,
      String taskId,
      DownloadState state,
      int percentage});
}

/// @nodoc
class __$$DownloadableImplCopyWithImpl<$Res>
    extends _$DownloadableCopyWithImpl<$Res, _$DownloadableImpl>
    implements _$$DownloadableImplCopyWith<$Res> {
  __$$DownloadableImplCopyWithImpl(
      _$DownloadableImpl _value, $Res Function(_$DownloadableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pguid = null,
    Object? guid = null,
    Object? url = null,
    Object? directory = null,
    Object? filename = null,
    Object? taskId = null,
    Object? state = null,
    Object? percentage = null,
  }) {
    return _then(_$DownloadableImpl(
      pguid: null == pguid
          ? _value.pguid
          : pguid // ignore: cast_nullable_to_non_nullable
              as String,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      directory: null == directory
          ? _value.directory
          : directory // ignore: cast_nullable_to_non_nullable
              as String,
      filename: null == filename
          ? _value.filename
          : filename // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as DownloadState,
      percentage: null == percentage
          ? _value.percentage
          : percentage // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadableImpl implements _Downloadable {
  const _$DownloadableImpl(
      {required this.pguid,
      required this.guid,
      required this.url,
      required this.directory,
      required this.filename,
      required this.taskId,
      required this.state,
      this.percentage = 0});

  factory _$DownloadableImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadableImplFromJson(json);

  /// The GUID for an associated podcast.
  @override
  final String pguid;

  /// Unique identifier for the episode.
  @override
  final String guid;

  /// Unique identifier for the download
  @override
  final String url;

  /// Destination directory
  @override
  final String directory;

  /// Name of file
  @override
  final String filename;

  /// Current task ID for the download
  @override
  final String taskId;

  /// Current state of the download
  @override
  final DownloadState state;

  /// Percentage of MP3 downloaded
  @override
  @JsonKey()
  final int percentage;

  @override
  String toString() {
    return 'Downloadable(pguid: $pguid, guid: $guid, url: $url, directory: $directory, filename: $filename, taskId: $taskId, state: $state, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadableImpl &&
            (identical(other.pguid, pguid) || other.pguid == pguid) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.directory, directory) ||
                other.directory == directory) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pguid, guid, url, directory,
      filename, taskId, state, percentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadableImplCopyWith<_$DownloadableImpl> get copyWith =>
      __$$DownloadableImplCopyWithImpl<_$DownloadableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadableImplToJson(
      this,
    );
  }
}

abstract class _Downloadable implements Downloadable {
  const factory _Downloadable(
      {required final String pguid,
      required final String guid,
      required final String url,
      required final String directory,
      required final String filename,
      required final String taskId,
      required final DownloadState state,
      final int percentage}) = _$DownloadableImpl;

  factory _Downloadable.fromJson(Map<String, dynamic> json) =
      _$DownloadableImpl.fromJson;

  @override

  /// The GUID for an associated podcast.
  String get pguid;
  @override

  /// Unique identifier for the episode.
  String get guid;
  @override

  /// Unique identifier for the download
  String get url;
  @override

  /// Destination directory
  String get directory;
  @override

  /// Name of file
  String get filename;
  @override

  /// Current task ID for the download
  String get taskId;
  @override

  /// Current state of the download
  DownloadState get state;
  @override

  /// Percentage of MP3 downloaded
  int get percentage;
  @override
  @JsonKey(ignore: true)
  _$$DownloadableImplCopyWith<_$DownloadableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
