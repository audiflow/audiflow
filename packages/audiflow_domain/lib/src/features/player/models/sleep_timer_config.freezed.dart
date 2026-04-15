// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_timer_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SleepTimerConfig {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimerConfig()';
}


}

/// @nodoc
class $SleepTimerConfigCopyWith<$Res>  {
$SleepTimerConfigCopyWith(SleepTimerConfig _, $Res Function(SleepTimerConfig) __);
}


/// Adds pattern-matching-related methods to [SleepTimerConfig].
extension SleepTimerConfigPatterns on SleepTimerConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SleepTimerConfigOff value)?  off,TResult Function( SleepTimerConfigEndOfEpisode value)?  endOfEpisode,TResult Function( SleepTimerConfigEndOfChapter value)?  endOfChapter,TResult Function( SleepTimerConfigDuration value)?  duration,TResult Function( SleepTimerConfigEpisodes value)?  episodes,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SleepTimerConfigOff() when off != null:
return off(_that);case SleepTimerConfigEndOfEpisode() when endOfEpisode != null:
return endOfEpisode(_that);case SleepTimerConfigEndOfChapter() when endOfChapter != null:
return endOfChapter(_that);case SleepTimerConfigDuration() when duration != null:
return duration(_that);case SleepTimerConfigEpisodes() when episodes != null:
return episodes(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SleepTimerConfigOff value)  off,required TResult Function( SleepTimerConfigEndOfEpisode value)  endOfEpisode,required TResult Function( SleepTimerConfigEndOfChapter value)  endOfChapter,required TResult Function( SleepTimerConfigDuration value)  duration,required TResult Function( SleepTimerConfigEpisodes value)  episodes,}){
final _that = this;
switch (_that) {
case SleepTimerConfigOff():
return off(_that);case SleepTimerConfigEndOfEpisode():
return endOfEpisode(_that);case SleepTimerConfigEndOfChapter():
return endOfChapter(_that);case SleepTimerConfigDuration():
return duration(_that);case SleepTimerConfigEpisodes():
return episodes(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SleepTimerConfigOff value)?  off,TResult? Function( SleepTimerConfigEndOfEpisode value)?  endOfEpisode,TResult? Function( SleepTimerConfigEndOfChapter value)?  endOfChapter,TResult? Function( SleepTimerConfigDuration value)?  duration,TResult? Function( SleepTimerConfigEpisodes value)?  episodes,}){
final _that = this;
switch (_that) {
case SleepTimerConfigOff() when off != null:
return off(_that);case SleepTimerConfigEndOfEpisode() when endOfEpisode != null:
return endOfEpisode(_that);case SleepTimerConfigEndOfChapter() when endOfChapter != null:
return endOfChapter(_that);case SleepTimerConfigDuration() when duration != null:
return duration(_that);case SleepTimerConfigEpisodes() when episodes != null:
return episodes(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  off,TResult Function()?  endOfEpisode,TResult Function()?  endOfChapter,TResult Function( Duration total,  DateTime deadline)?  duration,TResult Function( int total,  int remaining)?  episodes,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SleepTimerConfigOff() when off != null:
return off();case SleepTimerConfigEndOfEpisode() when endOfEpisode != null:
return endOfEpisode();case SleepTimerConfigEndOfChapter() when endOfChapter != null:
return endOfChapter();case SleepTimerConfigDuration() when duration != null:
return duration(_that.total,_that.deadline);case SleepTimerConfigEpisodes() when episodes != null:
return episodes(_that.total,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  off,required TResult Function()  endOfEpisode,required TResult Function()  endOfChapter,required TResult Function( Duration total,  DateTime deadline)  duration,required TResult Function( int total,  int remaining)  episodes,}) {final _that = this;
switch (_that) {
case SleepTimerConfigOff():
return off();case SleepTimerConfigEndOfEpisode():
return endOfEpisode();case SleepTimerConfigEndOfChapter():
return endOfChapter();case SleepTimerConfigDuration():
return duration(_that.total,_that.deadline);case SleepTimerConfigEpisodes():
return episodes(_that.total,_that.remaining);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  off,TResult? Function()?  endOfEpisode,TResult? Function()?  endOfChapter,TResult? Function( Duration total,  DateTime deadline)?  duration,TResult? Function( int total,  int remaining)?  episodes,}) {final _that = this;
switch (_that) {
case SleepTimerConfigOff() when off != null:
return off();case SleepTimerConfigEndOfEpisode() when endOfEpisode != null:
return endOfEpisode();case SleepTimerConfigEndOfChapter() when endOfChapter != null:
return endOfChapter();case SleepTimerConfigDuration() when duration != null:
return duration(_that.total,_that.deadline);case SleepTimerConfigEpisodes() when episodes != null:
return episodes(_that.total,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc


class SleepTimerConfigOff implements SleepTimerConfig {
  const SleepTimerConfigOff();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfigOff);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimerConfig.off()';
}


}




/// @nodoc


class SleepTimerConfigEndOfEpisode implements SleepTimerConfig {
  const SleepTimerConfigEndOfEpisode();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfigEndOfEpisode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimerConfig.endOfEpisode()';
}


}




/// @nodoc


class SleepTimerConfigEndOfChapter implements SleepTimerConfig {
  const SleepTimerConfigEndOfChapter();







@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfigEndOfChapter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SleepTimerConfig.endOfChapter()';
}


}




/// @nodoc


class SleepTimerConfigDuration implements SleepTimerConfig {
  const SleepTimerConfigDuration({required this.total, required this.deadline});


 final  Duration total;
 final  DateTime deadline;

/// Create a copy of SleepTimerConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepTimerConfigDurationCopyWith<SleepTimerConfigDuration> get copyWith => _$SleepTimerConfigDurationCopyWithImpl<SleepTimerConfigDuration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfigDuration&&(identical(other.total, total) || other.total == total)&&(identical(other.deadline, deadline) || other.deadline == deadline));
}


@override
int get hashCode => Object.hash(runtimeType,total,deadline);

@override
String toString() {
  return 'SleepTimerConfig.duration(total: $total, deadline: $deadline)';
}


}

