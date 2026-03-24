// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingConstraints {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingConstraints);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingConstraints()';
}


}

/// @nodoc
class $SettingConstraintsCopyWith<$Res>  {
$SettingConstraintsCopyWith(SettingConstraints _, $Res Function(SettingConstraints) __);
}


/// Adds pattern-matching-related methods to [SettingConstraints].
extension SettingConstraintsPatterns on SettingConstraints {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BooleanConstraints value)?  boolean,TResult Function( RangeConstraints value)?  range,TResult Function( OptionsConstraints value)?  options,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BooleanConstraints() when boolean != null:
return boolean(_that);case RangeConstraints() when range != null:
return range(_that);case OptionsConstraints() when options != null:
return options(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BooleanConstraints value)  boolean,required TResult Function( RangeConstraints value)  range,required TResult Function( OptionsConstraints value)  options,}){
final _that = this;
switch (_that) {
case BooleanConstraints():
return boolean(_that);case RangeConstraints():
return range(_that);case OptionsConstraints():
return options(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BooleanConstraints value)?  boolean,TResult? Function( RangeConstraints value)?  range,TResult? Function( OptionsConstraints value)?  options,}){
final _that = this;
switch (_that) {
case BooleanConstraints() when boolean != null:
return boolean(_that);case RangeConstraints() when range != null:
return range(_that);case OptionsConstraints() when options != null:
return options(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  boolean,TResult Function( double min,  double max,  double step)?  range,TResult Function( List<String> values)?  options,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BooleanConstraints() when boolean != null:
return boolean();case RangeConstraints() when range != null:
return range(_that.min,_that.max,_that.step);case OptionsConstraints() when options != null:
return options(_that.values);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  boolean,required TResult Function( double min,  double max,  double step)  range,required TResult Function( List<String> values)  options,}) {final _that = this;
switch (_that) {
case BooleanConstraints():
return boolean();case RangeConstraints():
return range(_that.min,_that.max,_that.step);case OptionsConstraints():
return options(_that.values);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  boolean,TResult? Function( double min,  double max,  double step)?  range,TResult? Function( List<String> values)?  options,}) {final _that = this;
switch (_that) {
case BooleanConstraints() when boolean != null:
return boolean();case RangeConstraints() when range != null:
return range(_that.min,_that.max,_that.step);case OptionsConstraints() when options != null:
return options(_that.values);case _:
  return null;

}
}

}

/// @nodoc


class BooleanConstraints implements SettingConstraints {
  const BooleanConstraints();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BooleanConstraints);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingConstraints.boolean()';
}


}




/// @nodoc


class RangeConstraints implements SettingConstraints {
  const RangeConstraints({required this.min, required this.max, required this.step});
  

/// Minimum allowed value.
 final  double min;
/// Maximum allowed value.
 final  double max;
/// Increment step between valid values.
 final  double step;

/// Create a copy of SettingConstraints
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RangeConstraintsCopyWith<RangeConstraints> get copyWith => _$RangeConstraintsCopyWithImpl<RangeConstraints>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RangeConstraints&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.step, step) || other.step == step));
}


@override
int get hashCode => Object.hash(runtimeType,min,max,step);

@override
String toString() {
  return 'SettingConstraints.range(min: $min, max: $max, step: $step)';
}


}

