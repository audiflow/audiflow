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

 Duration get totalListened; Duration get nextPromptThreshold; ReviewPromptStatus get status; DateTime? get lastPromptedAt;
/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewPromptStatsCopyWith<ReviewPromptStats> get copyWith => _$ReviewPromptStatsCopyWithImpl<ReviewPromptStats>(this as ReviewPromptStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewPromptStats&&(identical(other.totalListened, totalListened) || other.totalListened == totalListened)&&(identical(other.nextPromptThreshold, nextPromptThreshold) || other.nextPromptThreshold == nextPromptThreshold)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastPromptedAt, lastPromptedAt) || other.lastPromptedAt == lastPromptedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalListened,nextPromptThreshold,status,lastPromptedAt);

@override
String toString() {
  return 'ReviewPromptStats(totalListened: $totalListened, nextPromptThreshold: $nextPromptThreshold, status: $status, lastPromptedAt: $lastPromptedAt)';
}


}

/// @nodoc
abstract mixin class $ReviewPromptStatsCopyWith<$Res>  {
  factory $ReviewPromptStatsCopyWith(ReviewPromptStats value, $Res Function(ReviewPromptStats) _then) = _$ReviewPromptStatsCopyWithImpl;
@useResult
$Res call({
 Duration totalListened, Duration nextPromptThreshold, ReviewPromptStatus status, DateTime? lastPromptedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? totalListened = null,Object? nextPromptThreshold = null,Object? status = null,Object? lastPromptedAt = freezed,}) {
  return _then(_self.copyWith(
totalListened: null == totalListened ? _self.totalListened : totalListened // ignore: cast_nullable_to_non_nullable
as Duration,nextPromptThreshold: null == nextPromptThreshold ? _self.nextPromptThreshold : nextPromptThreshold // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReviewPromptStatus,lastPromptedAt: freezed == lastPromptedAt ? _self.lastPromptedAt : lastPromptedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration totalListened,  Duration nextPromptThreshold,  ReviewPromptStatus status,  DateTime? lastPromptedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
return $default(_that.totalListened,_that.nextPromptThreshold,_that.status,_that.lastPromptedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration totalListened,  Duration nextPromptThreshold,  ReviewPromptStatus status,  DateTime? lastPromptedAt)  $default,) {final _that = this;
switch (_that) {
case _ReviewPromptStats():
return $default(_that.totalListened,_that.nextPromptThreshold,_that.status,_that.lastPromptedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration totalListened,  Duration nextPromptThreshold,  ReviewPromptStatus status,  DateTime? lastPromptedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReviewPromptStats() when $default != null:
return $default(_that.totalListened,_that.nextPromptThreshold,_that.status,_that.lastPromptedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewPromptStats implements ReviewPromptStats {
  const _ReviewPromptStats({this.totalListened = Duration.zero, this.nextPromptThreshold = reviewPromptInitialThreshold, this.status = ReviewPromptStatus.accumulating, this.lastPromptedAt});


@override@JsonKey() final  Duration totalListened;
@override@JsonKey() final  Duration nextPromptThreshold;
@override@JsonKey() final  ReviewPromptStatus status;
@override final  DateTime? lastPromptedAt;

/// Create a copy of ReviewPromptStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewPromptStatsCopyWith<_ReviewPromptStats> get copyWith => __$ReviewPromptStatsCopyWithImpl<_ReviewPromptStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewPromptStats&&(identical(other.totalListened, totalListened) || other.totalListened == totalListened)&&(identical(other.nextPromptThreshold, nextPromptThreshold) || other.nextPromptThreshold == nextPromptThreshold)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastPromptedAt, lastPromptedAt) || other.lastPromptedAt == lastPromptedAt));
}


@override
int get hashCode => Object.hash(runtimeType,totalListened,nextPromptThreshold,status,lastPromptedAt);

@override
String toString() {
  return 'ReviewPromptStats(totalListened: $totalListened, nextPromptThreshold: $nextPromptThreshold, status: $status, lastPromptedAt: $lastPromptedAt)';
}


}

/// @nodoc
abstract mixin class _$ReviewPromptStatsCopyWith<$Res> implements $ReviewPromptStatsCopyWith<$Res> {
  factory _$ReviewPromptStatsCopyWith(_ReviewPromptStats value, $Res Function(_ReviewPromptStats) _then) = __$ReviewPromptStatsCopyWithImpl;
@override @useResult
$Res call({
 Duration totalListened, Duration nextPromptThreshold, ReviewPromptStatus status, DateTime? lastPromptedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? totalListened = null,Object? nextPromptThreshold = null,Object? status = null,Object? lastPromptedAt = freezed,}) {
  return _then(_ReviewPromptStats(
totalListened: null == totalListened ? _self.totalListened : totalListened // ignore: cast_nullable_to_non_nullable
as Duration,nextPromptThreshold: null == nextPromptThreshold ? _self.nextPromptThreshold : nextPromptThreshold // ignore: cast_nullable_to_non_nullable
as Duration,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReviewPromptStatus,lastPromptedAt: freezed == lastPromptedAt ? _self.lastPromptedAt : lastPromptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
