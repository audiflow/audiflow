// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TranscriptEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() clear,
    required TResult Function(String search) filter,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? clear,
    TResult? Function(String search)? filter,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? clear,
    TResult Function(String search)? filter,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptClearEvent value) clear,
    required TResult Function(TranscriptFilterEvent value) filter,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptClearEvent value)? clear,
    TResult? Function(TranscriptFilterEvent value)? filter,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptClearEvent value)? clear,
    TResult Function(TranscriptFilterEvent value)? filter,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptEventCopyWith<$Res> {
  factory $TranscriptEventCopyWith(
          TranscriptEvent value, $Res Function(TranscriptEvent) then) =
      _$TranscriptEventCopyWithImpl<$Res, TranscriptEvent>;
}

/// @nodoc
class _$TranscriptEventCopyWithImpl<$Res, $Val extends TranscriptEvent>
    implements $TranscriptEventCopyWith<$Res> {
  _$TranscriptEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$TranscriptClearEventImplCopyWith<$Res> {
  factory _$$TranscriptClearEventImplCopyWith(_$TranscriptClearEventImpl value,
          $Res Function(_$TranscriptClearEventImpl) then) =
      __$$TranscriptClearEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TranscriptClearEventImplCopyWithImpl<$Res>
    extends _$TranscriptEventCopyWithImpl<$Res, _$TranscriptClearEventImpl>
    implements _$$TranscriptClearEventImplCopyWith<$Res> {
  __$$TranscriptClearEventImplCopyWithImpl(_$TranscriptClearEventImpl _value,
      $Res Function(_$TranscriptClearEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TranscriptClearEventImpl implements TranscriptClearEvent {
  const _$TranscriptClearEventImpl();

  @override
  String toString() {
    return 'TranscriptEvent.clear()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptClearEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() clear,
    required TResult Function(String search) filter,
  }) {
    return clear();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? clear,
    TResult? Function(String search)? filter,
  }) {
    return clear?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? clear,
    TResult Function(String search)? filter,
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
    required TResult Function(TranscriptClearEvent value) clear,
    required TResult Function(TranscriptFilterEvent value) filter,
  }) {
    return clear(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptClearEvent value)? clear,
    TResult? Function(TranscriptFilterEvent value)? filter,
  }) {
    return clear?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptClearEvent value)? clear,
    TResult Function(TranscriptFilterEvent value)? filter,
    required TResult orElse(),
  }) {
    if (clear != null) {
      return clear(this);
    }
    return orElse();
  }
}

abstract class TranscriptClearEvent implements TranscriptEvent {
  const factory TranscriptClearEvent() = _$TranscriptClearEventImpl;
}

/// @nodoc
abstract class _$$TranscriptFilterEventImplCopyWith<$Res> {
  factory _$$TranscriptFilterEventImplCopyWith(
          _$TranscriptFilterEventImpl value,
          $Res Function(_$TranscriptFilterEventImpl) then) =
      __$$TranscriptFilterEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String search});
}

/// @nodoc
class __$$TranscriptFilterEventImplCopyWithImpl<$Res>
    extends _$TranscriptEventCopyWithImpl<$Res, _$TranscriptFilterEventImpl>
    implements _$$TranscriptFilterEventImplCopyWith<$Res> {
  __$$TranscriptFilterEventImplCopyWithImpl(_$TranscriptFilterEventImpl _value,
      $Res Function(_$TranscriptFilterEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
  }) {
    return _then(_$TranscriptFilterEventImpl(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TranscriptFilterEventImpl implements TranscriptFilterEvent {
  const _$TranscriptFilterEventImpl({required this.search});

  @override
  final String search;

  @override
  String toString() {
    return 'TranscriptEvent.filter(search: $search)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptFilterEventImpl &&
            (identical(other.search, search) || other.search == search));
  }

  @override
  int get hashCode => Object.hash(runtimeType, search);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptFilterEventImplCopyWith<_$TranscriptFilterEventImpl>
      get copyWith => __$$TranscriptFilterEventImplCopyWithImpl<
          _$TranscriptFilterEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() clear,
    required TResult Function(String search) filter,
  }) {
    return filter(search);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? clear,
    TResult? Function(String search)? filter,
  }) {
    return filter?.call(search);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? clear,
    TResult Function(String search)? filter,
    required TResult orElse(),
  }) {
    if (filter != null) {
      return filter(search);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptClearEvent value) clear,
    required TResult Function(TranscriptFilterEvent value) filter,
  }) {
    return filter(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptClearEvent value)? clear,
    TResult? Function(TranscriptFilterEvent value)? filter,
  }) {
    return filter?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptClearEvent value)? clear,
    TResult Function(TranscriptFilterEvent value)? filter,
    required TResult orElse(),
  }) {
    if (filter != null) {
      return filter(this);
    }
    return orElse();
  }
}

