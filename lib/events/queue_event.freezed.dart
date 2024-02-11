// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$QueueEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode, int? position) add,
    required TResult Function(Episode episode) remove,
    required TResult Function(Episode episode, int oldIndex, int newIndex) move,
    required TResult Function() clear,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode, int? position)? add,
    TResult? Function(Episode episode)? remove,
    TResult? Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult? Function()? clear,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode, int? position)? add,
    TResult Function(Episode episode)? remove,
    TResult Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult Function()? clear,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QueueAddEvent value) add,
    required TResult Function(QueueRemoveEvent value) remove,
    required TResult Function(QueueMoveEvent value) move,
    required TResult Function(QueueClearEvent value) clear,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QueueAddEvent value)? add,
    TResult? Function(QueueRemoveEvent value)? remove,
    TResult? Function(QueueMoveEvent value)? move,
    TResult? Function(QueueClearEvent value)? clear,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QueueAddEvent value)? add,
    TResult Function(QueueRemoveEvent value)? remove,
    TResult Function(QueueMoveEvent value)? move,
    TResult Function(QueueClearEvent value)? clear,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueEventCopyWith<$Res> {
  factory $QueueEventCopyWith(
          QueueEvent value, $Res Function(QueueEvent) then) =
      _$QueueEventCopyWithImpl<$Res, QueueEvent>;
}

/// @nodoc
class _$QueueEventCopyWithImpl<$Res, $Val extends QueueEvent>
    implements $QueueEventCopyWith<$Res> {
  _$QueueEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$QueueAddEventImplCopyWith<$Res> {
  factory _$$QueueAddEventImplCopyWith(
          _$QueueAddEventImpl value, $Res Function(_$QueueAddEventImpl) then) =
      __$$QueueAddEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Episode episode, int? position});

  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class __$$QueueAddEventImplCopyWithImpl<$Res>
    extends _$QueueEventCopyWithImpl<$Res, _$QueueAddEventImpl>
    implements _$$QueueAddEventImplCopyWith<$Res> {
  __$$QueueAddEventImplCopyWithImpl(
      _$QueueAddEventImpl _value, $Res Function(_$QueueAddEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? position = freezed,
  }) {
    return _then(_$QueueAddEventImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value));
    });
  }
}

/// @nodoc

class _$QueueAddEventImpl implements QueueAddEvent {
  const _$QueueAddEventImpl({required this.episode, this.position});

  @override
  final Episode episode;
  @override
  final int? position;

  @override
  String toString() {
    return 'QueueEvent.add(episode: $episode, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueAddEventImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, position);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueAddEventImplCopyWith<_$QueueAddEventImpl> get copyWith =>
      __$$QueueAddEventImplCopyWithImpl<_$QueueAddEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode, int? position) add,
    required TResult Function(Episode episode) remove,
    required TResult Function(Episode episode, int oldIndex, int newIndex) move,
    required TResult Function() clear,
  }) {
    return add(episode, position);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode, int? position)? add,
    TResult? Function(Episode episode)? remove,
    TResult? Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult? Function()? clear,
  }) {
    return add?.call(episode, position);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode, int? position)? add,
    TResult Function(Episode episode)? remove,
    TResult Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult Function()? clear,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(episode, position);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QueueAddEvent value) add,
    required TResult Function(QueueRemoveEvent value) remove,
    required TResult Function(QueueMoveEvent value) move,
    required TResult Function(QueueClearEvent value) clear,
  }) {
    return add(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QueueAddEvent value)? add,
    TResult? Function(QueueRemoveEvent value)? remove,
    TResult? Function(QueueMoveEvent value)? move,
    TResult? Function(QueueClearEvent value)? clear,
  }) {
    return add?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QueueAddEvent value)? add,
    TResult Function(QueueRemoveEvent value)? remove,
    TResult Function(QueueMoveEvent value)? move,
    TResult Function(QueueClearEvent value)? clear,
    required TResult orElse(),
  }) {
    if (add != null) {
      return add(this);
    }
    return orElse();
  }
}

