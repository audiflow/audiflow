// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_info_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodeInfoState {
  PodcastMetadata get podcastMetadata => throw _privateConstructorUsedError;
  Episode get episode => throw _privateConstructorUsedError;
  EpisodeStats? get stats => throw _privateConstructorUsedError;
  Downloadable? get download => throw _privateConstructorUsedError;
  int? get queueIndex => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EpisodeInfoStateCopyWith<EpisodeInfoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeInfoStateCopyWith<$Res> {
  factory $EpisodeInfoStateCopyWith(
          EpisodeInfoState value, $Res Function(EpisodeInfoState) then) =
      _$EpisodeInfoStateCopyWithImpl<$Res, EpisodeInfoState>;
  @useResult
  $Res call(
      {PodcastMetadata podcastMetadata,
      Episode episode,
      EpisodeStats? stats,
      Downloadable? download,
      int? queueIndex});

  $PodcastMetadataCopyWith<$Res> get podcastMetadata;
  $EpisodeCopyWith<$Res> get episode;
  $EpisodeStatsCopyWith<$Res>? get stats;
  $DownloadableCopyWith<$Res>? get download;
}

/// @nodoc
class _$EpisodeInfoStateCopyWithImpl<$Res, $Val extends EpisodeInfoState>
    implements $EpisodeInfoStateCopyWith<$Res> {
  _$EpisodeInfoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcastMetadata = null,
    Object? episode = null,
    Object? stats = freezed,
    Object? download = freezed,
    Object? queueIndex = freezed,
  }) {
    return _then(_value.copyWith(
      podcastMetadata: null == podcastMetadata
          ? _value.podcastMetadata
          : podcastMetadata // ignore: cast_nullable_to_non_nullable
              as PodcastMetadata,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as EpisodeStats?,
      download: freezed == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as Downloadable?,
      queueIndex: freezed == queueIndex
          ? _value.queueIndex
          : queueIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PodcastMetadataCopyWith<$Res> get podcastMetadata {
    return $PodcastMetadataCopyWith<$Res>(_value.podcastMetadata, (value) {
      return _then(_value.copyWith(podcastMetadata: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $EpisodeStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DownloadableCopyWith<$Res>? get download {
    if (_value.download == null) {
      return null;
    }

    return $DownloadableCopyWith<$Res>(_value.download!, (value) {
      return _then(_value.copyWith(download: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EpisodeStateImplCopyWith<$Res>
    implements $EpisodeInfoStateCopyWith<$Res> {
  factory _$$EpisodeStateImplCopyWith(
          _$EpisodeStateImpl value, $Res Function(_$EpisodeStateImpl) then) =
      __$$EpisodeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PodcastMetadata podcastMetadata,
      Episode episode,
      EpisodeStats? stats,
      Downloadable? download,
      int? queueIndex});

  @override
  $PodcastMetadataCopyWith<$Res> get podcastMetadata;
  @override
  $EpisodeCopyWith<$Res> get episode;
  @override
  $EpisodeStatsCopyWith<$Res>? get stats;
  @override
  $DownloadableCopyWith<$Res>? get download;
}

/// @nodoc
class __$$EpisodeStateImplCopyWithImpl<$Res>
    extends _$EpisodeInfoStateCopyWithImpl<$Res, _$EpisodeStateImpl>
    implements _$$EpisodeStateImplCopyWith<$Res> {
  __$$EpisodeStateImplCopyWithImpl(
      _$EpisodeStateImpl _value, $Res Function(_$EpisodeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? podcastMetadata = null,
    Object? episode = null,
    Object? stats = freezed,
    Object? download = freezed,
    Object? queueIndex = freezed,
  }) {
    return _then(_$EpisodeStateImpl(
      podcastMetadata: null == podcastMetadata
          ? _value.podcastMetadata
          : podcastMetadata // ignore: cast_nullable_to_non_nullable
              as PodcastMetadata,
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as EpisodeStats?,
      download: freezed == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as Downloadable?,
      queueIndex: freezed == queueIndex
          ? _value.queueIndex
          : queueIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$EpisodeStateImpl implements _EpisodeState {
  const _$EpisodeStateImpl(
      {required this.podcastMetadata,
      required this.episode,
      this.stats,
      this.download,
      this.queueIndex});

  @override
  final PodcastMetadata podcastMetadata;
  @override
  final Episode episode;
  @override
  final EpisodeStats? stats;
  @override
  final Downloadable? download;
  @override
  final int? queueIndex;

  @override
  String toString() {
    return 'EpisodeInfoState(podcastMetadata: $podcastMetadata, episode: $episode, stats: $stats, download: $download, queueIndex: $queueIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStateImpl &&
            (identical(other.podcastMetadata, podcastMetadata) ||
                other.podcastMetadata == podcastMetadata) &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.queueIndex, queueIndex) ||
                other.queueIndex == queueIndex));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, podcastMetadata, episode, stats, download, queueIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      __$$EpisodeStateImplCopyWithImpl<_$EpisodeStateImpl>(this, _$identity);
}

abstract class _EpisodeState implements EpisodeInfoState {
  const factory _EpisodeState(
      {required final PodcastMetadata podcastMetadata,
      required final Episode episode,
      final EpisodeStats? stats,
      final Downloadable? download,
      final int? queueIndex}) = _$EpisodeStateImpl;

  @override
  PodcastMetadata get podcastMetadata;
  @override
  Episode get episode;
  @override
  EpisodeStats? get stats;
  @override
  Downloadable? get download;
  @override
  int? get queueIndex;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
