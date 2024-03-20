// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_season_info_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastSeasonInfoState {
  List<Episode> get episodes => throw _privateConstructorUsedError;
  List<EpisodeStats> get statsList => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastSeasonInfoStateCopyWith<PodcastSeasonInfoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastSeasonInfoStateCopyWith<$Res> {
  factory $PodcastSeasonInfoStateCopyWith(PodcastSeasonInfoState value,
          $Res Function(PodcastSeasonInfoState) then) =
      _$PodcastSeasonInfoStateCopyWithImpl<$Res, PodcastSeasonInfoState>;
  @useResult
  $Res call({List<Episode> episodes, List<EpisodeStats> statsList});
}

/// @nodoc
class _$PodcastSeasonInfoStateCopyWithImpl<$Res,
        $Val extends PodcastSeasonInfoState>
    implements $PodcastSeasonInfoStateCopyWith<$Res> {
  _$PodcastSeasonInfoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? statsList = null,
  }) {
    return _then(_value.copyWith(
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      statsList: null == statsList
          ? _value.statsList
          : statsList // ignore: cast_nullable_to_non_nullable
              as List<EpisodeStats>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastSeasonInfoStateImplCopyWith<$Res>
    implements $PodcastSeasonInfoStateCopyWith<$Res> {
  factory _$$PodcastSeasonInfoStateImplCopyWith(
          _$PodcastSeasonInfoStateImpl value,
          $Res Function(_$PodcastSeasonInfoStateImpl) then) =
      __$$PodcastSeasonInfoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Episode> episodes, List<EpisodeStats> statsList});
}

/// @nodoc
class __$$PodcastSeasonInfoStateImplCopyWithImpl<$Res>
    extends _$PodcastSeasonInfoStateCopyWithImpl<$Res,
        _$PodcastSeasonInfoStateImpl>
    implements _$$PodcastSeasonInfoStateImplCopyWith<$Res> {
  __$$PodcastSeasonInfoStateImplCopyWithImpl(
      _$PodcastSeasonInfoStateImpl _value,
      $Res Function(_$PodcastSeasonInfoStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? statsList = null,
  }) {
    return _then(_$PodcastSeasonInfoStateImpl(
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      statsList: null == statsList
          ? _value._statsList
          : statsList // ignore: cast_nullable_to_non_nullable
              as List<EpisodeStats>,
    ));
  }
}

/// @nodoc

class _$PodcastSeasonInfoStateImpl implements _PodcastSeasonInfoState {
  const _$PodcastSeasonInfoStateImpl(
      {required final List<Episode> episodes,
      required final List<EpisodeStats> statsList})
      : _episodes = episodes,
        _statsList = statsList;

  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  final List<EpisodeStats> _statsList;
  @override
  List<EpisodeStats> get statsList {
    if (_statsList is EqualUnmodifiableListView) return _statsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statsList);
  }

  @override
  String toString() {
    return 'PodcastSeasonInfoState(episodes: $episodes, statsList: $statsList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastSeasonInfoStateImpl &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality()
                .equals(other._statsList, _statsList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_episodes),
      const DeepCollectionEquality().hash(_statsList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastSeasonInfoStateImplCopyWith<_$PodcastSeasonInfoStateImpl>
      get copyWith => __$$PodcastSeasonInfoStateImplCopyWithImpl<
          _$PodcastSeasonInfoStateImpl>(this, _$identity);
}

abstract class _PodcastSeasonInfoState implements PodcastSeasonInfoState {
  const factory _PodcastSeasonInfoState(
          {required final List<Episode> episodes,
          required final List<EpisodeStats> statsList}) =
      _$PodcastSeasonInfoStateImpl;

  @override
  List<Episode> get episodes;
  @override
  List<EpisodeStats> get statsList;
  @override
  @JsonKey(ignore: true)
  _$$PodcastSeasonInfoStateImplCopyWith<_$PodcastSeasonInfoStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
