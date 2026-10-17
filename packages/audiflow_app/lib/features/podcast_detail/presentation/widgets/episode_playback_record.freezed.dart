// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_playback_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackRecordValues {

 int get completedCount; int get playCount; int get listenedMinutes; int get realtimeMinutes; DateTime? get firstPlayedDay; DateTime? get lastPlayedDay;
/// Create a copy of PlaybackRecordValues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackRecordValuesCopyWith<PlaybackRecordValues> get copyWith => _$PlaybackRecordValuesCopyWithImpl<PlaybackRecordValues>(this as PlaybackRecordValues, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackRecordValues&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.listenedMinutes, listenedMinutes) || other.listenedMinutes == listenedMinutes)&&(identical(other.realtimeMinutes, realtimeMinutes) || other.realtimeMinutes == realtimeMinutes)&&(identical(other.firstPlayedDay, firstPlayedDay) || other.firstPlayedDay == firstPlayedDay)&&(identical(other.lastPlayedDay, lastPlayedDay) || other.lastPlayedDay == lastPlayedDay));
}


@override
int get hashCode => Object.hash(runtimeType,completedCount,playCount,listenedMinutes,realtimeMinutes,firstPlayedDay,lastPlayedDay);

@override
String toString() {
  return 'PlaybackRecordValues(completedCount: $completedCount, playCount: $playCount, listenedMinutes: $listenedMinutes, realtimeMinutes: $realtimeMinutes, firstPlayedDay: $firstPlayedDay, lastPlayedDay: $lastPlayedDay)';
}


}