/// @nodoc
abstract mixin class $RangeConstraintsCopyWith<$Res> implements $SettingConstraintsCopyWith<$Res> {
  factory $RangeConstraintsCopyWith(RangeConstraints value, $Res Function(RangeConstraints) _then) = _$RangeConstraintsCopyWithImpl;
@useResult
$Res call({
 double min, double max, double step
});




}
/// @nodoc
class _$RangeConstraintsCopyWithImpl<$Res>
    implements $RangeConstraintsCopyWith<$Res> {
  _$RangeConstraintsCopyWithImpl(this._self, this._then);

  final RangeConstraints _self;
  final $Res Function(RangeConstraints) _then;

/// Create a copy of SettingConstraints
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,Object? step = null,}) {
  return _then(RangeConstraints(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as double,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as double,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class OptionsConstraints implements SettingConstraints {
  const OptionsConstraints({required final  List<String> values}): _values = values;
  

/// Allowed string values.
 final  List<String> _values;
/// Allowed string values.
 List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of SettingConstraints
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionsConstraintsCopyWith<OptionsConstraints> get copyWith => _$OptionsConstraintsCopyWithImpl<OptionsConstraints>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptionsConstraints&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'SettingConstraints.options(values: $values)';
}


}

/// @nodoc
abstract mixin class $OptionsConstraintsCopyWith<$Res> implements $SettingConstraintsCopyWith<$Res> {
  factory $OptionsConstraintsCopyWith(OptionsConstraints value, $Res Function(OptionsConstraints) _then) = _$OptionsConstraintsCopyWithImpl;
@useResult
$Res call({
 List<String> values
});




}
/// @nodoc
class _$OptionsConstraintsCopyWithImpl<$Res>
    implements $OptionsConstraintsCopyWith<$Res> {
  _$OptionsConstraintsCopyWithImpl(this._self, this._then);

  final OptionsConstraints _self;
  final $Res Function(OptionsConstraints) _then;

/// Create a copy of SettingConstraints
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(OptionsConstraints(
values: null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$SettingMetadata {

/// Stable programmatic identifier for the setting (matches repository key).
 String get key;/// Localization key used to look up the human-readable display name.
 String get displayNameKey;/// Data type of this setting.
 SettingType get type;/// Validation constraints that bound acceptable values.
 SettingConstraints get constraints;/// Alternative phrases users might say to refer to this setting.
///
/// Used by the NLU layer for fuzzy matching against voice input.
 List<String> get synonyms;
/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingMetadataCopyWith<SettingMetadata> get copyWith => _$SettingMetadataCopyWithImpl<SettingMetadata>(this as SettingMetadata, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingMetadata&&(identical(other.key, key) || other.key == key)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.type, type) || other.type == type)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&const DeepCollectionEquality().equals(other.synonyms, synonyms));
}


@override
int get hashCode => Object.hash(runtimeType,key,displayNameKey,type,constraints,const DeepCollectionEquality().hash(synonyms));

@override
String toString() {
  return 'SettingMetadata(key: $key, displayNameKey: $displayNameKey, type: $type, constraints: $constraints, synonyms: $synonyms)';
}


}

/// @nodoc
abstract mixin class $SettingMetadataCopyWith<$Res>  {
  factory $SettingMetadataCopyWith(SettingMetadata value, $Res Function(SettingMetadata) _then) = _$SettingMetadataCopyWithImpl;
@useResult
$Res call({
 String key, String displayNameKey, SettingType type, SettingConstraints constraints, List<String> synonyms
});


$SettingConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class _$SettingMetadataCopyWithImpl<$Res>
    implements $SettingMetadataCopyWith<$Res> {
  _$SettingMetadataCopyWithImpl(this._self, this._then);

  final SettingMetadata _self;
  final $Res Function(SettingMetadata) _then;

/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? displayNameKey = null,Object? type = null,Object? constraints = null,Object? synonyms = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SettingType,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as SettingConstraints,synonyms: null == synonyms ? _self.synonyms : synonyms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SettingConstraintsCopyWith<$Res> get constraints {
  
  return $SettingConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingMetadata].
extension SettingMetadataPatterns on SettingMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingMetadata value)  $default,){
final _that = this;
switch (_that) {
case _SettingMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _SettingMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String displayNameKey,  SettingType type,  SettingConstraints constraints,  List<String> synonyms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingMetadata() when $default != null:
return $default(_that.key,_that.displayNameKey,_that.type,_that.constraints,_that.synonyms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String displayNameKey,  SettingType type,  SettingConstraints constraints,  List<String> synonyms)  $default,) {final _that = this;
switch (_that) {
case _SettingMetadata():
return $default(_that.key,_that.displayNameKey,_that.type,_that.constraints,_that.synonyms);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String displayNameKey,  SettingType type,  SettingConstraints constraints,  List<String> synonyms)?  $default,) {final _that = this;
switch (_that) {
case _SettingMetadata() when $default != null:
return $default(_that.key,_that.displayNameKey,_that.type,_that.constraints,_that.synonyms);case _:
  return null;

}
}

}

/// @nodoc


class _SettingMetadata implements SettingMetadata {
  const _SettingMetadata({required this.key, required this.displayNameKey, required this.type, required this.constraints, required final  List<String> synonyms}): _synonyms = synonyms;
  

/// Stable programmatic identifier for the setting (matches repository key).
@override final  String key;
/// Localization key used to look up the human-readable display name.
@override final  String displayNameKey;
/// Data type of this setting.
@override final  SettingType type;
/// Validation constraints that bound acceptable values.
@override final  SettingConstraints constraints;
/// Alternative phrases users might say to refer to this setting.
///
/// Used by the NLU layer for fuzzy matching against voice input.
 final  List<String> _synonyms;
/// Alternative phrases users might say to refer to this setting.
///
/// Used by the NLU layer for fuzzy matching against voice input.
@override List<String> get synonyms {
  if (_synonyms is EqualUnmodifiableListView) return _synonyms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_synonyms);
}


/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingMetadataCopyWith<_SettingMetadata> get copyWith => __$SettingMetadataCopyWithImpl<_SettingMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingMetadata&&(identical(other.key, key) || other.key == key)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.type, type) || other.type == type)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&const DeepCollectionEquality().equals(other._synonyms, _synonyms));
}


@override
int get hashCode => Object.hash(runtimeType,key,displayNameKey,type,constraints,const DeepCollectionEquality().hash(_synonyms));

@override
String toString() {
  return 'SettingMetadata(key: $key, displayNameKey: $displayNameKey, type: $type, constraints: $constraints, synonyms: $synonyms)';
}


}

/// @nodoc
abstract mixin class _$SettingMetadataCopyWith<$Res> implements $SettingMetadataCopyWith<$Res> {
  factory _$SettingMetadataCopyWith(_SettingMetadata value, $Res Function(_SettingMetadata) _then) = __$SettingMetadataCopyWithImpl;
@override @useResult
$Res call({
 String key, String displayNameKey, SettingType type, SettingConstraints constraints, List<String> synonyms
});


@override $SettingConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class __$SettingMetadataCopyWithImpl<$Res>
    implements _$SettingMetadataCopyWith<$Res> {
  __$SettingMetadataCopyWithImpl(this._self, this._then);

  final _SettingMetadata _self;
  final $Res Function(_SettingMetadata) _then;

/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? displayNameKey = null,Object? type = null,Object? constraints = null,Object? synonyms = null,}) {
  return _then(_SettingMetadata(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SettingType,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as SettingConstraints,synonyms: null == synonyms ? _self._synonyms : synonyms // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SettingMetadata
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SettingConstraintsCopyWith<$Res> get constraints {
  
  return $SettingConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}

// dart format on
