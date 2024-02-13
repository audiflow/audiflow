// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodeState {
  bool get chaptersLoading => throw _privateConstructorUsedError;
  bool get highlight => throw _privateConstructorUsedError;
  bool get queued => throw _privateConstructorUsedError;
  bool get streaming => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EpisodeStateCopyWith<EpisodeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeStateCopyWith<$Res> {
  factory $EpisodeStateCopyWith(
          EpisodeState value, $Res Function(EpisodeState) then) =
      _$EpisodeStateCopyWithImpl<$Res, EpisodeState>;
  @useResult
  $Res call(
      {bool chaptersLoading, bool highlight, bool queued, bool streaming});
}

/// @nodoc
class _$EpisodeStateCopyWithImpl<$Res, $Val extends EpisodeState>
    implements $EpisodeStateCopyWith<$Res> {
  _$EpisodeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chaptersLoading = null,
    Object? highlight = null,
    Object? queued = null,
    Object? streaming = null,
  }) {
    return _then(_value.copyWith(
      chaptersLoading: null == chaptersLoading
          ? _value.chaptersLoading
          : chaptersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      highlight: null == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as bool,
      queued: null == queued
          ? _value.queued
          : queued // ignore: cast_nullable_to_non_nullable
              as bool,
      streaming: null == streaming
          ? _value.streaming
          : streaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeStateImplCopyWith<$Res>
    implements $EpisodeStateCopyWith<$Res> {
  factory _$$EpisodeStateImplCopyWith(
          _$EpisodeStateImpl value, $Res Function(_$EpisodeStateImpl) then) =
      __$$EpisodeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool chaptersLoading, bool highlight, bool queued, bool streaming});
}

/// @nodoc
class __$$EpisodeStateImplCopyWithImpl<$Res>
    extends _$EpisodeStateCopyWithImpl<$Res, _$EpisodeStateImpl>
    implements _$$EpisodeStateImplCopyWith<$Res> {
  __$$EpisodeStateImplCopyWithImpl(
      _$EpisodeStateImpl _value, $Res Function(_$EpisodeStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chaptersLoading = null,
    Object? highlight = null,
    Object? queued = null,
    Object? streaming = null,
  }) {
    return _then(_$EpisodeStateImpl(
      chaptersLoading: null == chaptersLoading
          ? _value.chaptersLoading
          : chaptersLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      highlight: null == highlight
          ? _value.highlight
          : highlight // ignore: cast_nullable_to_non_nullable
              as bool,
      queued: null == queued
          ? _value.queued
          : queued // ignore: cast_nullable_to_non_nullable
              as bool,
      streaming: null == streaming
          ? _value.streaming
          : streaming // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EpisodeStateImpl implements _EpisodeState {
  const _$EpisodeStateImpl(
      {this.chaptersLoading = false,
      this.highlight = false,
      this.queued = false,
      this.streaming = false});

  @override
  @JsonKey()
  final bool chaptersLoading;
  @override
  @JsonKey()
  final bool highlight;
  @override
  @JsonKey()
  final bool queued;
  @override
  @JsonKey()
  final bool streaming;

  @override
  String toString() {
    return 'EpisodeState(chaptersLoading: $chaptersLoading, highlight: $highlight, queued: $queued, streaming: $streaming)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeStateImpl &&
            (identical(other.chaptersLoading, chaptersLoading) ||
                other.chaptersLoading == chaptersLoading) &&
            (identical(other.highlight, highlight) ||
                other.highlight == highlight) &&
            (identical(other.queued, queued) || other.queued == queued) &&
            (identical(other.streaming, streaming) ||
                other.streaming == streaming));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, chaptersLoading, highlight, queued, streaming);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      __$$EpisodeStateImplCopyWithImpl<_$EpisodeStateImpl>(this, _$identity);
}

abstract class _EpisodeState implements EpisodeState {
  const factory _EpisodeState(
      {final bool chaptersLoading,
      final bool highlight,
      final bool queued,
      final bool streaming}) = _$EpisodeStateImpl;

  @override
  bool get chaptersLoading;
  @override
  bool get highlight;
  @override
  bool get queued;
  @override
  bool get streaming;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeStateImplCopyWith<_$EpisodeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