abstract class QueueAddEvent implements QueueEvent {
  const factory QueueAddEvent(
      {required final Episode episode,
      final int? position}) = _$QueueAddEventImpl;

  Episode get episode;
  int? get position;
  @JsonKey(ignore: true)
  _$$QueueAddEventImplCopyWith<_$QueueAddEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$QueueRemoveEventImplCopyWith<$Res> {
  factory _$$QueueRemoveEventImplCopyWith(_$QueueRemoveEventImpl value,
          $Res Function(_$QueueRemoveEventImpl) then) =
      __$$QueueRemoveEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Episode episode});

  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class __$$QueueRemoveEventImplCopyWithImpl<$Res>
    extends _$QueueEventCopyWithImpl<$Res, _$QueueRemoveEventImpl>
    implements _$$QueueRemoveEventImplCopyWith<$Res> {
  __$$QueueRemoveEventImplCopyWithImpl(_$QueueRemoveEventImpl _value,
      $Res Function(_$QueueRemoveEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
  }) {
    return _then(_$QueueRemoveEventImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value));
    });
  }
}

/// @nodoc

class _$QueueRemoveEventImpl implements QueueRemoveEvent {
  const _$QueueRemoveEventImpl({required this.episode});

  @override
  final Episode episode;

  @override
  String toString() {
    return 'QueueEvent.remove(episode: $episode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueRemoveEventImpl &&
            (identical(other.episode, episode) || other.episode == episode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueRemoveEventImplCopyWith<_$QueueRemoveEventImpl> get copyWith =>
      __$$QueueRemoveEventImplCopyWithImpl<_$QueueRemoveEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode, int? position) add,
    required TResult Function(Episode episode) remove,
    required TResult Function(Episode episode, int oldIndex, int newIndex) move,
    required TResult Function() clear,
  }) {
    return remove(episode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode, int? position)? add,
    TResult? Function(Episode episode)? remove,
    TResult? Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult? Function()? clear,
  }) {
    return remove?.call(episode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode, int? position)? add,
    TResult Function(Episode episode)? remove,
    TResult Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult Function()? clear,
    required TResult orElse(),
  }) {
    if (remove != null) {
      return remove(episode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QueueAddEvent value) add,
    required TResult Function(QueueRemoveEvent value) remove,
    required TResult Function(QueueMoveEvent value) move,
    required TResult Function(QueueClearEvent value) clear,
  }) {
    return remove(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QueueAddEvent value)? add,
    TResult? Function(QueueRemoveEvent value)? remove,
    TResult? Function(QueueMoveEvent value)? move,
    TResult? Function(QueueClearEvent value)? clear,
  }) {
    return remove?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QueueAddEvent value)? add,
    TResult Function(QueueRemoveEvent value)? remove,
    TResult Function(QueueMoveEvent value)? move,
    TResult Function(QueueClearEvent value)? clear,
    required TResult orElse(),
  }) {
    if (remove != null) {
      return remove(this);
    }
    return orElse();
  }
}

abstract class QueueRemoveEvent implements QueueEvent {
  const factory QueueRemoveEvent({required final Episode episode}) =
      _$QueueRemoveEventImpl;

  Episode get episode;
  @JsonKey(ignore: true)
  _$$QueueRemoveEventImplCopyWith<_$QueueRemoveEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$QueueMoveEventImplCopyWith<$Res> {
  factory _$$QueueMoveEventImplCopyWith(_$QueueMoveEventImpl value,
          $Res Function(_$QueueMoveEventImpl) then) =
      __$$QueueMoveEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Episode episode, int oldIndex, int newIndex});

  $EpisodeCopyWith<$Res> get episode;
}