/// @nodoc
abstract mixin class $SleepTimerConfigDurationCopyWith<$Res> implements $SleepTimerConfigCopyWith<$Res> {
  factory $SleepTimerConfigDurationCopyWith(SleepTimerConfigDuration value, $Res Function(SleepTimerConfigDuration) _then) = _$SleepTimerConfigDurationCopyWithImpl;
@useResult
$Res call({
 Duration total, DateTime deadline
});




}
/// @nodoc
class _$SleepTimerConfigDurationCopyWithImpl<$Res>
    implements $SleepTimerConfigDurationCopyWith<$Res> {
  _$SleepTimerConfigDurationCopyWithImpl(this._self, this._then);

  final SleepTimerConfigDuration _self;
  final $Res Function(SleepTimerConfigDuration) _then;

/// Create a copy of SleepTimerConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? total = null,Object? deadline = null,}) {
  return _then(SleepTimerConfigDuration(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Duration,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class SleepTimerConfigEpisodes implements SleepTimerConfig {
  const SleepTimerConfigEpisodes({required this.total, required this.remaining});


 final  int total;
 final  int remaining;

/// Create a copy of SleepTimerConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepTimerConfigEpisodesCopyWith<SleepTimerConfigEpisodes> get copyWith => _$SleepTimerConfigEpisodesCopyWithImpl<SleepTimerConfigEpisodes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepTimerConfigEpisodes&&(identical(other.total, total) || other.total == total)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,total,remaining);

@override
String toString() {
  return 'SleepTimerConfig.episodes(total: $total, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $SleepTimerConfigEpisodesCopyWith<$Res> implements $SleepTimerConfigCopyWith<$Res> {
  factory $SleepTimerConfigEpisodesCopyWith(SleepTimerConfigEpisodes value, $Res Function(SleepTimerConfigEpisodes) _then) = _$SleepTimerConfigEpisodesCopyWithImpl;
@useResult
$Res call({
 int total, int remaining
});




}
/// @nodoc
class _$SleepTimerConfigEpisodesCopyWithImpl<$Res>
    implements $SleepTimerConfigEpisodesCopyWith<$Res> {
  _$SleepTimerConfigEpisodesCopyWithImpl(this._self, this._then);

  final SleepTimerConfigEpisodes _self;
  final $Res Function(SleepTimerConfigEpisodes) _then;

/// Create a copy of SleepTimerConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? total = null,Object? remaining = null,}) {
  return _then(SleepTimerConfigEpisodes(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
