// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_details_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastDetailsState {
  String? get feedUrl => throw _privateConstructorUsedError;
  int? get collectionId => throw _privateConstructorUsedError;
  Podcast? get podcast => throw _privateConstructorUsedError;
  PodcastStats? get stats => throw _privateConstructorUsedError;
  List<Episode> get episodes => throw _privateConstructorUsedError;
  AppException? get error => throw _privateConstructorUsedError;

  /// Create a copy of PodcastDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastDetailsStateCopyWith<PodcastDetailsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastDetailsStateCopyWith<$Res> {
  factory $PodcastDetailsStateCopyWith(
          PodcastDetailsState value, $Res Function(PodcastDetailsState) then) =
      _$PodcastDetailsStateCopyWithImpl<$Res, PodcastDetailsState>;
  @useResult
  $Res call(
      {String? feedUrl,
      int? collectionId,
      Podcast? podcast,
      PodcastStats? stats,
      List<Episode> episodes,
      AppException? error});
}

/// @nodoc
class _$PodcastDetailsStateCopyWithImpl<$Res, $Val extends PodcastDetailsState>
    implements $PodcastDetailsStateCopyWith<$Res> {
  _$PodcastDetailsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedUrl = freezed,
    Object? collectionId = freezed,
    Object? podcast = freezed,
    Object? stats = freezed,
    Object? episodes = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int?,
      podcast: freezed == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ) as $Val);
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
  $Res call(
      {String? feedUrl,
      int? collectionId,
      Podcast? podcast,
      PodcastStats? stats,
      List<Episode> episodes,
      AppException? error});
}

/// @nodoc
class __$$PodcastDetailsStateImplCopyWithImpl<$Res>
    extends _$PodcastDetailsStateCopyWithImpl<$Res, _$PodcastDetailsStateImpl>
    implements _$$PodcastDetailsStateImplCopyWith<$Res> {
  __$$PodcastDetailsStateImplCopyWithImpl(_$PodcastDetailsStateImpl _value,
      $Res Function(_$PodcastDetailsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedUrl = freezed,
    Object? collectionId = freezed,
    Object? podcast = freezed,
    Object? stats = freezed,
    Object? episodes = null,
    Object? error = freezed,
  }) {
    return _then(_$PodcastDetailsStateImpl(
      feedUrl: freezed == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as int?,
      podcast: freezed == podcast
          ? _value.podcast
          : podcast // ignore: cast_nullable_to_non_nullable
              as Podcast?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as PodcastStats?,
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as AppException?,
    ));
  }
}

/// @nodoc

class _$PodcastDetailsStateImpl implements _PodcastDetailsState {
  const _$PodcastDetailsStateImpl(
      {this.feedUrl,
      this.collectionId,
      this.podcast,
      this.stats,
      final List<Episode> episodes = const [],
      this.error})
      : _episodes = episodes;

  @override
  final String? feedUrl;
  @override
  final int? collectionId;
  @override
  final Podcast? podcast;
  @override
  final PodcastStats? stats;
  final List<Episode> _episodes;
  @override
  @JsonKey()
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  final AppException? error;

  @override
  String toString() {
    return 'PodcastDetailsState(feedUrl: $feedUrl, collectionId: $collectionId, podcast: $podcast, stats: $stats, episodes: $episodes, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastDetailsStateImpl &&
            (identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.podcast, podcast) || other.podcast == podcast) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feedUrl, collectionId, podcast,
      stats, const DeepCollectionEquality().hash(_episodes), error);

  /// Create a copy of PodcastDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastDetailsStateImplCopyWith<_$PodcastDetailsStateImpl> get copyWith =>
      __$$PodcastDetailsStateImplCopyWithImpl<_$PodcastDetailsStateImpl>(
          this, _$identity);
}

abstract class _PodcastDetailsState implements PodcastDetailsState {
  const factory _PodcastDetailsState(
      {final String? feedUrl,
      final int? collectionId,
      final Podcast? podcast,
      final PodcastStats? stats,
      final List<Episode> episodes,
      final AppException? error}) = _$PodcastDetailsStateImpl;

  @override
  String? get feedUrl;
  @override
  int? get collectionId;
  @override
  Podcast? get podcast;
  @override
  PodcastStats? get stats;
  @override
  List<Episode> get episodes;
  @override
  AppException? get error;

  /// Create a copy of PodcastDetailsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastDetailsStateImplCopyWith<_$PodcastDetailsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