/// @nodoc
class __$$QueueMoveEventImplCopyWithImpl<$Res>
    extends _$QueueEventCopyWithImpl<$Res, _$QueueMoveEventImpl>
    implements _$$QueueMoveEventImplCopyWith<$Res> {
  __$$QueueMoveEventImplCopyWithImpl(
      _$QueueMoveEventImpl _value, $Res Function(_$QueueMoveEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episode = null,
    Object? oldIndex = null,
    Object? newIndex = null,
  }) {
    return _then(_$QueueMoveEventImpl(
      episode: null == episode
          ? _value.episode
          : episode // ignore: cast_nullable_to_non_nullable
              as Episode,
      oldIndex: null == oldIndex
          ? _value.oldIndex
          : oldIndex // ignore: cast_nullable_to_non_nullable
              as int,
      newIndex: null == newIndex
          ? _value.newIndex
          : newIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get episode {
    return $EpisodeCopyWith<$Res>(_value.episode, (value) {
      return _then(_value.copyWith(episode: value));
    });
  }
}

/// @nodoc

class _$QueueMoveEventImpl implements QueueMoveEvent {
  const _$QueueMoveEventImpl(
      {required this.episode, required this.oldIndex, required this.newIndex});

  @override
  final Episode episode;
  @override
  final int oldIndex;
  @override
  final int newIndex;

  @override
  String toString() {
    return 'QueueEvent.move(episode: $episode, oldIndex: $oldIndex, newIndex: $newIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueMoveEventImpl &&
            (identical(other.episode, episode) || other.episode == episode) &&
            (identical(other.oldIndex, oldIndex) ||
                other.oldIndex == oldIndex) &&
            (identical(other.newIndex, newIndex) ||
                other.newIndex == newIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, episode, oldIndex, newIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueMoveEventImplCopyWith<_$QueueMoveEventImpl> get copyWith =>
      __$$QueueMoveEventImplCopyWithImpl<_$QueueMoveEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode, int? position) add,
    required TResult Function(Episode episode) remove,
    required TResult Function(Episode episode, int oldIndex, int newIndex) move,
    required TResult Function() clear,
  }) {
    return move(episode, oldIndex, newIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode, int? position)? add,
    TResult? Function(Episode episode)? remove,
    TResult? Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult? Function()? clear,
  }) {
    return move?.call(episode, oldIndex, newIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode, int? position)? add,
    TResult Function(Episode episode)? remove,
    TResult Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult Function()? clear,
    required TResult orElse(),
  }) {
    if (move != null) {
      return move(episode, oldIndex, newIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QueueAddEvent value) add,
    required TResult Function(QueueRemoveEvent value) remove,
    required TResult Function(QueueMoveEvent value) move,
    required TResult Function(QueueClearEvent value) clear,
  }) {
    return move(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QueueAddEvent value)? add,
    TResult? Function(QueueRemoveEvent value)? remove,
    TResult? Function(QueueMoveEvent value)? move,
    TResult? Function(QueueClearEvent value)? clear,
  }) {
    return move?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QueueAddEvent value)? add,
    TResult Function(QueueRemoveEvent value)? remove,
    TResult Function(QueueMoveEvent value)? move,
    TResult Function(QueueClearEvent value)? clear,
    required TResult orElse(),
  }) {
    if (move != null) {
      return move(this);
    }
    return orElse();
  }
}

abstract class QueueMoveEvent implements QueueEvent {
  const factory QueueMoveEvent(
      {required final Episode episode,
      required final int oldIndex,
      required final int newIndex}) = _$QueueMoveEventImpl;

