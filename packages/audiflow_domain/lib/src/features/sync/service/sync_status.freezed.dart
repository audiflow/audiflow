// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncStatus {

 SyncPhase get phase;/// The `SyncRelayFailure.code` behind [SyncPhase.retrying] or
/// [SyncPhase.failed].
 String? get failure;
/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncStatusCopyWith<SyncStatus> get copyWith => _$SyncStatusCopyWithImpl<SyncStatus>(this as SyncStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncStatus&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,phase,failure);

@override
String toString() {
  return 'SyncStatus(phase: $phase, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SyncStatusCopyWith<$Res>  {
  factory $SyncStatusCopyWith(SyncStatus value, $Res Function(SyncStatus) _then) = _$SyncStatusCopyWithImpl;
@useResult
$Res call({
 SyncPhase phase, String? failure
});




}
/// @nodoc
class _$SyncStatusCopyWithImpl<$Res>
    implements $SyncStatusCopyWith<$Res> {
  _$SyncStatusCopyWithImpl(this._self, this._then);

  final SyncStatus _self;
  final $Res Function(SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SyncPhase,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncStatus].
extension SyncStatusPatterns on SyncStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncStatus value)  $default,){
final _that = this;
switch (_that) {
case _SyncStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncPhase phase,  String? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.phase,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncPhase phase,  String? failure)  $default,) {final _that = this;
switch (_that) {
case _SyncStatus():
return $default(_that.phase,_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncPhase phase,  String? failure)?  $default,) {final _that = this;
switch (_that) {
case _SyncStatus() when $default != null:
return $default(_that.phase,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _SyncStatus implements SyncStatus {
  const _SyncStatus(this.phase, {this.failure});
  

@override final  SyncPhase phase;
/// The `SyncRelayFailure.code` behind [SyncPhase.retrying] or
/// [SyncPhase.failed].
@override final  String? failure;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncStatusCopyWith<_SyncStatus> get copyWith => __$SyncStatusCopyWithImpl<_SyncStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncStatus&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,phase,failure);

@override
String toString() {
  return 'SyncStatus(phase: $phase, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$SyncStatusCopyWith<$Res> implements $SyncStatusCopyWith<$Res> {
  factory _$SyncStatusCopyWith(_SyncStatus value, $Res Function(_SyncStatus) _then) = __$SyncStatusCopyWithImpl;
@override @useResult
$Res call({
 SyncPhase phase, String? failure
});




}
/// @nodoc
class __$SyncStatusCopyWithImpl<$Res>
    implements _$SyncStatusCopyWith<$Res> {
  __$SyncStatusCopyWithImpl(this._self, this._then);

  final _SyncStatus _self;
  final $Res Function(_SyncStatus) _then;

/// Create a copy of SyncStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? failure = freezed,}) {
  return _then(_SyncStatus(
null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SyncPhase,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
