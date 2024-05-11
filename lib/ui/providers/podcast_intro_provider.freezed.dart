// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_intro_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastIntroState {
  Podcast get podcast => throw _privateConstructorUsedError;
  PodcastStats? get stats => throw _privateConstructorUsedError;
  List<Episode> get episodes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastIntroStateCopyWith<PodcastIntroState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastIntroStateCopyWith<$Res> {
  factory $PodcastIntroStateCopyWith(
          PodcastIntroState value, $Res Function(PodcastIntroState) then) =
      _$PodcastIntroStateCopyWithImpl<$Res, PodcastIntroState>;
  @useResult
  $Res call({Podcast podcast, PodcastStats? stats, List<Episode> episodes});
}

/// @nodoc
class _$PodcastIntroStateCopyWithImpl<$Res, $Val extends PodcastIntroState>
    implements $PodcastIntroStateCopyWith<$Res> {
  _$PodcastIntroStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = null,
    Object? stats = freezed,
    Object? episodes = null,
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
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastIntroStateImplCopyWith<$Res>
    implements $PodcastIntroStateCopyWith<$Res> {
  factory _$$PodcastIntroStateImplCopyWith(_$PodcastIntroStateImpl value,
          $Res Function(_$PodcastIntroStateImpl) then) =
      __$$PodcastIntroStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Podcast podcast, PodcastStats? stats, List<Episode> episodes});
}

/// @nodoc
class __$$PodcastIntroStateImplCopyWithImpl<$Res>
    extends _$PodcastIntroStateCopyWithImpl<$Res, _$PodcastIntroStateImpl>
    implements _$$PodcastIntroStateImplCopyWith<$Res> {
  __$$PodcastIntroStateImplCopyWithImpl(_$PodcastIntroStateImpl _value,
      $Res Function(_$PodcastIntroStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcast = null,
    Object? stats = freezed,
    Object? episodes = null,
  }) {
    return _then(_$PodcastIntroStateImpl(
      podcast: null == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ));
  }
}

/// @nodoc

class _$PodcastIntroStateImpl
    with DiagnosticableTreeMixin
    implements _PodcastIntroState {
  const _$PodcastIntroStateImpl(
      {required this.podcast,
      this.stats,
      required final List<Episode> episodes})
      : _episodes = episodes;

  @override
  final Podcast podcast;
  @override
  final PodcastStats? stats;
  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PodcastIntroState(podcast: $podcast, stats: $stats, episodes: $episodes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PodcastIntroState'))
      ..add(DiagnosticsProperty('podcast', podcast))
      ..add(DiagnosticsProperty('stats', stats))
      ..add(DiagnosticsProperty('episodes', episodes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastIntroStateImpl &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, podcast, stats,
      const DeepCollectionEquality().hash(_episodes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastIntroStateImplCopyWith<_$PodcastIntroStateImpl> get copyWith =>
      __$$PodcastIntroStateImplCopyWithImpl<_$PodcastIntroStateImpl>(
          this, _$identity);
}

abstract class _PodcastIntroState implements PodcastIntroState {
  const factory _PodcastIntroState(
      {required final Podcast podcast,
      final PodcastStats? stats,
      required final List<Episode> episodes}) = _$PodcastIntroStateImpl;

  @override
  Podcast get podcast;
  @override
  PodcastStats? get stats;
  @override
  List<Episode> get episodes;
  @override
  @JsonKey(ignore: true)
  _$$PodcastIntroStateImplCopyWith<_$PodcastIntroStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
