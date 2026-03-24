// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_intent_resolver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsResolutionCandidate {

/// The settings key this candidate targets.
 String get key;/// The current value of the setting before the proposed change.
 String get oldValue;/// The proposed new value for the setting.
 String get newValue;/// Confidence score in [0.0, 1.0] for this candidate.
 double get confidence;
/// Create a copy of SettingsResolutionCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsResolutionCandidateCopyWith<SettingsResolutionCandidate> get copyWith => _$SettingsResolutionCandidateCopyWithImpl<SettingsResolutionCandidate>(this as SettingsResolutionCandidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolutionCandidate&&(identical(other.key, key) || other.key == key)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,oldValue,newValue,confidence);

@override
String toString() {
  return 'SettingsResolutionCandidate(key: $key, oldValue: $oldValue, newValue: $newValue, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $SettingsResolutionCandidateCopyWith<$Res>  {
  factory $SettingsResolutionCandidateCopyWith(SettingsResolutionCandidate value, $Res Function(SettingsResolutionCandidate) _then) = _$SettingsResolutionCandidateCopyWithImpl;
@useResult
$Res call({
 String key, String oldValue, String newValue, double confidence
});




}
/// @nodoc
class _$SettingsResolutionCandidateCopyWithImpl<$Res>
    implements $SettingsResolutionCandidateCopyWith<$Res> {
  _$SettingsResolutionCandidateCopyWithImpl(this._self, this._then);

  final SettingsResolutionCandidate _self;
  final $Res Function(SettingsResolutionCandidate) _then;

/// Create a copy of SettingsResolutionCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? oldValue = null,Object? newValue = null,Object? confidence = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,oldValue: null == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SettingsResolutionCandidate].
extension SettingsResolutionCandidatePatterns on SettingsResolutionCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsResolutionCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsResolutionCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsResolutionCandidate value)  $default,){
final _that = this;
switch (_that) {
case _SettingsResolutionCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsResolutionCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsResolutionCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String oldValue,  String newValue,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsResolutionCandidate() when $default != null:
return $default(_that.key,_that.oldValue,_that.newValue,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String oldValue,  String newValue,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _SettingsResolutionCandidate():
return $default(_that.key,_that.oldValue,_that.newValue,_that.confidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String oldValue,  String newValue,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _SettingsResolutionCandidate() when $default != null:
return $default(_that.key,_that.oldValue,_that.newValue,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsResolutionCandidate implements SettingsResolutionCandidate {
  const _SettingsResolutionCandidate({required this.key, required this.oldValue, required this.newValue, required this.confidence});
  

/// The settings key this candidate targets.
@override final  String key;
/// The current value of the setting before the proposed change.
@override final  String oldValue;
/// The proposed new value for the setting.
@override final  String newValue;
/// Confidence score in [0.0, 1.0] for this candidate.
@override final  double confidence;

/// Create a copy of SettingsResolutionCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsResolutionCandidateCopyWith<_SettingsResolutionCandidate> get copyWith => __$SettingsResolutionCandidateCopyWithImpl<_SettingsResolutionCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsResolutionCandidate&&(identical(other.key, key) || other.key == key)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,oldValue,newValue,confidence);

@override
String toString() {
  return 'SettingsResolutionCandidate(key: $key, oldValue: $oldValue, newValue: $newValue, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$SettingsResolutionCandidateCopyWith<$Res> implements $SettingsResolutionCandidateCopyWith<$Res> {
  factory _$SettingsResolutionCandidateCopyWith(_SettingsResolutionCandidate value, $Res Function(_SettingsResolutionCandidate) _then) = __$SettingsResolutionCandidateCopyWithImpl;
@override @useResult
$Res call({
 String key, String oldValue, String newValue, double confidence
});




}
/// @nodoc
class __$SettingsResolutionCandidateCopyWithImpl<$Res>
    implements _$SettingsResolutionCandidateCopyWith<$Res> {
  __$SettingsResolutionCandidateCopyWithImpl(this._self, this._then);

  final _SettingsResolutionCandidate _self;
  final $Res Function(_SettingsResolutionCandidate) _then;

/// Create a copy of SettingsResolutionCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? oldValue = null,Object? newValue = null,Object? confidence = null,}) {
  return _then(_SettingsResolutionCandidate(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,oldValue: null == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$SettingsResolution {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolution);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsResolution()';
}


}

/// @nodoc
class $SettingsResolutionCopyWith<$Res>  {
$SettingsResolutionCopyWith(SettingsResolution _, $Res Function(SettingsResolution) __);
}


/// Adds pattern-matching-related methods to [SettingsResolution].
extension SettingsResolutionPatterns on SettingsResolution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsResolutionAutoApply value)?  autoApply,TResult Function( SettingsResolutionConfirm value)?  confirm,TResult Function( SettingsResolutionDisambiguate value)?  disambiguate,TResult Function( SettingsResolutionNotFound value)?  notFound,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsResolutionAutoApply() when autoApply != null:
return autoApply(_that);case SettingsResolutionConfirm() when confirm != null:
return confirm(_that);case SettingsResolutionDisambiguate() when disambiguate != null:
return disambiguate(_that);case SettingsResolutionNotFound() when notFound != null:
return notFound(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsResolutionAutoApply value)  autoApply,required TResult Function( SettingsResolutionConfirm value)  confirm,required TResult Function( SettingsResolutionDisambiguate value)  disambiguate,required TResult Function( SettingsResolutionNotFound value)  notFound,}){
final _that = this;
switch (_that) {
case SettingsResolutionAutoApply():
return autoApply(_that);case SettingsResolutionConfirm():
return confirm(_that);case SettingsResolutionDisambiguate():
return disambiguate(_that);case SettingsResolutionNotFound():
return notFound(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsResolutionAutoApply value)?  autoApply,TResult? Function( SettingsResolutionConfirm value)?  confirm,TResult? Function( SettingsResolutionDisambiguate value)?  disambiguate,TResult? Function( SettingsResolutionNotFound value)?  notFound,}){
final _that = this;
switch (_that) {
case SettingsResolutionAutoApply() when autoApply != null:
return autoApply(_that);case SettingsResolutionConfirm() when confirm != null:
return confirm(_that);case SettingsResolutionDisambiguate() when disambiguate != null:
return disambiguate(_that);case SettingsResolutionNotFound() when notFound != null:
return notFound(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String key,  String oldValue,  String newValue)?  autoApply,TResult Function( String key,  String oldValue,  String newValue,  double confidence)?  confirm,TResult Function( List<SettingsResolutionCandidate> candidates)?  disambiguate,TResult Function()?  notFound,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsResolutionAutoApply() when autoApply != null:
return autoApply(_that.key,_that.oldValue,_that.newValue);case SettingsResolutionConfirm() when confirm != null:
return confirm(_that.key,_that.oldValue,_that.newValue,_that.confidence);case SettingsResolutionDisambiguate() when disambiguate != null:
return disambiguate(_that.candidates);case SettingsResolutionNotFound() when notFound != null:
return notFound();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String key,  String oldValue,  String newValue)  autoApply,required TResult Function( String key,  String oldValue,  String newValue,  double confidence)  confirm,required TResult Function( List<SettingsResolutionCandidate> candidates)  disambiguate,required TResult Function()  notFound,}) {final _that = this;
switch (_that) {
case SettingsResolutionAutoApply():
return autoApply(_that.key,_that.oldValue,_that.newValue);case SettingsResolutionConfirm():
return confirm(_that.key,_that.oldValue,_that.newValue,_that.confidence);case SettingsResolutionDisambiguate():
return disambiguate(_that.candidates);case SettingsResolutionNotFound():
return notFound();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String key,  String oldValue,  String newValue)?  autoApply,TResult? Function( String key,  String oldValue,  String newValue,  double confidence)?  confirm,TResult? Function( List<SettingsResolutionCandidate> candidates)?  disambiguate,TResult? Function()?  notFound,}) {final _that = this;
switch (_that) {
case SettingsResolutionAutoApply() when autoApply != null:
return autoApply(_that.key,_that.oldValue,_that.newValue);case SettingsResolutionConfirm() when confirm != null:
return confirm(_that.key,_that.oldValue,_that.newValue,_that.confidence);case SettingsResolutionDisambiguate() when disambiguate != null:
return disambiguate(_that.candidates);case SettingsResolutionNotFound() when notFound != null:
return notFound();case _:
  return null;

}
}

}

/// @nodoc


class SettingsResolutionAutoApply implements SettingsResolution {
  const SettingsResolutionAutoApply({required this.key, required this.oldValue, required this.newValue});
  

/// The settings key to modify.
 final  String key;
/// The current value before the change.
 final  String oldValue;
/// The proposed new value.
 final  String newValue;

/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsResolutionAutoApplyCopyWith<SettingsResolutionAutoApply> get copyWith => _$SettingsResolutionAutoApplyCopyWithImpl<SettingsResolutionAutoApply>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolutionAutoApply&&(identical(other.key, key) || other.key == key)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue));
}


