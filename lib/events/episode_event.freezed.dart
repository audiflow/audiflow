// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$EpisodeEvent {
  Episode get episode => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode) update,
    required TResult Function(Episode episode) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode)? update,
    TResult? Function(Episode episode)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode)? update,
    TResult Function(Episode episode)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EpisodeUpdateEvent value) update,
    required TResult Function(EpisodeDeleteEvent value) delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EpisodeUpdateEvent value)? update,
    TResult? Function(EpisodeDeleteEvent value)? delete,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EpisodeUpdateEvent value)? update,
    TResult Function(EpisodeDeleteEvent value)? delete,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EpisodeEventCopyWith<EpisodeEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeEventCopyWith<$Res> {
  factory $EpisodeEventCopyWith(
          EpisodeEvent value, $Res Function(EpisodeEvent) then) =
      _$EpisodeEventCopyWithImpl<$Res, EpisodeEvent>;
  @useResult
  $Res call({Episode episode});

  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class _$EpisodeEventCopyWithImpl<$Res, $Val extends EpisodeEvent>
    implements $EpisodeEventCopyWith<$Res> {
  _$EpisodeEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
  }) {
    return _then(_value.copyWith(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EpisodeUpdateEventImplCopyWith<$Res>
    implements $EpisodeEventCopyWith<$Res> {
  factory _$$EpisodeUpdateEventImplCopyWith(_$EpisodeUpdateEventImpl value,
          $Res Function(_$EpisodeUpdateEventImpl) then) =
      __$$EpisodeUpdateEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Episode episode});

  @override
  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class __$$EpisodeUpdateEventImplCopyWithImpl<$Res>
    extends _$EpisodeEventCopyWithImpl<$Res, _$EpisodeUpdateEventImpl>
    implements _$$EpisodeUpdateEventImplCopyWith<$Res> {
  __$$EpisodeUpdateEventImplCopyWithImpl(_$EpisodeUpdateEventImpl _value,
      $Res Function(_$EpisodeUpdateEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
  }) {
    return _then(_$EpisodeUpdateEventImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ));
  }
}

/// @nodoc

class _$EpisodeUpdateEventImpl implements EpisodeUpdateEvent {
  const _$EpisodeUpdateEventImpl({required this.episode});

  @override
  final Episode episode;

  @override
  String toString() {
    return 'EpisodeEvent.update(episode: $episode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeUpdateEventImpl &&
            (identical(other.episode, episode) || other.episode == episode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeUpdateEventImplCopyWith<_$EpisodeUpdateEventImpl> get copyWith =>
      __$$EpisodeUpdateEventImplCopyWithImpl<_$EpisodeUpdateEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode) update,
    required TResult Function(Episode episode) delete,
  }) {
    return update(episode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode)? update,
    TResult? Function(Episode episode)? delete,
  }) {
    return update?.call(episode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode)? update,
    TResult Function(Episode episode)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(episode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EpisodeUpdateEvent value) update,
    required TResult Function(EpisodeDeleteEvent value) delete,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EpisodeUpdateEvent value)? update,
    TResult? Function(EpisodeDeleteEvent value)? delete,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EpisodeUpdateEvent value)? update,
    TResult Function(EpisodeDeleteEvent value)? delete,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class EpisodeUpdateEvent implements EpisodeEvent {
  const factory EpisodeUpdateEvent({required final Episode episode}) =
      _$EpisodeUpdateEventImpl;

  @override
  Episode get episode;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeUpdateEventImplCopyWith<_$EpisodeUpdateEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EpisodeDeleteEventImplCopyWith<$Res>
    implements $EpisodeEventCopyWith<$Res> {
  factory _$$EpisodeDeleteEventImplCopyWith(_$EpisodeDeleteEventImpl value,
          $Res Function(_$EpisodeDeleteEventImpl) then) =
      __$$EpisodeDeleteEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Episode episode});

  @override
  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class __$$EpisodeDeleteEventImplCopyWithImpl<$Res>
    extends _$EpisodeEventCopyWithImpl<$Res, _$EpisodeDeleteEventImpl>
    implements _$$EpisodeDeleteEventImplCopyWith<$Res> {
  __$$EpisodeDeleteEventImplCopyWithImpl(_$EpisodeDeleteEventImpl _value,
      $Res Function(_$EpisodeDeleteEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
  }) {
    return _then(_$EpisodeDeleteEventImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ));
  }
}

/// @nodoc

class _$EpisodeDeleteEventImpl implements EpisodeDeleteEvent {
  const _$EpisodeDeleteEventImpl({required this.episode});

  @override
  final Episode episode;

  @override
  String toString() {
    return 'EpisodeEvent.delete(episode: $episode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeDeleteEventImpl &&
            (identical(other.episode, episode) || other.episode == episode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeDeleteEventImplCopyWith<_$EpisodeDeleteEventImpl> get copyWith =>
      __$$EpisodeDeleteEventImplCopyWithImpl<_$EpisodeDeleteEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode) update,
    required TResult Function(Episode episode) delete,
  }) {
    return delete(episode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode)? update,
    TResult? Function(Episode episode)? delete,
  }) {
    return delete?.call(episode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode)? update,
    TResult Function(Episode episode)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(episode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EpisodeUpdateEvent value) update,
    required TResult Function(EpisodeDeleteEvent value) delete,
  }) {
    return delete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EpisodeUpdateEvent value)? update,
    TResult? Function(EpisodeDeleteEvent value)? delete,
  }) {
    return delete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EpisodeUpdateEvent value)? update,
    TResult Function(EpisodeDeleteEvent value)? delete,
    required TResult orElse(),
  }) {
    if (delete != null) {
      return delete(this);
    }
    return orElse();
  }
}

abstract class EpisodeDeleteEvent implements EpisodeEvent {
  const factory EpisodeDeleteEvent({required final Episode episode}) =
      _$EpisodeDeleteEventImpl;

  @override
  Episode get episode;
  @override
  @JsonKey(ignore: true)
  _$$EpisodeDeleteEventImplCopyWith<_$EpisodeDeleteEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
