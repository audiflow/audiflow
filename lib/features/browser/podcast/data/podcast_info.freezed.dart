// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastInfoState {
  Podcast? get podcast => throw _privateConstructorUsedError;
  PodcastStats? get stats => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;

  /// Create a copy of PodcastInfoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastInfoStateCopyWith<PodcastInfoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastInfoStateCopyWith<$Res> {
  factory $PodcastInfoStateCopyWith(
          PodcastInfoState value, $Res Function(PodcastInfoState) then) =
      _$PodcastInfoStateCopyWithImpl<$Res, PodcastInfoState>;
  @useResult
  $Res call({Podcast? podcast, PodcastStats? stats, AppException? error});
}

/// @nodoc
class _$PodcastInfoStateCopyWithImpl<$Res, $Val extends PodcastInfoState>
    implements $PodcastInfoStateCopyWith<$Res> {
  _$PodcastInfoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastInfoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = freezed,
    Object? stats = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      podcast: freezed == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastInfoStateImplCopyWith<$Res>
    implements $PodcastInfoStateCopyWith<$Res> {
  factory _$$PodcastInfoStateImplCopyWith(_$PodcastInfoStateImpl value,
          $Res Function(_$PodcastInfoStateImpl) then) =
      __$$PodcastInfoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Podcast? podcast, PodcastStats? stats, AppException? error});
}

/// @nodoc
class __$$PodcastInfoStateImplCopyWithImpl<$Res>
    extends _$PodcastInfoStateCopyWithImpl<$Res, _$PodcastInfoStateImpl>
    implements _$$PodcastInfoStateImplCopyWith<$Res> {
  __$$PodcastInfoStateImplCopyWithImpl(_$PodcastInfoStateImpl _value,
      $Res Function(_$PodcastInfoStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastInfoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = freezed,
    Object? stats = freezed,
    Object? error = freezed,
  }) {
    return _then(_$PodcastInfoStateImpl(
      podcast: freezed == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ));
  }
}

/// @nodoc

class _$PodcastInfoStateImpl implements _PodcastInfoState {
  const _$PodcastInfoStateImpl({this.podcast, this.stats, this.error});

  @override
  final Podcast? podcast;
  @override
  final PodcastStats? stats;
  @override
  final AppException? error;

  @override
  String toString() {
    return 'PodcastInfoState(podcast: $podcast, stats: $stats, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastInfoStateImpl &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, podcast, stats, error);

  /// Create a copy of PodcastInfoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastInfoStateImplCopyWith<_$PodcastInfoStateImpl> get copyWith =>
      __$$PodcastInfoStateImplCopyWithImpl<_$PodcastInfoStateImpl>(
          this, _$identity);
}

abstract class _PodcastInfoState implements PodcastInfoState {
  const factory _PodcastInfoState(
      {final Podcast? podcast,
      final PodcastStats? stats,
      final AppException? error}) = _$PodcastInfoStateImpl;

  @override
  Podcast? get podcast;
  @override
  PodcastStats? get stats;
  @override
  AppException? get error;

  /// Create a copy of PodcastInfoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastInfoStateImplCopyWith<_$PodcastInfoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
