// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_prompt_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewPromptStats {

/// Cumulative content listened since the feature was installed.
 int get totalListenedMs;/// Next milestone at which the prompt should fire.
///
/// First prompt fires when [totalListenedMs] reaches this value
/// (default 10 hours). Each shown prompt advances it by 100 hours.
 int get nextPromptThresholdMs;/// User selected "Don't ask again" — never auto-prompt again.
 bool get userOptedOut;/// User tapped "Rate now" or the manual "Rate the App" tile — assume
/// they rated; never auto-prompt again.
 bool get userTappedRateNow;/// Timestamp of the last shown prompt (debugging / future throttling).
 DateTime? get lastPromptedAt;
/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewPromptStatsCopyWith<ReviewPromptStats> get copyWith => _$ReviewPromptStatsCopyWithImpl<ReviewPromptStats>(this as ReviewPromptStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewPromptStats&&(identical(other.totalListenedMs, totalListenedMs) || other.totalListenedMs == totalListenedMs)&&(identical(other.nextPromptThresholdMs, nextPromptThresholdMs) || other.nextPromptThresholdMs == nextPromptThresholdMs)&&(identical(other.userOptedOut, userOptedOut) || other.userOptedOut == userOptedOut)&&(identical(other.userTappedRateNow, userTappedRateNow) || other.userTappedRateNow == userTappedRateNow)&&(identical(other.lastPromptedAt, lastPromptedAt) || other.lastPromptedAt == lastPromptedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalListenedMs,nextPromptThresholdMs,userOptedOut,userTappedRateNow,lastPromptedAt);

@override
String toString() {
  return 'ReviewPromptStats(totalListenedMs: $totalListenedMs, nextPromptThresholdMs: $nextPromptThresholdMs, userOptedOut: $userOptedOut, userTappedRateNow: $userTappedRateNow, lastPromptedAt: $lastPromptedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewPromptStatsCopyWith<$Res>  {
  factory $ReviewPromptStatsCopyWith(ReviewPromptStats value, $Res Function(ReviewPromptStats) _then) = _$ReviewPromptStatsCopyWithImpl;
@useResult
$Res call({
 int totalListenedMs, int nextPromptThresholdMs, bool userOptedOut, bool userTappedRateNow, DateTime? lastPromptedAt
});




}
/// @nodoc
class _$ReviewPromptStatsCopyWithImpl<$Res>
    implements $ReviewPromptStatsCopyWith<$Res> {
  _$ReviewPromptStatsCopyWithImpl(this._self, this._then);

  final ReviewPromptStats _self;
  final $Res Function(ReviewPromptStats) _then;

/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalListenedMs = null,Object? nextPromptThresholdMs = null,Object? userOptedOut = null,Object? userTappedRateNow = null,Object? lastPromptedAt = freezed,}) {
  return _then(_self.copyWith(
totalListenedMs: null == totalListenedMs ? _self.totalListenedMs : totalListenedMs // ignore: cast_nullable_to_non_nullable
as int,nextPromptThresholdMs: null == nextPromptThresholdMs ? _self.nextPromptThresholdMs : nextPromptThresholdMs // ignore: cast_nullable_to_non_nullable
as int,userOptedOut: null == userOptedOut ? _self.userOptedOut : userOptedOut // ignore: cast_nullable_to_non_nullable
as bool,userTappedRateNow: null == userTappedRateNow ? _self.userTappedRateNow : userTappedRateNow // ignore: cast_nullable_to_non_nullable
as bool,lastPromptedAt: freezed == lastPromptedAt ? _self.lastPromptedAt : lastPromptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewPromptStats].
extension ReviewPromptStatsPatterns on ReviewPromptStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewPromptStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewPromptStats value)  $default,){
final _that = this;
switch (_that) {
case _ReviewPromptStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewPromptStats value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalListenedMs,  int nextPromptThresholdMs,  bool userOptedOut,  bool userTappedRateNow,  DateTime? lastPromptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
return $default(_that.totalListenedMs,_that.nextPromptThresholdMs,_that.userOptedOut,_that.userTappedRateNow,_that.lastPromptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalListenedMs,  int nextPromptThresholdMs,  bool userOptedOut,  bool userTappedRateNow,  DateTime? lastPromptedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewPromptStats():
return $default(_that.totalListenedMs,_that.nextPromptThresholdMs,_that.userOptedOut,_that.userTappedRateNow,_that.lastPromptedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalListenedMs,  int nextPromptThresholdMs,  bool userOptedOut,  bool userTappedRateNow,  DateTime? lastPromptedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
return $default(_that.totalListenedMs,_that.nextPromptThresholdMs,_that.userOptedOut,_that.userTappedRateNow,_that.lastPromptedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewPromptStats implements ReviewPromptStats {
  const _ReviewPromptStats({this.totalListenedMs = 0, this.nextPromptThresholdMs = reviewPromptInitialThresholdMs, this.userOptedOut = false, this.userTappedRateNow = false, this.lastPromptedAt});


/// Cumulative content listened since the feature was installed.
@override@JsonKey() final  int totalListenedMs;
/// Next milestone at which the prompt should fire.
///
/// First prompt fires when [totalListenedMs] reaches this value
/// (default 10 hours). Each shown prompt advances it by 100 hours.
@override@JsonKey() final  int nextPromptThresholdMs;
/// User selected "Don't ask again" — never auto-prompt again.
@override@JsonKey() final  bool userOptedOut;
/// User tapped "Rate now" or the manual "Rate the App" tile — assume
/// they rated; never auto-prompt again.
@override@JsonKey() final  bool userTappedRateNow;
/// Timestamp of the last shown prompt (debugging / future throttling).
@override final  DateTime? lastPromptedAt;

/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewPromptStatsCopyWith<_ReviewPromptStats> get copyWith => __$ReviewPromptStatsCopyWithImpl<_ReviewPromptStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewPromptStats&&(identical(other.totalListenedMs, totalListenedMs) || other.totalListenedMs == totalListenedMs)&&(identical(other.nextPromptThresholdMs, nextPromptThresholdMs) || other.nextPromptThresholdMs == nextPromptThresholdMs)&&(identical(other.userOptedOut, userOptedOut) || other.userOptedOut == userOptedOut)&&(identical(other.userTappedRateNow, userTappedRateNow) || other.userTappedRateNow == userTappedRateNow)&&(identical(other.lastPromptedAt, lastPromptedAt) || other.lastPromptedAt == lastPromptedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalListenedMs,nextPromptThresholdMs,userOptedOut,userTappedRateNow,lastPromptedAt);

@override
String toString() {
  return 'ReviewPromptStats(totalListenedMs: $totalListenedMs, nextPromptThresholdMs: $nextPromptThresholdMs, userOptedOut: $userOptedOut, userTappedRateNow: $userTappedRateNow, lastPromptedAt: $lastPromptedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewPromptStatsCopyWith<$Res> implements $ReviewPromptStatsCopyWith<$Res> {
  factory _$ReviewPromptStatsCopyWith(_ReviewPromptStats value, $Res Function(_ReviewPromptStats) _then) = __$ReviewPromptStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalListenedMs, int nextPromptThresholdMs, bool userOptedOut, bool userTappedRateNow, DateTime? lastPromptedAt
});




}
/// @nodoc
class __$ReviewPromptStatsCopyWithImpl<$Res>
    implements _$ReviewPromptStatsCopyWith<$Res> {
  __$ReviewPromptStatsCopyWithImpl(this._self, this._then);

  final _ReviewPromptStats _self;
  final $Res Function(_ReviewPromptStats) _then;

/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalListenedMs = null,Object? nextPromptThresholdMs = null,Object? userOptedOut = null,Object? userTappedRateNow = null,Object? lastPromptedAt = freezed,}) {
  return _then(_ReviewPromptStats(
totalListenedMs: null == totalListenedMs ? _self.totalListenedMs : totalListenedMs // ignore: cast_nullable_to_non_nullable
as int,nextPromptThresholdMs: null == nextPromptThresholdMs ? _self.nextPromptThresholdMs : nextPromptThresholdMs // ignore: cast_nullable_to_non_nullable
as int,userOptedOut: null == userOptedOut ? _self.userOptedOut : userOptedOut // ignore: cast_nullable_to_non_nullable
as bool,userTappedRateNow: null == userTappedRateNow ? _self.userTappedRateNow : userTappedRateNow // ignore: cast_nullable_to_non_nullable
as bool,lastPromptedAt: freezed == lastPromptedAt ? _self.lastPromptedAt : lastPromptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
