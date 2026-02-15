// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opml_import_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpmlImportResult {

 List<OpmlEntry> get succeeded; List<OpmlEntry> get alreadySubscribed; List<OpmlEntry> get failed;
/// Create a copy of OpmlImportResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpmlImportResultCopyWith<OpmlImportResult> get copyWith => _$OpmlImportResultCopyWithImpl<OpmlImportResult>(this as OpmlImportResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpmlImportResult&&const DeepCollectionEquality().equals(other.succeeded, succeeded)&&const DeepCollectionEquality().equals(other.alreadySubscribed, alreadySubscribed)&&const DeepCollectionEquality().equals(other.failed, failed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(succeeded),const DeepCollectionEquality().hash(alreadySubscribed),const DeepCollectionEquality().hash(failed));

@override
String toString() {
  return 'OpmlImportResult(succeeded: $succeeded, alreadySubscribed: $alreadySubscribed, failed: $failed)';
}


}

/// @nodoc
abstract mixin class $OpmlImportResultCopyWith<$Res>  {
  factory $OpmlImportResultCopyWith(OpmlImportResult value, $Res Function(OpmlImportResult) _then) = _$OpmlImportResultCopyWithImpl;
@useResult
$Res call({
 List<OpmlEntry> succeeded, List<OpmlEntry> alreadySubscribed, List<OpmlEntry> failed
});




}
/// @nodoc
class _$OpmlImportResultCopyWithImpl<$Res>
    implements $OpmlImportResultCopyWith<$Res> {
  _$OpmlImportResultCopyWithImpl(this._self, this._then);

  final OpmlImportResult _self;
  final $Res Function(OpmlImportResult) _then;

/// Create a copy of OpmlImportResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? succeeded = null,Object? alreadySubscribed = null,Object? failed = null,}) {
  return _then(_self.copyWith(
succeeded: null == succeeded ? _self.succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,alreadySubscribed: null == alreadySubscribed ? _self.alreadySubscribed : alreadySubscribed // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [OpmlImportResult].
extension OpmlImportResultPatterns on OpmlImportResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpmlImportResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpmlImportResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpmlImportResult value)  $default,){
final _that = this;
switch (_that) {
case _OpmlImportResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpmlImportResult value)?  $default,){
final _that = this;
switch (_that) {
case _OpmlImportResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OpmlEntry> succeeded,  List<OpmlEntry> alreadySubscribed,  List<OpmlEntry> failed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpmlImportResult() when $default != null:
return $default(_that.succeeded,_that.alreadySubscribed,_that.failed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OpmlEntry> succeeded,  List<OpmlEntry> alreadySubscribed,  List<OpmlEntry> failed)  $default,) {final _that = this;
switch (_that) {
case _OpmlImportResult():
return $default(_that.succeeded,_that.alreadySubscribed,_that.failed);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OpmlEntry> succeeded,  List<OpmlEntry> alreadySubscribed,  List<OpmlEntry> failed)?  $default,) {final _that = this;
switch (_that) {
case _OpmlImportResult() when $default != null:
return $default(_that.succeeded,_that.alreadySubscribed,_that.failed);case _:
  return null;

}
}

}

/// @nodoc


class _OpmlImportResult implements OpmlImportResult {
  const _OpmlImportResult({required final  List<OpmlEntry> succeeded, required final  List<OpmlEntry> alreadySubscribed, required final  List<OpmlEntry> failed}): _succeeded = succeeded,_alreadySubscribed = alreadySubscribed,_failed = failed;
  

 final  List<OpmlEntry> _succeeded;
@override List<OpmlEntry> get succeeded {
  if (_succeeded is EqualUnmodifiableListView) return _succeeded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_succeeded);
}

 final  List<OpmlEntry> _alreadySubscribed;
@override List<OpmlEntry> get alreadySubscribed {
  if (_alreadySubscribed is EqualUnmodifiableListView) return _alreadySubscribed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alreadySubscribed);
}

 final  List<OpmlEntry> _failed;
@override List<OpmlEntry> get failed {
  if (_failed is EqualUnmodifiableListView) return _failed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failed);
}


/// Create a copy of OpmlImportResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpmlImportResultCopyWith<_OpmlImportResult> get copyWith => __$OpmlImportResultCopyWithImpl<_OpmlImportResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpmlImportResult&&const DeepCollectionEquality().equals(other._succeeded, _succeeded)&&const DeepCollectionEquality().equals(other._alreadySubscribed, _alreadySubscribed)&&const DeepCollectionEquality().equals(other._failed, _failed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_succeeded),const DeepCollectionEquality().hash(_alreadySubscribed),const DeepCollectionEquality().hash(_failed));

@override
String toString() {
  return 'OpmlImportResult(succeeded: $succeeded, alreadySubscribed: $alreadySubscribed, failed: $failed)';
}


}

/// @nodoc
abstract mixin class _$OpmlImportResultCopyWith<$Res> implements $OpmlImportResultCopyWith<$Res> {
  factory _$OpmlImportResultCopyWith(_OpmlImportResult value, $Res Function(_OpmlImportResult) _then) = __$OpmlImportResultCopyWithImpl;
@override @useResult
$Res call({
 List<OpmlEntry> succeeded, List<OpmlEntry> alreadySubscribed, List<OpmlEntry> failed
});




}
/// @nodoc
class __$OpmlImportResultCopyWithImpl<$Res>
    implements _$OpmlImportResultCopyWith<$Res> {
  __$OpmlImportResultCopyWithImpl(this._self, this._then);

  final _OpmlImportResult _self;
  final $Res Function(_OpmlImportResult) _then;

/// Create a copy of OpmlImportResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? succeeded = null,Object? alreadySubscribed = null,Object? failed = null,}) {
  return _then(_OpmlImportResult(
succeeded: null == succeeded ? _self._succeeded : succeeded // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,alreadySubscribed: null == alreadySubscribed ? _self._alreadySubscribed : alreadySubscribed // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,failed: null == failed ? _self._failed : failed // ignore: cast_nullable_to_non_nullable
as List<OpmlEntry>,
  ));
}


}

// dart format on
