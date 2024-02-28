// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episodes_group_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodesGroupState {
  List<Episode> get episodes => throw _privateConstructorUsedError;
  Map<String, EpisodeStats> get statsMap => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EpisodesGroupStateCopyWith<EpisodesGroupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodesGroupStateCopyWith<$Res> {
  factory $EpisodesGroupStateCopyWith(
          EpisodesGroupState value, $Res Function(EpisodesGroupState) then) =
      _$EpisodesGroupStateCopyWithImpl<$Res, EpisodesGroupState>;
  @useResult
  $Res call({List<Episode> episodes, Map<String, EpisodeStats> statsMap});
}

/// @nodoc
class _$EpisodesGroupStateCopyWithImpl<$Res, $Val extends EpisodesGroupState>
    implements $EpisodesGroupStateCopyWith<$Res> {
  _$EpisodesGroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? statsMap = null,
  }) {
    return _then(_value.copyWith(
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      statsMap: null == statsMap
          ? _value.statsMap
          : statsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, EpisodeStats>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodesGroupStateImplCopyWith<$Res>
    implements $EpisodesGroupStateCopyWith<$Res> {
  factory _$$EpisodesGroupStateImplCopyWith(_$EpisodesGroupStateImpl value,
          $Res Function(_$EpisodesGroupStateImpl) then) =
      __$$EpisodesGroupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Episode> episodes, Map<String, EpisodeStats> statsMap});
}

/// @nodoc
class __$$EpisodesGroupStateImplCopyWithImpl<$Res>
    extends _$EpisodesGroupStateCopyWithImpl<$Res, _$EpisodesGroupStateImpl>
    implements _$$EpisodesGroupStateImplCopyWith<$Res> {
  __$$EpisodesGroupStateImplCopyWithImpl(_$EpisodesGroupStateImpl _value,
      $Res Function(_$EpisodesGroupStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
    Object? statsMap = null,
  }) {
    return _then(_$EpisodesGroupStateImpl(
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      statsMap: null == statsMap
          ? _value._statsMap
          : statsMap // ignore: cast_nullable_to_non_nullable
              as Map<String, EpisodeStats>,
    ));
  }
}

/// @nodoc

class _$EpisodesGroupStateImpl
    with DiagnosticableTreeMixin
    implements _EpisodesGroupState {
  const _$EpisodesGroupStateImpl(
      {required final List<Episode> episodes,
      required final Map<String, EpisodeStats> statsMap})
      : _episodes = episodes,
        _statsMap = statsMap;

  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  final Map<String, EpisodeStats> _statsMap;
  @override
  Map<String, EpisodeStats> get statsMap {
    if (_statsMap is EqualUnmodifiableMapView) return _statsMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statsMap);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodesGroupState(episodes: $episodes, statsMap: $statsMap)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodesGroupState'))
      ..add(DiagnosticsProperty('episodes', episodes))
      ..add(DiagnosticsProperty('statsMap', statsMap));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodesGroupStateImpl &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality().equals(other._statsMap, _statsMap));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_episodes),
      const DeepCollectionEquality().hash(_statsMap));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodesGroupStateImplCopyWith<_$EpisodesGroupStateImpl> get copyWith =>
      __$$EpisodesGroupStateImplCopyWithImpl<_$EpisodesGroupStateImpl>(
          this, _$identity);
}

abstract class _EpisodesGroupState implements EpisodesGroupState {
  const factory _EpisodesGroupState(
          {required final List<Episode> episodes,
          required final Map<String, EpisodeStats> statsMap}) =
      _$EpisodesGroupStateImpl;

  @override
  List<Episode> get episodes;
  @override
  Map<String, EpisodeStats> get statsMap;
  @override
  @JsonKey(ignore: true)
  _$$EpisodesGroupStateImplCopyWith<_$EpisodesGroupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
