// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_info_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastDetailsState {
  Podcast get podcast => throw _privateConstructorUsedError;
  PodcastStats? get stats => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastDetailsStateCopyWith<PodcastDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastDetailsStateCopyWith<$Res> {
  factory $PodcastDetailsStateCopyWith(
          PodcastDetailsState value, $Res Function(PodcastDetailsState) then) =
      _$PodcastDetailsStateCopyWithImpl<$Res, PodcastDetailsState>;
  @useResult
  $Res call({Podcast podcast, PodcastStats? stats});

  $PodcastCopyWith<$Res> get podcast;
  $PodcastStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$PodcastDetailsStateCopyWithImpl<$Res, $Val extends PodcastDetailsState>
    implements $PodcastDetailsStateCopyWith<$Res> {
  _$PodcastDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = null,
    Object? stats = freezed,
  }) {
    return _then(_value.copyWith(
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PodcastCopyWith<$Res> get podcast {
    return $PodcastCopyWith<$Res>(_value.podcast, (value) {
      return _then(_value.copyWith(podcast: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PodcastStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $PodcastStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PodcastDetailsStateImplCopyWith<$Res>
    implements $PodcastDetailsStateCopyWith<$Res> {
  factory _$$PodcastDetailsStateImplCopyWith(_$PodcastDetailsStateImpl value,
          $Res Function(_$PodcastDetailsStateImpl) then) =
      __$$PodcastDetailsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Podcast podcast, PodcastStats? stats});

  @override
  $PodcastCopyWith<$Res> get podcast;
  @override
  $PodcastStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$PodcastDetailsStateImplCopyWithImpl<$Res>
    extends _$PodcastDetailsStateCopyWithImpl<$Res, _$PodcastDetailsStateImpl>
    implements _$$PodcastDetailsStateImplCopyWith<$Res> {
  __$$PodcastDetailsStateImplCopyWithImpl(_$PodcastDetailsStateImpl _value,
      $Res Function(_$PodcastDetailsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = null,
    Object? stats = freezed,
  }) {
    return _then(_$PodcastDetailsStateImpl(
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
    ));
  }
}

/// @nodoc

class _$PodcastDetailsStateImpl implements _PodcastDetailsState {
  const _$PodcastDetailsStateImpl({required this.podcast, this.stats});

  @override
  final Podcast podcast;
  @override
  final PodcastStats? stats;

  @override
  String toString() {
    return 'PodcastDetailsState(podcast: $podcast, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastDetailsStateImpl &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, podcast, stats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastDetailsStateImplCopyWith<_$PodcastDetailsStateImpl> get copyWith =>
      __$$PodcastDetailsStateImplCopyWithImpl<_$PodcastDetailsStateImpl>(
          this, _$identity);
}

abstract class _PodcastDetailsState implements PodcastDetailsState {
  const factory _PodcastDetailsState(
      {required final Podcast podcast,
      final PodcastStats? stats}) = _$PodcastDetailsStateImpl;

  @override
  Podcast get podcast;
  @override
  PodcastStats? get stats;
  @override
  @JsonKey(ignore: true)
  _$$PodcastDetailsStateImplCopyWith<_$PodcastDetailsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
