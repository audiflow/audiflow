// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_episodes_page_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SeasonEpisodesState {
  List<Episode> get episodes => throw _privateConstructorUsedError;
  EpisodeFilterMode get filterMode => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Create a copy of SeasonEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonEpisodesStateCopyWith<SeasonEpisodesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonEpisodesStateCopyWith<$Res> {
  factory $SeasonEpisodesStateCopyWith(
          SeasonEpisodesState value, $Res Function(SeasonEpisodesState) then) =
      _$SeasonEpisodesStateCopyWithImpl<$Res, SeasonEpisodesState>;
  @useResult
  $Res call(
      {List<Episode> episodes, EpisodeFilterMode filterMode, bool ascending});
}

/// @nodoc
class _$SeasonEpisodesStateCopyWithImpl<$Res, $Val extends SeasonEpisodesState>
    implements $SeasonEpisodesStateCopyWith<$Res> {
  _$SeasonEpisodesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? filterMode = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonEpisodesStateImplCopyWith<$Res>
    implements $SeasonEpisodesStateCopyWith<$Res> {
  factory _$$SeasonEpisodesStateImplCopyWith(_$SeasonEpisodesStateImpl value,
          $Res Function(_$SeasonEpisodesStateImpl) then) =
      __$$SeasonEpisodesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Episode> episodes, EpisodeFilterMode filterMode, bool ascending});
}

/// @nodoc
class __$$SeasonEpisodesStateImplCopyWithImpl<$Res>
    extends _$SeasonEpisodesStateCopyWithImpl<$Res, _$SeasonEpisodesStateImpl>
    implements _$$SeasonEpisodesStateImplCopyWith<$Res> {
  __$$SeasonEpisodesStateImplCopyWithImpl(_$SeasonEpisodesStateImpl _value,
      $Res Function(_$SeasonEpisodesStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? filterMode = null,
    Object? ascending = null,
  }) {
    return _then(_$SeasonEpisodesStateImpl(
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SeasonEpisodesStateImpl implements _SeasonEpisodesState {
  const _$SeasonEpisodesStateImpl(
      {required final List<Episode> episodes,
      required this.filterMode,
      required this.ascending})
      : _episodes = episodes;

  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  final EpisodeFilterMode filterMode;
  @override
  final bool ascending;

  @override
  String toString() {
    return 'SeasonEpisodesState(episodes: $episodes, filterMode: $filterMode, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonEpisodesStateImpl &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.filterMode, filterMode) ||
                other.filterMode == filterMode) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_episodes), filterMode, ascending);

  /// Create a copy of SeasonEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonEpisodesStateImplCopyWith<_$SeasonEpisodesStateImpl> get copyWith =>
      __$$SeasonEpisodesStateImplCopyWithImpl<_$SeasonEpisodesStateImpl>(
          this, _$identity);
}

abstract class _SeasonEpisodesState implements SeasonEpisodesState {
  const factory _SeasonEpisodesState(
      {required final List<Episode> episodes,
      required final EpisodeFilterMode filterMode,
      required final bool ascending}) = _$SeasonEpisodesStateImpl;

  @override
  List<Episode> get episodes;
  @override
  EpisodeFilterMode get filterMode;
  @override
  bool get ascending;

  /// Create a copy of SeasonEpisodesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonEpisodesStateImplCopyWith<_$SeasonEpisodesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
