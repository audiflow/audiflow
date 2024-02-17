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
  Episode get episode => throw _privateConstructorUsedError;
  EpisodeStats? get stats => throw _privateConstructorUsedError;
  Downloadable? get download => throw _privateConstructorUsedError;
  Queue? get queue => throw _privateConstructorUsedError;

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
      {Episode episode,
      EpisodeStats? stats,
      Downloadable? download,
      Queue? queue});

  $EpisodeCopyWith<$Res> get episode;
  $EpisodeStatsCopyWith<$Res>? get stats;
  $DownloadableCopyWith<$Res>? get download;
  $QueueCopyWith<$Res>? get queue;
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
    Object? episode = null,
    Object? stats = freezed,
    Object? download = freezed,
    Object? queue = freezed,
  }) {
    return _then(_value.copyWith(
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
      queue: freezed == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as Queue?,
    ) as $Val);
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

  @override
  @pragma('vm:prefer-inline')
  $QueueCopyWith<$Res>? get queue {
    if (_value.queue == null) {
      return null;
    }

    return $QueueCopyWith<$Res>(_value.queue!, (value) {
      return _then(_value.copyWith(queue: value) as $Val);
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
      {Episode episode,
      EpisodeStats? stats,
      Downloadable? download,
      Queue? queue});

  @override
  $EpisodeCopyWith<$Res> get episode;
  @override
  $EpisodeStatsCopyWith<$Res>? get stats;
  @override
  $DownloadableCopyWith<$Res>? get download;
  @override
  $QueueCopyWith<$Res>? get queue;
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
    Object? episode = null,
    Object? stats = freezed,
    Object? download = freezed,
    Object? queue = freezed,
  }) {
    return _then(_$EpisodeStateImpl(
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
      queue: freezed == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as Queue?,
    ));
  }
}

/// @nodoc

class _$EpisodeStateImpl implements _EpisodeState {
  const _$EpisodeStateImpl(
      {required this.episode, this.stats, this.download, this.queue});

  @override
  final Episode episode;
  @override
  final EpisodeStats? stats;
  @override
  final Downloadable? download;
  @override
  final Queue? queue;

  @override
  String toString() {
    return 'EpisodeInfoState(episode: $episode, stats: $stats, download: $download, queue: $queue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStateImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.queue, queue) || other.queue == queue));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, stats, download, queue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      __$$EpisodeStateImplCopyWithImpl<_$EpisodeStateImpl>(this, _$identity);
}

abstract class _EpisodeState implements EpisodeInfoState {
  const factory _EpisodeState(
      {required final Episode episode,
      final EpisodeStats? stats,
      final Downloadable? download,
      final Queue? queue}) = _$EpisodeStateImpl;

  @override
  Episode get episode;
  @override
  EpisodeStats? get stats;
  @override
  Downloadable? get download;
  @override
  Queue? get queue;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