abstract class TranscriptFilterEvent implements TranscriptEvent {
  const factory TranscriptFilterEvent({required final String search}) =
      _$TranscriptFilterEventImpl;

  String get search;
  @JsonKey(ignore: true)
  _$$TranscriptFilterEventImplCopyWith<_$TranscriptFilterEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TranscriptState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unavailable,
    required TResult Function() loading,
    required TResult Function(Transcript transcript, bool isFiltered) update,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unavailable,
    TResult? Function()? loading,
    TResult? Function(Transcript transcript, bool isFiltered)? update,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unavailable,
    TResult Function()? loading,
    TResult Function(Transcript transcript, bool isFiltered)? update,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptUnavailableState value) unavailable,
    required TResult Function(TranscriptLoadingState value) loading,
    required TResult Function(TranscriptUpdateState value) update,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptUnavailableState value)? unavailable,
    TResult? Function(TranscriptLoadingState value)? loading,
    TResult? Function(TranscriptUpdateState value)? update,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptUnavailableState value)? unavailable,
    TResult Function(TranscriptLoadingState value)? loading,
    TResult Function(TranscriptUpdateState value)? update,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranscriptStateCopyWith<$Res> {
  factory $TranscriptStateCopyWith(
          TranscriptState value, $Res Function(TranscriptState) then) =
      _$TranscriptStateCopyWithImpl<$Res, TranscriptState>;
}

/// @nodoc
class _$TranscriptStateCopyWithImpl<$Res, $Val extends TranscriptState>
    implements $TranscriptStateCopyWith<$Res> {
  _$TranscriptStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$TranscriptUnavailableStateImplCopyWith<$Res> {
  factory _$$TranscriptUnavailableStateImplCopyWith(
          _$TranscriptUnavailableStateImpl value,
          $Res Function(_$TranscriptUnavailableStateImpl) then) =
      __$$TranscriptUnavailableStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TranscriptUnavailableStateImplCopyWithImpl<$Res>
    extends _$TranscriptStateCopyWithImpl<$Res,
        _$TranscriptUnavailableStateImpl>
    implements _$$TranscriptUnavailableStateImplCopyWith<$Res> {
  __$$TranscriptUnavailableStateImplCopyWithImpl(
      _$TranscriptUnavailableStateImpl _value,
      $Res Function(_$TranscriptUnavailableStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TranscriptUnavailableStateImpl implements TranscriptUnavailableState {
  const _$TranscriptUnavailableStateImpl();

  @override
  String toString() {
    return 'TranscriptState.unavailable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptUnavailableStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unavailable,
    required TResult Function() loading,
    required TResult Function(Transcript transcript, bool isFiltered) update,
  }) {
    return unavailable();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unavailable,
    TResult? Function()? loading,
    TResult? Function(Transcript transcript, bool isFiltered)? update,
  }) {
    return unavailable?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unavailable,
    TResult Function()? loading,
    TResult Function(Transcript transcript, bool isFiltered)? update,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptUnavailableState value) unavailable,
    required TResult Function(TranscriptLoadingState value) loading,
    required TResult Function(TranscriptUpdateState value) update,
  }) {
    return unavailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptUnavailableState value)? unavailable,
    TResult? Function(TranscriptLoadingState value)? loading,
    TResult? Function(TranscriptUpdateState value)? update,
  }) {
    return unavailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptUnavailableState value)? unavailable,
    TResult Function(TranscriptLoadingState value)? loading,
    TResult Function(TranscriptUpdateState value)? update,
    required TResult orElse(),
  }) {
    if (unavailable != null) {
      return unavailable(this);
    }
    return orElse();
  }
}

abstract class TranscriptUnavailableState implements TranscriptState {
  const factory TranscriptUnavailableState() = _$TranscriptUnavailableStateImpl;
}

