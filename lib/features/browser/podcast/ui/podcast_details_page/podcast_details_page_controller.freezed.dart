// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_details_page_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastDetailsPageState {
  PodcastDetailsPageViewMode get viewMode => throw _privateConstructorUsedError;
  EpisodeFilterMode get episodeFilterMode => throw _privateConstructorUsedError;
  bool get episodesAscending => throw _privateConstructorUsedError;
  SeasonFilterMode get seasonFilterMode => throw _privateConstructorUsedError;
  bool get seasonsAscending => throw _privateConstructorUsedError;

  /// Create a copy of PodcastDetailsPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastDetailsPageStateCopyWith<PodcastDetailsPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastDetailsPageStateCopyWith<$Res> {
  factory $PodcastDetailsPageStateCopyWith(PodcastDetailsPageState value,
          $Res Function(PodcastDetailsPageState) then) =
      _$PodcastDetailsPageStateCopyWithImpl<$Res, PodcastDetailsPageState>;
  @useResult
  $Res call(
      {PodcastDetailsPageViewMode viewMode,
      EpisodeFilterMode episodeFilterMode,
      bool episodesAscending,
      SeasonFilterMode seasonFilterMode,
      bool seasonsAscending});
}

/// @nodoc
class _$PodcastDetailsPageStateCopyWithImpl<$Res,
        $Val extends PodcastDetailsPageState>
    implements $PodcastDetailsPageStateCopyWith<$Res> {
  _$PodcastDetailsPageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastDetailsPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewMode = null,
    Object? episodeFilterMode = null,
    Object? episodesAscending = null,
    Object? seasonFilterMode = null,
    Object? seasonsAscending = null,
  }) {
    return _then(_value.copyWith(
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailsPageViewMode,
      episodeFilterMode: null == episodeFilterMode
          ? _value.episodeFilterMode
          : episodeFilterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      episodesAscending: null == episodesAscending
          ? _value.episodesAscending
          : episodesAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      seasonFilterMode: null == seasonFilterMode
          ? _value.seasonFilterMode
          : seasonFilterMode // ignore: cast_nullable_to_non_nullable
              as SeasonFilterMode,
      seasonsAscending: null == seasonsAscending
          ? _value.seasonsAscending
          : seasonsAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastDetailsPageStateImplCopyWith<$Res>
    implements $PodcastDetailsPageStateCopyWith<$Res> {
  factory _$$PodcastDetailsPageStateImplCopyWith(
          _$PodcastDetailsPageStateImpl value,
          $Res Function(_$PodcastDetailsPageStateImpl) then) =
      __$$PodcastDetailsPageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PodcastDetailsPageViewMode viewMode,
      EpisodeFilterMode episodeFilterMode,
      bool episodesAscending,
      SeasonFilterMode seasonFilterMode,
      bool seasonsAscending});
}

/// @nodoc
class __$$PodcastDetailsPageStateImplCopyWithImpl<$Res>
    extends _$PodcastDetailsPageStateCopyWithImpl<$Res,
        _$PodcastDetailsPageStateImpl>
    implements _$$PodcastDetailsPageStateImplCopyWith<$Res> {
  __$$PodcastDetailsPageStateImplCopyWithImpl(
      _$PodcastDetailsPageStateImpl _value,
      $Res Function(_$PodcastDetailsPageStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastDetailsPageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewMode = null,
    Object? episodeFilterMode = null,
    Object? episodesAscending = null,
    Object? seasonFilterMode = null,
    Object? seasonsAscending = null,
  }) {
    return _then(_$PodcastDetailsPageStateImpl(
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as PodcastDetailsPageViewMode,
      episodeFilterMode: null == episodeFilterMode
          ? _value.episodeFilterMode
          : episodeFilterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      episodesAscending: null == episodesAscending
          ? _value.episodesAscending
          : episodesAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      seasonFilterMode: null == seasonFilterMode
          ? _value.seasonFilterMode
          : seasonFilterMode // ignore: cast_nullable_to_non_nullable
              as SeasonFilterMode,
      seasonsAscending: null == seasonsAscending
          ? _value.seasonsAscending
          : seasonsAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PodcastDetailsPageStateImpl implements _PodcastDetailsPageState {
  const _$PodcastDetailsPageStateImpl(
      {required this.viewMode,
      required this.episodeFilterMode,
      required this.episodesAscending,
      required this.seasonFilterMode,
      required this.seasonsAscending});

  @override
  final PodcastDetailsPageViewMode viewMode;
  @override
  final EpisodeFilterMode episodeFilterMode;
  @override
  final bool episodesAscending;
  @override
  final SeasonFilterMode seasonFilterMode;
  @override
  final bool seasonsAscending;

  @override
  String toString() {
    return 'PodcastDetailsPageState(viewMode: $viewMode, episodeFilterMode: $episodeFilterMode, episodesAscending: $episodesAscending, seasonFilterMode: $seasonFilterMode, seasonsAscending: $seasonsAscending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastDetailsPageStateImpl &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.episodeFilterMode, episodeFilterMode) ||
                other.episodeFilterMode == episodeFilterMode) &&
            (identical(other.episodesAscending, episodesAscending) ||
                other.episodesAscending == episodesAscending) &&
            (identical(other.seasonFilterMode, seasonFilterMode) ||
                other.seasonFilterMode == seasonFilterMode) &&
            (identical(other.seasonsAscending, seasonsAscending) ||
                other.seasonsAscending == seasonsAscending));
  }

  @override
  int get hashCode => Object.hash(runtimeType, viewMode, episodeFilterMode,
      episodesAscending, seasonFilterMode, seasonsAscending);

  /// Create a copy of PodcastDetailsPageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastDetailsPageStateImplCopyWith<_$PodcastDetailsPageStateImpl>
      get copyWith => __$$PodcastDetailsPageStateImplCopyWithImpl<
          _$PodcastDetailsPageStateImpl>(this, _$identity);
}

abstract class _PodcastDetailsPageState implements PodcastDetailsPageState {
  const factory _PodcastDetailsPageState(
      {required final PodcastDetailsPageViewMode viewMode,
      required final EpisodeFilterMode episodeFilterMode,
      required final bool episodesAscending,
      required final SeasonFilterMode seasonFilterMode,
      required final bool seasonsAscending}) = _$PodcastDetailsPageStateImpl;

  @override
  PodcastDetailsPageViewMode get viewMode;
  @override
  EpisodeFilterMode get episodeFilterMode;
  @override
  bool get episodesAscending;
  @override
  SeasonFilterMode get seasonFilterMode;
  @override
  bool get seasonsAscending;

  /// Create a copy of PodcastDetailsPageState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastDetailsPageStateImplCopyWith<_$PodcastDetailsPageStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