/// @nodoc
abstract mixin class $PlaybackRecordValuesCopyWith<$Res>  {
  factory $PlaybackRecordValuesCopyWith(PlaybackRecordValues value, $Res Function(PlaybackRecordValues) _then) = _$PlaybackRecordValuesCopyWithImpl;
@useResult
$Res call({
 int completedCount, int playCount, int listenedMinutes, int realtimeMinutes, DateTime? firstPlayedDay, DateTime? lastPlayedDay
});




}
/// @nodoc
class _$PlaybackRecordValuesCopyWithImpl<$Res>
    implements $PlaybackRecordValuesCopyWith<$Res> {
  _$PlaybackRecordValuesCopyWithImpl(this._self, this._then);

  final PlaybackRecordValues _self;
  final $Res Function(PlaybackRecordValues) _then;

/// Create a copy of PlaybackRecordValues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedCount = null,Object? playCount = null,Object? listenedMinutes = null,Object? realtimeMinutes = null,Object? firstPlayedDay = freezed,Object? lastPlayedDay = freezed,}) {
  return _then(_self.copyWith(
completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,listenedMinutes: null == listenedMinutes ? _self.listenedMinutes : listenedMinutes // ignore: cast_nullable_to_non_nullable
as int,realtimeMinutes: null == realtimeMinutes ? _self.realtimeMinutes : realtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,firstPlayedDay: freezed == firstPlayedDay ? _self.firstPlayedDay : firstPlayedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedDay: freezed == lastPlayedDay ? _self.lastPlayedDay : lastPlayedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackRecordValues].
extension PlaybackRecordValuesPatterns on PlaybackRecordValues {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackRecordValues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackRecordValues() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackRecordValues value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackRecordValues():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackRecordValues value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackRecordValues() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int completedCount,  int playCount,  int listenedMinutes,  int realtimeMinutes,  DateTime? firstPlayedDay,  DateTime? lastPlayedDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackRecordValues() when $default != null:
return $default(_that.completedCount,_that.playCount,_that.listenedMinutes,_that.realtimeMinutes,_that.firstPlayedDay,_that.lastPlayedDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int completedCount,  int playCount,  int listenedMinutes,  int realtimeMinutes,  DateTime? firstPlayedDay,  DateTime? lastPlayedDay)  $default,) {final _that = this;
switch (_that) {
case _PlaybackRecordValues():
return $default(_that.completedCount,_that.playCount,_that.listenedMinutes,_that.realtimeMinutes,_that.firstPlayedDay,_that.lastPlayedDay);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int completedCount,  int playCount,  int listenedMinutes,  int realtimeMinutes,  DateTime? firstPlayedDay,  DateTime? lastPlayedDay)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackRecordValues() when $default != null:
return $default(_that.completedCount,_that.playCount,_that.listenedMinutes,_that.realtimeMinutes,_that.firstPlayedDay,_that.lastPlayedDay);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackRecordValues implements PlaybackRecordValues {
  const _PlaybackRecordValues({required this.completedCount, required this.playCount, required this.listenedMinutes, required this.realtimeMinutes, required this.firstPlayedDay, required this.lastPlayedDay});
  

@override final  int completedCount;
@override final  int playCount;
@override final  int listenedMinutes;
@override final  int realtimeMinutes;
@override final  DateTime? firstPlayedDay;
@override final  DateTime? lastPlayedDay;

/// Create a copy of PlaybackRecordValues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackRecordValuesCopyWith<_PlaybackRecordValues> get copyWith => __$PlaybackRecordValuesCopyWithImpl<_PlaybackRecordValues>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackRecordValues&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.listenedMinutes, listenedMinutes) || other.listenedMinutes == listenedMinutes)&&(identical(other.realtimeMinutes, realtimeMinutes) || other.realtimeMinutes == realtimeMinutes)&&(identical(other.firstPlayedDay, firstPlayedDay) || other.firstPlayedDay == firstPlayedDay)&&(identical(other.lastPlayedDay, lastPlayedDay) || other.lastPlayedDay == lastPlayedDay));
}


@override
int get hashCode => Object.hash(runtimeType,completedCount,playCount,listenedMinutes,realtimeMinutes,firstPlayedDay,lastPlayedDay);

@override
String toString() {
  return 'PlaybackRecordValues(completedCount: $completedCount, playCount: $playCount, listenedMinutes: $listenedMinutes, realtimeMinutes: $realtimeMinutes, firstPlayedDay: $firstPlayedDay, lastPlayedDay: $lastPlayedDay)';
}


}

/// @nodoc
abstract mixin class _$PlaybackRecordValuesCopyWith<$Res> implements $PlaybackRecordValuesCopyWith<$Res> {
  factory _$PlaybackRecordValuesCopyWith(_PlaybackRecordValues value, $Res Function(_PlaybackRecordValues) _then) = __$PlaybackRecordValuesCopyWithImpl;
@override @useResult
$Res call({
 int completedCount, int playCount, int listenedMinutes, int realtimeMinutes, DateTime? firstPlayedDay, DateTime? lastPlayedDay
});




}
/// @nodoc
class __$PlaybackRecordValuesCopyWithImpl<$Res>
    implements _$PlaybackRecordValuesCopyWith<$Res> {
  __$PlaybackRecordValuesCopyWithImpl(this._self, this._then);

  final _PlaybackRecordValues _self;
  final $Res Function(_PlaybackRecordValues) _then;

/// Create a copy of PlaybackRecordValues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedCount = null,Object? playCount = null,Object? listenedMinutes = null,Object? realtimeMinutes = null,Object? firstPlayedDay = freezed,Object? lastPlayedDay = freezed,}) {
  return _then(_PlaybackRecordValues(
completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,listenedMinutes: null == listenedMinutes ? _self.listenedMinutes : listenedMinutes // ignore: cast_nullable_to_non_nullable
as int,realtimeMinutes: null == realtimeMinutes ? _self.realtimeMinutes : realtimeMinutes // ignore: cast_nullable_to_non_nullable
as int,firstPlayedDay: freezed == firstPlayedDay ? _self.firstPlayedDay : firstPlayedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayedDay: freezed == lastPlayedDay ? _self.lastPlayedDay : lastPlayedDay // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
