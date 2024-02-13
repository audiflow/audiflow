// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastState {
  /// Indicates whether the user wants to see the podcast as a list of seasons
  bool get seasonView => throw _privateConstructorUsedError;
  bool get newEpisodes => throw _privateConstructorUsedError;
  bool get updatedEpisodes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastStateCopyWith<PodcastState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastStateCopyWith<$Res> {
  factory $PodcastStateCopyWith(
          PodcastState value, $Res Function(PodcastState) then) =
      _$PodcastStateCopyWithImpl<$Res, PodcastState>;
  @useResult
  $Res call({bool seasonView, bool newEpisodes, bool updatedEpisodes});
}

/// @nodoc
class _$PodcastStateCopyWithImpl<$Res, $Val extends PodcastState>
    implements $PodcastStateCopyWith<$Res> {
  _$PodcastStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasonView = null,
    Object? newEpisodes = null,
    Object? updatedEpisodes = null,
  }) {
    return _then(_value.copyWith(
      seasonView: null == seasonView
          ? _value.seasonView
          : seasonView // ignore: cast_nullable_to_non_nullable
              as bool,
      newEpisodes: null == newEpisodes
          ? _value.newEpisodes
          : newEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedEpisodes: null == updatedEpisodes
          ? _value.updatedEpisodes
          : updatedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastStateImplCopyWith<$Res>
    implements $PodcastStateCopyWith<$Res> {
  factory _$$PodcastStateImplCopyWith(
          _$PodcastStateImpl value, $Res Function(_$PodcastStateImpl) then) =
      __$$PodcastStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool seasonView, bool newEpisodes, bool updatedEpisodes});
}

/// @nodoc
class __$$PodcastStateImplCopyWithImpl<$Res>
    extends _$PodcastStateCopyWithImpl<$Res, _$PodcastStateImpl>
    implements _$$PodcastStateImplCopyWith<$Res> {
  __$$PodcastStateImplCopyWithImpl(
      _$PodcastStateImpl _value, $Res Function(_$PodcastStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seasonView = null,
    Object? newEpisodes = null,
    Object? updatedEpisodes = null,
  }) {
    return _then(_$PodcastStateImpl(
      seasonView: null == seasonView
          ? _value.seasonView
          : seasonView // ignore: cast_nullable_to_non_nullable
              as bool,
      newEpisodes: null == newEpisodes
          ? _value.newEpisodes
          : newEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedEpisodes: null == updatedEpisodes
          ? _value.updatedEpisodes
          : updatedEpisodes // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PodcastStateImpl implements _PodcastState {
  const _$PodcastStateImpl(
      {this.seasonView = false,
      this.newEpisodes = false,
      this.updatedEpisodes = false});

  /// Indicates whether the user wants to see the podcast as a list of seasons
  @override
  @JsonKey()
  final bool seasonView;
  @override
  @JsonKey()
  final bool newEpisodes;
  @override
  @JsonKey()
  final bool updatedEpisodes;

  @override
  String toString() {
    return 'PodcastState(seasonView: $seasonView, newEpisodes: $newEpisodes, updatedEpisodes: $updatedEpisodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastStateImpl &&
            (identical(other.seasonView, seasonView) ||
                other.seasonView == seasonView) &&
            (identical(other.newEpisodes, newEpisodes) ||
                other.newEpisodes == newEpisodes) &&
            (identical(other.updatedEpisodes, updatedEpisodes) ||
                other.updatedEpisodes == updatedEpisodes));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, seasonView, newEpisodes, updatedEpisodes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastStateImplCopyWith<_$PodcastStateImpl> get copyWith =>
      __$$PodcastStateImplCopyWithImpl<_$PodcastStateImpl>(this, _$identity);
}

abstract class _PodcastState implements PodcastState {
  const factory _PodcastState(
      {final bool seasonView,
      final bool newEpisodes,
      final bool updatedEpisodes}) = _$PodcastStateImpl;

  @override

  /// Indicates whether the user wants to see the podcast as a list of seasons
  bool get seasonView;
  @override
  bool get newEpisodes;
  @override
  bool get updatedEpisodes;
  @override
  @JsonKey(ignore: true)
  _$$PodcastStateImplCopyWith<_$PodcastStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
