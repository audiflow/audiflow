// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SleepTimerState {

 SleepTimerConfig get config; int get lastMinutes; int get lastEpisodes;
/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepTimerStateCopyWith<SleepTimerState> get copyWith => _$SleepTimerStateCopyWithImpl<SleepTimerState>(this as SleepTimerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerState&&(identical(other.config, config) || other.config == config)&&(identical(other.lastMinutes, lastMinutes) || other.lastMinutes == lastMinutes)&&(identical(other.lastEpisodes, lastEpisodes) || other.lastEpisodes == lastEpisodes));
}


@override
int get hashCode => Object.hash(runtimeType,config,lastMinutes,lastEpisodes);

@override
String toString() {
  return 'SleepTimerState(config: $config, lastMinutes: $lastMinutes, lastEpisodes: $lastEpisodes)';
}


}

/// @nodoc
abstract mixin class $SleepTimerStateCopyWith<$Res>  {
  factory $SleepTimerStateCopyWith(SleepTimerState value, $Res Function(SleepTimerState) _then) = _$SleepTimerStateCopyWithImpl;
@useResult
$Res call({
 SleepTimerConfig config, int lastMinutes, int lastEpisodes
});


$SleepTimerConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$SleepTimerStateCopyWithImpl<$Res>
    implements $SleepTimerStateCopyWith<$Res> {
  _$SleepTimerStateCopyWithImpl(this._self, this._then);

  final SleepTimerState _self;
  final $Res Function(SleepTimerState) _then;

/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? config = null,Object? lastMinutes = null,Object? lastEpisodes = null,}) {
  return _then(_self.copyWith(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SleepTimerConfig,lastMinutes: null == lastMinutes ? _self.lastMinutes : lastMinutes // ignore: cast_nullable_to_non_nullable
as int,lastEpisodes: null == lastEpisodes ? _self.lastEpisodes : lastEpisodes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepTimerConfigCopyWith<$Res> get config {

  return $SleepTimerConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [SleepTimerState].
extension SleepTimerStatePatterns on SleepTimerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SleepTimerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SleepTimerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SleepTimerState value)  $default,){
final _that = this;
switch (_that) {
case _SleepTimerState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SleepTimerState value)?  $default,){
final _that = this;
switch (_that) {
case _SleepTimerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SleepTimerConfig config,  int lastMinutes,  int lastEpisodes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SleepTimerState() when $default != null:
return $default(_that.config,_that.lastMinutes,_that.lastEpisodes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SleepTimerConfig config,  int lastMinutes,  int lastEpisodes)  $default,) {final _that = this;
switch (_that) {
case _SleepTimerState():
return $default(_that.config,_that.lastMinutes,_that.lastEpisodes);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SleepTimerConfig config,  int lastMinutes,  int lastEpisodes)?  $default,) {final _that = this;
switch (_that) {
case _SleepTimerState() when $default != null:
return $default(_that.config,_that.lastMinutes,_that.lastEpisodes);case _:
  return null;

}
}

}

/// @nodoc


class _SleepTimerState implements SleepTimerState {
  const _SleepTimerState({required this.config, required this.lastMinutes, required this.lastEpisodes});


@override final  SleepTimerConfig config;
@override final  int lastMinutes;
@override final  int lastEpisodes;

/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SleepTimerStateCopyWith<_SleepTimerState> get copyWith => __$SleepTimerStateCopyWithImpl<_SleepTimerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SleepTimerState&&(identical(other.config, config) || other.config == config)&&(identical(other.lastMinutes, lastMinutes) || other.lastMinutes == lastMinutes)&&(identical(other.lastEpisodes, lastEpisodes) || other.lastEpisodes == lastEpisodes));
}


@override
int get hashCode => Object.hash(runtimeType,config,lastMinutes,lastEpisodes);

@override
String toString() {
  return 'SleepTimerState(config: $config, lastMinutes: $lastMinutes, lastEpisodes: $lastEpisodes)';
}


}

/// @nodoc
abstract mixin class _$SleepTimerStateCopyWith<$Res> implements $SleepTimerStateCopyWith<$Res> {
  factory _$SleepTimerStateCopyWith(_SleepTimerState value, $Res Function(_SleepTimerState) _then) = __$SleepTimerStateCopyWithImpl;
@override @useResult
$Res call({
 SleepTimerConfig config, int lastMinutes, int lastEpisodes
});


@override $SleepTimerConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$SleepTimerStateCopyWithImpl<$Res>
    implements _$SleepTimerStateCopyWith<$Res> {
  __$SleepTimerStateCopyWithImpl(this._self, this._then);

  final _SleepTimerState _self;
  final $Res Function(_SleepTimerState) _then;

/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? config = null,Object? lastMinutes = null,Object? lastEpisodes = null,}) {
  return _then(_SleepTimerState(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SleepTimerConfig,lastMinutes: null == lastMinutes ? _self.lastMinutes : lastMinutes // ignore: cast_nullable_to_non_nullable
as int,lastEpisodes: null == lastEpisodes ? _self.lastEpisodes : lastEpisodes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SleepTimerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SleepTimerConfigCopyWith<$Res> get config {

  return $SleepTimerConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

// dart format on
