// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_feed_loader.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastFeedLoaderState {
  String get feedUrl => throw _privateConstructorUsedError;
  LoadingState get loadingState => throw _privateConstructorUsedError;

  /// Create a copy of PodcastFeedLoaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastFeedLoaderStateCopyWith<PodcastFeedLoaderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastFeedLoaderStateCopyWith<$Res> {
  factory $PodcastFeedLoaderStateCopyWith(PodcastFeedLoaderState value,
          $Res Function(PodcastFeedLoaderState) then) =
      _$PodcastFeedLoaderStateCopyWithImpl<$Res, PodcastFeedLoaderState>;
  @useResult
  $Res call({String feedUrl, LoadingState loadingState});
}

/// @nodoc
class _$PodcastFeedLoaderStateCopyWithImpl<$Res,
        $Val extends PodcastFeedLoaderState>
    implements $PodcastFeedLoaderStateCopyWith<$Res> {
  _$PodcastFeedLoaderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastFeedLoaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedUrl = null,
    Object? loadingState = null,
  }) {
    return _then(_value.copyWith(
      feedUrl: null == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String,
      loadingState: null == loadingState
          ? _value.loadingState
          : loadingState // ignore: cast_nullable_to_non_nullable
              as LoadingState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastFeedLoaderStateImplCopyWith<$Res>
    implements $PodcastFeedLoaderStateCopyWith<$Res> {
  factory _$$PodcastFeedLoaderStateImplCopyWith(
          _$PodcastFeedLoaderStateImpl value,
          $Res Function(_$PodcastFeedLoaderStateImpl) then) =
      __$$PodcastFeedLoaderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String feedUrl, LoadingState loadingState});
}

/// @nodoc
class __$$PodcastFeedLoaderStateImplCopyWithImpl<$Res>
    extends _$PodcastFeedLoaderStateCopyWithImpl<$Res,
        _$PodcastFeedLoaderStateImpl>
    implements _$$PodcastFeedLoaderStateImplCopyWith<$Res> {
  __$$PodcastFeedLoaderStateImplCopyWithImpl(
      _$PodcastFeedLoaderStateImpl _value,
      $Res Function(_$PodcastFeedLoaderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastFeedLoaderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? feedUrl = null,
    Object? loadingState = null,
  }) {
    return _then(_$PodcastFeedLoaderStateImpl(
      feedUrl: null == feedUrl
          ? _value.feedUrl
          : feedUrl // ignore: cast_nullable_to_non_nullable
              as String,
      loadingState: null == loadingState
          ? _value.loadingState
          : loadingState // ignore: cast_nullable_to_non_nullable
              as LoadingState,
    ));
  }
}

/// @nodoc

class _$PodcastFeedLoaderStateImpl implements _PodcastFeedLoaderState {
  const _$PodcastFeedLoaderStateImpl(
      {required this.feedUrl, this.loadingState = LoadingState.loadingPodcast});

  @override
  final String feedUrl;
  @override
  @JsonKey()
  final LoadingState loadingState;

  @override
  String toString() {
    return 'PodcastFeedLoaderState(feedUrl: $feedUrl, loadingState: $loadingState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastFeedLoaderStateImpl &&
            (identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl) &&
            (identical(other.loadingState, loadingState) ||
                other.loadingState == loadingState));
  }

  @override
  int get hashCode => Object.hash(runtimeType, feedUrl, loadingState);

  /// Create a copy of PodcastFeedLoaderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastFeedLoaderStateImplCopyWith<_$PodcastFeedLoaderStateImpl>
      get copyWith => __$$PodcastFeedLoaderStateImplCopyWithImpl<
          _$PodcastFeedLoaderStateImpl>(this, _$identity);
}

abstract class _PodcastFeedLoaderState implements PodcastFeedLoaderState {
  const factory _PodcastFeedLoaderState(
      {required final String feedUrl,
      final LoadingState loadingState}) = _$PodcastFeedLoaderStateImpl;

  @override
  String get feedUrl;
  @override
  LoadingState get loadingState;

  /// Create a copy of PodcastFeedLoaderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastFeedLoaderStateImplCopyWith<_$PodcastFeedLoaderStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
