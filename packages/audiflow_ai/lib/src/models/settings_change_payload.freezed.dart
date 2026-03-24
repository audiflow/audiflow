// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_change_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsCandidate {

/// The settings key this candidate targets.
 String get key;/// The resolved value for this candidate.
 String get value;/// Confidence score in [0.0, 1.0] for this candidate.
 double get confidence;
/// Create a copy of SettingsCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCandidateCopyWith<SettingsCandidate> get copyWith => _$SettingsCandidateCopyWithImpl<SettingsCandidate>(this as SettingsCandidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsCandidate&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,value,confidence);

@override
String toString() {
  return 'SettingsCandidate(key: $key, value: $value, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $SettingsCandidateCopyWith<$Res>  {
  factory $SettingsCandidateCopyWith(SettingsCandidate value, $Res Function(SettingsCandidate) _then) = _$SettingsCandidateCopyWithImpl;
@useResult
$Res call({
 String key, String value, double confidence
});




}
/// @nodoc
class _$SettingsCandidateCopyWithImpl<$Res>
    implements $SettingsCandidateCopyWith<$Res> {
  _$SettingsCandidateCopyWithImpl(this._self, this._then);

  final SettingsCandidate _self;
  final $Res Function(SettingsCandidate) _then;

/// Create a copy of SettingsCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? confidence = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsCandidate].
extension SettingsCandidatePatterns on SettingsCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsCandidate value)  $default,){
final _that = this;
switch (_that) {
case _SettingsCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsCandidate() when $default != null:
return $default(_that.key,_that.value,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _SettingsCandidate():
return $default(_that.key,_that.value,_that.confidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _SettingsCandidate() when $default != null:
return $default(_that.key,_that.value,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsCandidate implements SettingsCandidate {
  const _SettingsCandidate({required this.key, required this.value, required this.confidence});
  

/// The settings key this candidate targets.
@override final  String key;
/// The resolved value for this candidate.
@override final  String value;
/// Confidence score in [0.0, 1.0] for this candidate.
@override final  double confidence;

/// Create a copy of SettingsCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCandidateCopyWith<_SettingsCandidate> get copyWith => __$SettingsCandidateCopyWithImpl<_SettingsCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsCandidate&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,value,confidence);

@override
String toString() {
  return 'SettingsCandidate(key: $key, value: $value, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$SettingsCandidateCopyWith<$Res> implements $SettingsCandidateCopyWith<$Res> {
  factory _$SettingsCandidateCopyWith(_SettingsCandidate value, $Res Function(_SettingsCandidate) _then) = __$SettingsCandidateCopyWithImpl;
@override @useResult
$Res call({
 String key, String value, double confidence
});




}
/// @nodoc
class __$SettingsCandidateCopyWithImpl<$Res>
    implements _$SettingsCandidateCopyWith<$Res> {
  __$SettingsCandidateCopyWithImpl(this._self, this._then);

  final _SettingsCandidate _self;
  final $Res Function(_SettingsCandidate) _then;

/// Create a copy of SettingsCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? confidence = null,}) {
  return _then(_SettingsCandidate(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$SettingsChangePayload {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChangePayload);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsChangePayload()';
}


}

/// @nodoc
class $SettingsChangePayloadCopyWith<$Res>  {
$SettingsChangePayloadCopyWith(SettingsChangePayload _, $Res Function(SettingsChangePayload) __);
}


/// Adds pattern-matching-related methods to [SettingsChangePayload].
extension SettingsChangePayloadPatterns on SettingsChangePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsChangePayloadAbsolute value)?  absolute,TResult Function( SettingsChangePayloadRelative value)?  relative,TResult Function( SettingsChangePayloadAmbiguous value)?  ambiguous,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute() when absolute != null:
return absolute(_that);case SettingsChangePayloadRelative() when relative != null:
return relative(_that);case SettingsChangePayloadAmbiguous() when ambiguous != null:
return ambiguous(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsChangePayloadAbsolute value)  absolute,required TResult Function( SettingsChangePayloadRelative value)  relative,required TResult Function( SettingsChangePayloadAmbiguous value)  ambiguous,}){
final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute():
return absolute(_that);case SettingsChangePayloadRelative():
return relative(_that);case SettingsChangePayloadAmbiguous():
return ambiguous(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsChangePayloadAbsolute value)?  absolute,TResult? Function( SettingsChangePayloadRelative value)?  relative,TResult? Function( SettingsChangePayloadAmbiguous value)?  ambiguous,}){
final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute() when absolute != null:
return absolute(_that);case SettingsChangePayloadRelative() when relative != null:
return relative(_that);case SettingsChangePayloadAmbiguous() when ambiguous != null:
return ambiguous(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String key,  String value,  double confidence)?  absolute,TResult Function( String key,  ChangeDirection direction,  ChangeMagnitude magnitude,  double confidence)?  relative,TResult Function( List<SettingsCandidate> candidates)?  ambiguous,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute() when absolute != null:
return absolute(_that.key,_that.value,_that.confidence);case SettingsChangePayloadRelative() when relative != null:
return relative(_that.key,_that.direction,_that.magnitude,_that.confidence);case SettingsChangePayloadAmbiguous() when ambiguous != null:
return ambiguous(_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String key,  String value,  double confidence)  absolute,required TResult Function( String key,  ChangeDirection direction,  ChangeMagnitude magnitude,  double confidence)  relative,required TResult Function( List<SettingsCandidate> candidates)  ambiguous,}) {final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute():
return absolute(_that.key,_that.value,_that.confidence);case SettingsChangePayloadRelative():
return relative(_that.key,_that.direction,_that.magnitude,_that.confidence);case SettingsChangePayloadAmbiguous():
return ambiguous(_that.candidates);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String key,  String value,  double confidence)?  absolute,TResult? Function( String key,  ChangeDirection direction,  ChangeMagnitude magnitude,  double confidence)?  relative,TResult? Function( List<SettingsCandidate> candidates)?  ambiguous,}) {final _that = this;
switch (_that) {
case SettingsChangePayloadAbsolute() when absolute != null:
return absolute(_that.key,_that.value,_that.confidence);case SettingsChangePayloadRelative() when relative != null:
return relative(_that.key,_that.direction,_that.magnitude,_that.confidence);case SettingsChangePayloadAmbiguous() when ambiguous != null:
return ambiguous(_that.candidates);case _:
  return null;

}
}

}