  Episode get episode;
  int get oldIndex;
  int get newIndex;
  @JsonKey(ignore: true)
  _$$QueueMoveEventImplCopyWith<_$QueueMoveEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$QueueClearEventImplCopyWith<$Res> {
  factory _$$QueueClearEventImplCopyWith(_$QueueClearEventImpl value,
          $Res Function(_$QueueClearEventImpl) then) =
      __$$QueueClearEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$QueueClearEventImplCopyWithImpl<$Res>
    extends _$QueueEventCopyWithImpl<$Res, _$QueueClearEventImpl>
    implements _$$QueueClearEventImplCopyWith<$Res> {
  __$$QueueClearEventImplCopyWithImpl(
      _$QueueClearEventImpl _value, $Res Function(_$QueueClearEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$QueueClearEventImpl implements QueueClearEvent {
  const _$QueueClearEventImpl();

  @override
  String toString() {
    return 'QueueEvent.clear()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$QueueClearEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Episode episode, int? position) add,
    required TResult Function(Episode episode) remove,
    required TResult Function(Episode episode, int oldIndex, int newIndex) move,
    required TResult Function() clear,
  }) {
    return clear();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Episode episode, int? position)? add,
    TResult? Function(Episode episode)? remove,
    TResult? Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult? Function()? clear,
  }) {
    return clear?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Episode episode, int? position)? add,
    TResult Function(Episode episode)? remove,
    TResult Function(Episode episode, int oldIndex, int newIndex)? move,
    TResult Function()? clear,
    required TResult orElse(),
  }) {
    if (clear != null) {
      return clear();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QueueAddEvent value) add,
    required TResult Function(QueueRemoveEvent value) remove,
    required TResult Function(QueueMoveEvent value) move,
    required TResult Function(QueueClearEvent value) clear,
  }) {
    return clear(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QueueAddEvent value)? add,
    TResult? Function(QueueRemoveEvent value)? remove,
    TResult? Function(QueueMoveEvent value)? move,
    TResult? Function(QueueClearEvent value)? clear,
  }) {
    return clear?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QueueAddEvent value)? add,
    TResult Function(QueueRemoveEvent value)? remove,
    TResult Function(QueueMoveEvent value)? move,
    TResult Function(QueueClearEvent value)? clear,
    required TResult orElse(),
  }) {
    if (clear != null) {
      return clear(this);
    }
    return orElse();
  }
}

abstract class QueueClearEvent implements QueueEvent {
  const factory QueueClearEvent() = _$QueueClearEventImpl;
}

/// @nodoc
mixin _$QueueListEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(Episode playing, List<Episode> queue) list,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(Episode playing, List<Episode> queue)? list,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(Episode playing, List<Episode> queue)? list,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyQueueListEvent value) empty,
    required TResult Function(ReadyQueueListEvent value) list,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyQueueListEvent value)? empty,
    TResult? Function(ReadyQueueListEvent value)? list,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyQueueListEvent value)? empty,
    TResult Function(ReadyQueueListEvent value)? list,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueListEventCopyWith<$Res> {
  factory $QueueListEventCopyWith(
          QueueListEvent value, $Res Function(QueueListEvent) then) =
      _$QueueListEventCopyWithImpl<$Res, QueueListEvent>;
}