@override
int get hashCode => Object.hash(runtimeType,key,oldValue,newValue);

@override
String toString() {
  return 'SettingsResolution.autoApply(key: $key, oldValue: $oldValue, newValue: $newValue)';
}


}

/// @nodoc
abstract mixin class $SettingsResolutionAutoApplyCopyWith<$Res> implements $SettingsResolutionCopyWith<$Res> {
  factory $SettingsResolutionAutoApplyCopyWith(SettingsResolutionAutoApply value, $Res Function(SettingsResolutionAutoApply) _then) = _$SettingsResolutionAutoApplyCopyWithImpl;
@useResult
$Res call({
 String key, String oldValue, String newValue
});




}
/// @nodoc
class _$SettingsResolutionAutoApplyCopyWithImpl<$Res>
    implements $SettingsResolutionAutoApplyCopyWith<$Res> {
  _$SettingsResolutionAutoApplyCopyWithImpl(this._self, this._then);

  final SettingsResolutionAutoApply _self;
  final $Res Function(SettingsResolutionAutoApply) _then;

/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? oldValue = null,Object? newValue = null,}) {
  return _then(SettingsResolutionAutoApply(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,oldValue: null == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsResolutionConfirm implements SettingsResolution {
  const SettingsResolutionConfirm({required this.key, required this.oldValue, required this.newValue, required this.confidence});
  

/// The settings key to modify.
 final  String key;
/// The current value before the change.
 final  String oldValue;
/// The proposed new value.
 final  String newValue;
/// Confidence score in [0.0, 1.0].
 final  double confidence;

/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsResolutionConfirmCopyWith<SettingsResolutionConfirm> get copyWith => _$SettingsResolutionConfirmCopyWithImpl<SettingsResolutionConfirm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolutionConfirm&&(identical(other.key, key) || other.key == key)&&(identical(other.oldValue, oldValue) || other.oldValue == oldValue)&&(identical(other.newValue, newValue) || other.newValue == newValue)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,key,oldValue,newValue,confidence);

@override
String toString() {
  return 'SettingsResolution.confirm(key: $key, oldValue: $oldValue, newValue: $newValue, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $SettingsResolutionConfirmCopyWith<$Res> implements $SettingsResolutionCopyWith<$Res> {
  factory $SettingsResolutionConfirmCopyWith(SettingsResolutionConfirm value, $Res Function(SettingsResolutionConfirm) _then) = _$SettingsResolutionConfirmCopyWithImpl;
@useResult
$Res call({
 String key, String oldValue, String newValue, double confidence
});




}
/// @nodoc
class _$SettingsResolutionConfirmCopyWithImpl<$Res>
    implements $SettingsResolutionConfirmCopyWith<$Res> {
  _$SettingsResolutionConfirmCopyWithImpl(this._self, this._then);

  final SettingsResolutionConfirm _self;
  final $Res Function(SettingsResolutionConfirm) _then;

/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? oldValue = null,Object? newValue = null,Object? confidence = null,}) {
  return _then(SettingsResolutionConfirm(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,oldValue: null == oldValue ? _self.oldValue : oldValue // ignore: cast_nullable_to_non_nullable
as String,newValue: null == newValue ? _self.newValue : newValue // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class SettingsResolutionDisambiguate implements SettingsResolution {
  const SettingsResolutionDisambiguate({required final  List<SettingsResolutionCandidate> candidates}): _candidates = candidates;
  

/// All plausible candidates ordered by descending confidence.
 final  List<SettingsResolutionCandidate> _candidates;
/// All plausible candidates ordered by descending confidence.
 List<SettingsResolutionCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsResolutionDisambiguateCopyWith<SettingsResolutionDisambiguate> get copyWith => _$SettingsResolutionDisambiguateCopyWithImpl<SettingsResolutionDisambiguate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolutionDisambiguate&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'SettingsResolution.disambiguate(candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $SettingsResolutionDisambiguateCopyWith<$Res> implements $SettingsResolutionCopyWith<$Res> {
  factory $SettingsResolutionDisambiguateCopyWith(SettingsResolutionDisambiguate value, $Res Function(SettingsResolutionDisambiguate) _then) = _$SettingsResolutionDisambiguateCopyWithImpl;
@useResult
$Res call({
 List<SettingsResolutionCandidate> candidates
});




}
/// @nodoc
class _$SettingsResolutionDisambiguateCopyWithImpl<$Res>
    implements $SettingsResolutionDisambiguateCopyWith<$Res> {
  _$SettingsResolutionDisambiguateCopyWithImpl(this._self, this._then);

  final SettingsResolutionDisambiguate _self;
  final $Res Function(SettingsResolutionDisambiguate) _then;

/// Create a copy of SettingsResolution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidates = null,}) {
  return _then(SettingsResolutionDisambiguate(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<SettingsResolutionCandidate>,
  ));
}


}

/// @nodoc


class SettingsResolutionNotFound implements SettingsResolution {
  const SettingsResolutionNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsResolutionNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsResolution.notFound()';
}


}




// dart format on
