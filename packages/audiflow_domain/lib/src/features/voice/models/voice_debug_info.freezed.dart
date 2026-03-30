// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_debug_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoiceDebugInfo {

 VoiceParserSource get parserSource; VoiceCommand? get lastCommand;
/// Create a copy of VoiceDebugInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceDebugInfoCopyWith<VoiceDebugInfo> get copyWith => _$VoiceDebugInfoCopyWithImpl<VoiceDebugInfo>(this as VoiceDebugInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceDebugInfo&&(identical(other.parserSource, parserSource) || other.parserSource == parserSource)&&(identical(other.lastCommand, lastCommand) || other.lastCommand == lastCommand));
}


@override
int get hashCode => Object.hash(runtimeType,parserSource,lastCommand);

@override
String toString() {
  return 'VoiceDebugInfo(parserSource: $parserSource, lastCommand: $lastCommand)';
}


}

/// @nodoc
abstract mixin class $VoiceDebugInfoCopyWith<$Res>  {
  factory $VoiceDebugInfoCopyWith(VoiceDebugInfo value, $Res Function(VoiceDebugInfo) _then) = _$VoiceDebugInfoCopyWithImpl;
@useResult
$Res call({
 VoiceParserSource parserSource, VoiceCommand? lastCommand
});




}
/// @nodoc
class _$VoiceDebugInfoCopyWithImpl<$Res>
    implements $VoiceDebugInfoCopyWith<$Res> {
  _$VoiceDebugInfoCopyWithImpl(this._self, this._then);

  final VoiceDebugInfo _self;
  final $Res Function(VoiceDebugInfo) _then;

/// Create a copy of VoiceDebugInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? parserSource = null,Object? lastCommand = freezed,}) {
  return _then(_self.copyWith(
parserSource: null == parserSource ? _self.parserSource : parserSource // ignore: cast_nullable_to_non_nullable
as VoiceParserSource,lastCommand: freezed == lastCommand ? _self.lastCommand : lastCommand // ignore: cast_nullable_to_non_nullable
as VoiceCommand?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceDebugInfo].
extension VoiceDebugInfoPatterns on VoiceDebugInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceDebugInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceDebugInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceDebugInfo value)  $default,){
final _that = this;
switch (_that) {
case _VoiceDebugInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceDebugInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceDebugInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoiceParserSource parserSource,  VoiceCommand? lastCommand)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceDebugInfo() when $default != null:
return $default(_that.parserSource,_that.lastCommand);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoiceParserSource parserSource,  VoiceCommand? lastCommand)  $default,) {final _that = this;
switch (_that) {
case _VoiceDebugInfo():
return $default(_that.parserSource,_that.lastCommand);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoiceParserSource parserSource,  VoiceCommand? lastCommand)?  $default,) {final _that = this;
switch (_that) {
case _VoiceDebugInfo() when $default != null:
return $default(_that.parserSource,_that.lastCommand);case _:
  return null;

}
}

}

/// @nodoc


class _VoiceDebugInfo implements VoiceDebugInfo {
  const _VoiceDebugInfo({this.parserSource = VoiceParserSource.none, this.lastCommand});


@override@JsonKey() final  VoiceParserSource parserSource;
@override final  VoiceCommand? lastCommand;

/// Create a copy of VoiceDebugInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceDebugInfoCopyWith<_VoiceDebugInfo> get copyWith => __$VoiceDebugInfoCopyWithImpl<_VoiceDebugInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceDebugInfo&&(identical(other.parserSource, parserSource) || other.parserSource == parserSource)&&(identical(other.lastCommand, lastCommand) || other.lastCommand == lastCommand));
}


@override
int get hashCode => Object.hash(runtimeType,parserSource,lastCommand);

@override
String toString() {
  return 'VoiceDebugInfo(parserSource: $parserSource, lastCommand: $lastCommand)';
}


}

/// @nodoc
abstract mixin class _$VoiceDebugInfoCopyWith<$Res> implements $VoiceDebugInfoCopyWith<$Res> {
  factory _$VoiceDebugInfoCopyWith(_VoiceDebugInfo value, $Res Function(_VoiceDebugInfo) _then) = __$VoiceDebugInfoCopyWithImpl;
@override @useResult
$Res call({
 VoiceParserSource parserSource, VoiceCommand? lastCommand
});




}
/// @nodoc
class __$VoiceDebugInfoCopyWithImpl<$Res>
    implements _$VoiceDebugInfoCopyWith<$Res> {
  __$VoiceDebugInfoCopyWithImpl(this._self, this._then);

  final _VoiceDebugInfo _self;
  final $Res Function(_VoiceDebugInfo) _then;

/// Create a copy of VoiceDebugInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? parserSource = null,Object? lastCommand = freezed,}) {
  return _then(_VoiceDebugInfo(
parserSource: null == parserSource ? _self.parserSource : parserSource // ignore: cast_nullable_to_non_nullable
as VoiceParserSource,lastCommand: freezed == lastCommand ? _self.lastCommand : lastCommand // ignore: cast_nullable_to_non_nullable
as VoiceCommand?,
  ));
}


}

// dart format on