/// @nodoc
class _$QueueListEventCopyWithImpl<$Res, $Val extends QueueListEvent>
    implements $QueueListEventCopyWith<$Res> {
  _$QueueListEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$EmptyQueueListEventImplCopyWith<$Res> {
  factory _$$EmptyQueueListEventImplCopyWith(_$EmptyQueueListEventImpl value,
          $Res Function(_$EmptyQueueListEventImpl) then) =
      __$$EmptyQueueListEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmptyQueueListEventImplCopyWithImpl<$Res>
    extends _$QueueListEventCopyWithImpl<$Res, _$EmptyQueueListEventImpl>
    implements _$$EmptyQueueListEventImplCopyWith<$Res> {
  __$$EmptyQueueListEventImplCopyWithImpl(_$EmptyQueueListEventImpl _value,
      $Res Function(_$EmptyQueueListEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$EmptyQueueListEventImpl implements EmptyQueueListEvent {
  const _$EmptyQueueListEventImpl();

  @override
  String toString() {
    return 'QueueListEvent.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmptyQueueListEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(Episode playing, List<Episode> queue) list,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(Episode playing, List<Episode> queue)? list,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(Episode playing, List<Episode> queue)? list,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyQueueListEvent value) empty,
    required TResult Function(ReadyQueueListEvent value) list,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyQueueListEvent value)? empty,
    TResult? Function(ReadyQueueListEvent value)? list,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyQueueListEvent value)? empty,
    TResult Function(ReadyQueueListEvent value)? list,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class EmptyQueueListEvent implements QueueListEvent {
  const factory EmptyQueueListEvent() = _$EmptyQueueListEventImpl;
}

/// @nodoc
abstract class _$$ReadyQueueListEventImplCopyWith<$Res> {
  factory _$$ReadyQueueListEventImplCopyWith(_$ReadyQueueListEventImpl value,
          $Res Function(_$ReadyQueueListEventImpl) then) =
      __$$ReadyQueueListEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Episode playing, List<Episode> queue});

  $EpisodeCopyWith<$Res> get playing;
}

/// @nodoc
class __$$ReadyQueueListEventImplCopyWithImpl<$Res>
    extends _$QueueListEventCopyWithImpl<$Res, _$ReadyQueueListEventImpl>
    implements _$$ReadyQueueListEventImplCopyWith<$Res> {
  __$$ReadyQueueListEventImplCopyWithImpl(_$ReadyQueueListEventImpl _value,
      $Res Function(_$ReadyQueueListEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playing = null,
    Object? queue = null,
  }) {
    return _then(_$ReadyQueueListEventImpl(
      playing: null == playing
          ? _value.playing
          : playing // ignore: cast_nullable_to_non_nullable
              as Episode,
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $EpisodeCopyWith<$Res> get playing {
    return $EpisodeCopyWith<$Res>(_value.playing, (value) {
      return _then(_value.copyWith(playing: value));
    });
  }
}

/// @nodoc

class _$ReadyQueueListEventImpl implements ReadyQueueListEvent {
  const _$ReadyQueueListEventImpl(
      {required this.playing, required final List<Episode> queue})
      : _queue = queue;

  @override
  final Episode playing;
  final List<Episode> _queue;
  @override
  List<Episode> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  @override
  String toString() {
    return 'QueueListEvent.list(playing: $playing, queue: $queue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadyQueueListEventImpl &&
            (identical(other.playing, playing) || other.playing == playing) &&
            const DeepCollectionEquality().equals(other._queue, _queue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, playing, const DeepCollectionEquality().hash(_queue));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadyQueueListEventImplCopyWith<_$ReadyQueueListEventImpl> get copyWith =>
      __$$ReadyQueueListEventImplCopyWithImpl<_$ReadyQueueListEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(Episode playing, List<Episode> queue) list,
  }) {
    return list(playing, queue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function(Episode playing, List<Episode> queue)? list,
  }) {
    return list?.call(playing, queue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(Episode playing, List<Episode> queue)? list,
    required TResult orElse(),
  }) {
    if (list != null) {
      return list(playing, queue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmptyQueueListEvent value) empty,
    required TResult Function(ReadyQueueListEvent value) list,
  }) {
    return list(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmptyQueueListEvent value)? empty,
    TResult? Function(ReadyQueueListEvent value)? list,
  }) {
    return list?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmptyQueueListEvent value)? empty,
    TResult Function(ReadyQueueListEvent value)? list,
    required TResult orElse(),
  }) {
    if (list != null) {
      return list(this);
    }
    return orElse();
  }
}

abstract class ReadyQueueListEvent implements QueueListEvent {
  const factory ReadyQueueListEvent(
      {required final Episode playing,
      required final List<Episode> queue}) = _$ReadyQueueListEventImpl;

  Episode get playing;
  List<Episode> get queue;
  @JsonKey(ignore: true)
  _$$ReadyQueueListEventImplCopyWith<_$ReadyQueueListEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