/// @nodoc
abstract class _$$TranscriptLoadingStateImplCopyWith<$Res> {
  factory _$$TranscriptLoadingStateImplCopyWith(
          _$TranscriptLoadingStateImpl value,
          $Res Function(_$TranscriptLoadingStateImpl) then) =
      __$$TranscriptLoadingStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TranscriptLoadingStateImplCopyWithImpl<$Res>
    extends _$TranscriptStateCopyWithImpl<$Res, _$TranscriptLoadingStateImpl>
    implements _$$TranscriptLoadingStateImplCopyWith<$Res> {
  __$$TranscriptLoadingStateImplCopyWithImpl(
      _$TranscriptLoadingStateImpl _value,
      $Res Function(_$TranscriptLoadingStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TranscriptLoadingStateImpl implements TranscriptLoadingState {
  const _$TranscriptLoadingStateImpl();

  @override
  String toString() {
    return 'TranscriptState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptLoadingStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unavailable,
    required TResult Function() loading,
    required TResult Function(Transcript transcript, bool isFiltered) update,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unavailable,
    TResult? Function()? loading,
    TResult? Function(Transcript transcript, bool isFiltered)? update,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unavailable,
    TResult Function()? loading,
    TResult Function(Transcript transcript, bool isFiltered)? update,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptUnavailableState value) unavailable,
    required TResult Function(TranscriptLoadingState value) loading,
    required TResult Function(TranscriptUpdateState value) update,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptUnavailableState value)? unavailable,
    TResult? Function(TranscriptLoadingState value)? loading,
    TResult? Function(TranscriptUpdateState value)? update,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptUnavailableState value)? unavailable,
    TResult Function(TranscriptLoadingState value)? loading,
    TResult Function(TranscriptUpdateState value)? update,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TranscriptLoadingState implements TranscriptState {
  const factory TranscriptLoadingState() = _$TranscriptLoadingStateImpl;
}

/// @nodoc
abstract class _$$TranscriptUpdateStateImplCopyWith<$Res> {
  factory _$$TranscriptUpdateStateImplCopyWith(
          _$TranscriptUpdateStateImpl value,
          $Res Function(_$TranscriptUpdateStateImpl) then) =
      __$$TranscriptUpdateStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Transcript transcript, bool isFiltered});

  $TranscriptCopyWith<$Res> get transcript;
}

/// @nodoc
class __$$TranscriptUpdateStateImplCopyWithImpl<$Res>
    extends _$TranscriptStateCopyWithImpl<$Res, _$TranscriptUpdateStateImpl>
    implements _$$TranscriptUpdateStateImplCopyWith<$Res> {
  __$$TranscriptUpdateStateImplCopyWithImpl(_$TranscriptUpdateStateImpl _value,
      $Res Function(_$TranscriptUpdateStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcript = null,
    Object? isFiltered = null,
  }) {
    return _then(_$TranscriptUpdateStateImpl(
      transcript: null == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as Transcript,
      isFiltered: null == isFiltered
          ? _value.isFiltered
          : isFiltered // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $TranscriptCopyWith<$Res> get transcript {
    return $TranscriptCopyWith<$Res>(_value.transcript, (value) {
      return _then(_value.copyWith(transcript: value));
    });
  }
}

/// @nodoc

class _$TranscriptUpdateStateImpl implements TranscriptUpdateState {
  const _$TranscriptUpdateStateImpl(
      {required this.transcript, this.isFiltered = false});

  @override
  final Transcript transcript;
  @override
  @JsonKey()
  final bool isFiltered;

  @override
  String toString() {
    return 'TranscriptState.update(transcript: $transcript, isFiltered: $isFiltered)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranscriptUpdateStateImpl &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.isFiltered, isFiltered) ||
                other.isFiltered == isFiltered));
  }

  @override
  int get hashCode => Object.hash(runtimeType, transcript, isFiltered);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TranscriptUpdateStateImplCopyWith<_$TranscriptUpdateStateImpl>
      get copyWith => __$$TranscriptUpdateStateImplCopyWithImpl<
          _$TranscriptUpdateStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() unavailable,
    required TResult Function() loading,
    required TResult Function(Transcript transcript, bool isFiltered) update,
  }) {
    return update(transcript, isFiltered);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? unavailable,
    TResult? Function()? loading,
    TResult? Function(Transcript transcript, bool isFiltered)? update,
  }) {
    return update?.call(transcript, isFiltered);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? unavailable,
    TResult Function()? loading,
    TResult Function(Transcript transcript, bool isFiltered)? update,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(transcript, isFiltered);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TranscriptUnavailableState value) unavailable,
    required TResult Function(TranscriptLoadingState value) loading,
    required TResult Function(TranscriptUpdateState value) update,
  }) {
    return update(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TranscriptUnavailableState value)? unavailable,
    TResult? Function(TranscriptLoadingState value)? loading,
    TResult? Function(TranscriptUpdateState value)? update,
  }) {
    return update?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TranscriptUnavailableState value)? unavailable,
    TResult Function(TranscriptLoadingState value)? loading,
    TResult Function(TranscriptUpdateState value)? update,
    required TResult orElse(),
  }) {
    if (update != null) {
      return update(this);
    }
    return orElse();
  }
}

abstract class TranscriptUpdateState implements TranscriptState {
  const factory TranscriptUpdateState(
      {required final Transcript transcript,
      final bool isFiltered}) = _$TranscriptUpdateStateImpl;

  Transcript get transcript;
  bool get isFiltered;
  @JsonKey(ignore: true)
  _$$TranscriptUpdateStateImplCopyWith<_$TranscriptUpdateStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