/// @nodoc


class SettingsChangePayloadAbsolute implements SettingsChangePayload {
  const SettingsChangePayloadAbsolute({required this.key, required this.value, required this.confidence});
  

/// Settings key to change.
 final  String key;
/// The resolved absolute value.
 final  String value;
/// Confidence score in [0.0, 1.0].
 final  double confidence;

/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsChangePayloadAbsoluteCopyWith<SettingsChangePayloadAbsolute> get copyWith => _$SettingsChangePayloadAbsoluteCopyWithImpl<SettingsChangePayloadAbsolute>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChangePayloadAbsolute&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,value,confidence);

@override
String toString() {
  return 'SettingsChangePayload.absolute(key: $key, value: $value, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $SettingsChangePayloadAbsoluteCopyWith<$Res> implements $SettingsChangePayloadCopyWith<$Res> {
  factory $SettingsChangePayloadAbsoluteCopyWith(SettingsChangePayloadAbsolute value, $Res Function(SettingsChangePayloadAbsolute) _then) = _$SettingsChangePayloadAbsoluteCopyWithImpl;
@useResult
$Res call({
 String key, String value, double confidence
});




}
/// @nodoc
class _$SettingsChangePayloadAbsoluteCopyWithImpl<$Res>
    implements $SettingsChangePayloadAbsoluteCopyWith<$Res> {
  _$SettingsChangePayloadAbsoluteCopyWithImpl(this._self, this._then);

  final SettingsChangePayloadAbsolute _self;
  final $Res Function(SettingsChangePayloadAbsolute) _then;

/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? confidence = null,}) {
  return _then(SettingsChangePayloadAbsolute(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class SettingsChangePayloadRelative implements SettingsChangePayload {
  const SettingsChangePayloadRelative({required this.key, required this.direction, required this.magnitude, required this.confidence});
  

/// Settings key to change.
 final  String key;
/// Whether to increase or decrease the current value.
 final  ChangeDirection direction;
/// How much to adjust the current value.
 final  ChangeMagnitude magnitude;
/// Confidence score in [0.0, 1.0].
 final  double confidence;

/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsChangePayloadRelativeCopyWith<SettingsChangePayloadRelative> get copyWith => _$SettingsChangePayloadRelativeCopyWithImpl<SettingsChangePayloadRelative>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChangePayloadRelative&&(identical(other.key, key) || other.key == key)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.magnitude, magnitude) || other.magnitude == magnitude)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,direction,magnitude,confidence);

@override
String toString() {
  return 'SettingsChangePayload.relative(key: $key, direction: $direction, magnitude: $magnitude, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $SettingsChangePayloadRelativeCopyWith<$Res> implements $SettingsChangePayloadCopyWith<$Res> {
  factory $SettingsChangePayloadRelativeCopyWith(SettingsChangePayloadRelative value, $Res Function(SettingsChangePayloadRelative) _then) = _$SettingsChangePayloadRelativeCopyWithImpl;
@useResult
$Res call({
 String key, ChangeDirection direction, ChangeMagnitude magnitude, double confidence
});




}
/// @nodoc
class _$SettingsChangePayloadRelativeCopyWithImpl<$Res>
    implements $SettingsChangePayloadRelativeCopyWith<$Res> {
  _$SettingsChangePayloadRelativeCopyWithImpl(this._self, this._then);

  final SettingsChangePayloadRelative _self;
  final $Res Function(SettingsChangePayloadRelative) _then;

/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? direction = null,Object? magnitude = null,Object? confidence = null,}) {
  return _then(SettingsChangePayloadRelative(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ChangeDirection,magnitude: null == magnitude ? _self.magnitude : magnitude // ignore: cast_nullable_to_non_nullable
as ChangeMagnitude,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class SettingsChangePayloadAmbiguous implements SettingsChangePayload {
  const SettingsChangePayloadAmbiguous({required final  List<SettingsCandidate> candidates}): _candidates = candidates;
  

/// All plausible interpretations, ordered by descending confidence.
 final  List<SettingsCandidate> _candidates;
/// All plausible interpretations, ordered by descending confidence.
 List<SettingsCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsChangePayloadAmbiguousCopyWith<SettingsChangePayloadAmbiguous> get copyWith => _$SettingsChangePayloadAmbiguousCopyWithImpl<SettingsChangePayloadAmbiguous>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChangePayloadAmbiguous&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'SettingsChangePayload.ambiguous(candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $SettingsChangePayloadAmbiguousCopyWith<$Res> implements $SettingsChangePayloadCopyWith<$Res> {
  factory $SettingsChangePayloadAmbiguousCopyWith(SettingsChangePayloadAmbiguous value, $Res Function(SettingsChangePayloadAmbiguous) _then) = _$SettingsChangePayloadAmbiguousCopyWithImpl;
@useResult
$Res call({
 List<SettingsCandidate> candidates
});




}
/// @nodoc
class _$SettingsChangePayloadAmbiguousCopyWithImpl<$Res>
    implements $SettingsChangePayloadAmbiguousCopyWith<$Res> {
  _$SettingsChangePayloadAmbiguousCopyWithImpl(this._self, this._then);

  final SettingsChangePayloadAmbiguous _self;
  final $Res Function(SettingsChangePayloadAmbiguous) _then;

/// Create a copy of SettingsChangePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,}) {
  return _then(SettingsChangePayloadAmbiguous(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<SettingsCandidate>,
  ));
}


}

// dart format on
