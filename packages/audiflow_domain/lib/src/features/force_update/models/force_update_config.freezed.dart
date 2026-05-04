// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'force_update_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ForceUpdateConfig {

 int get schemaVersion; String get minVersion; String get recommendedVersion; bool get maintenanceMode; String get messageKey; Map<String, String>? get messageOverride; String? get updateUrl;
/// Create a copy of ForceUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForceUpdateConfigCopyWith<ForceUpdateConfig> get copyWith => _$ForceUpdateConfigCopyWithImpl<ForceUpdateConfig>(this as ForceUpdateConfig, _$identity);

  /// Serializes this ForceUpdateConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForceUpdateConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.recommendedVersion, recommendedVersion) || other.recommendedVersion == recommendedVersion)&&(identical(other.maintenanceMode, maintenanceMode) || other.maintenanceMode == maintenanceMode)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&const DeepCollectionEquality().equals(other.messageOverride, messageOverride)&&(identical(other.updateUrl, updateUrl) || other.updateUrl == updateUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,minVersion,recommendedVersion,maintenanceMode,messageKey,const DeepCollectionEquality().hash(messageOverride),updateUrl);

@override
String toString() {
  return 'ForceUpdateConfig(schemaVersion: $schemaVersion, minVersion: $minVersion, recommendedVersion: $recommendedVersion, maintenanceMode: $maintenanceMode, messageKey: $messageKey, messageOverride: $messageOverride, updateUrl: $updateUrl)';
}


}

/// @nodoc
abstract mixin class $ForceUpdateConfigCopyWith<$Res>  {
  factory $ForceUpdateConfigCopyWith(ForceUpdateConfig value, $Res Function(ForceUpdateConfig) _then) = _$ForceUpdateConfigCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String minVersion, String recommendedVersion, bool maintenanceMode, String messageKey, Map<String, String>? messageOverride, String? updateUrl
});




}
/// @nodoc
class _$ForceUpdateConfigCopyWithImpl<$Res>
    implements $ForceUpdateConfigCopyWith<$Res> {
  _$ForceUpdateConfigCopyWithImpl(this._self, this._then);

  final ForceUpdateConfig _self;
  final $Res Function(ForceUpdateConfig) _then;

/// Create a copy of ForceUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? minVersion = null,Object? recommendedVersion = null,Object? maintenanceMode = null,Object? messageKey = null,Object? messageOverride = freezed,Object? updateUrl = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,recommendedVersion: null == recommendedVersion ? _self.recommendedVersion : recommendedVersion // ignore: cast_nullable_to_non_nullable
as String,maintenanceMode: null == maintenanceMode ? _self.maintenanceMode : maintenanceMode // ignore: cast_nullable_to_non_nullable
as bool,messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,messageOverride: freezed == messageOverride ? _self.messageOverride : messageOverride // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,updateUrl: freezed == updateUrl ? _self.updateUrl : updateUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForceUpdateConfig].
extension ForceUpdateConfigPatterns on ForceUpdateConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForceUpdateConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForceUpdateConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForceUpdateConfig value)  $default,){
final _that = this;
switch (_that) {
case _ForceUpdateConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForceUpdateConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ForceUpdateConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String minVersion,  String recommendedVersion,  bool maintenanceMode,  String messageKey,  Map<String, String>? messageOverride,  String? updateUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForceUpdateConfig() when $default != null:
return $default(_that.schemaVersion,_that.minVersion,_that.recommendedVersion,_that.maintenanceMode,_that.messageKey,_that.messageOverride,_that.updateUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String minVersion,  String recommendedVersion,  bool maintenanceMode,  String messageKey,  Map<String, String>? messageOverride,  String? updateUrl)  $default,) {final _that = this;
switch (_that) {
case _ForceUpdateConfig():
return $default(_that.schemaVersion,_that.minVersion,_that.recommendedVersion,_that.maintenanceMode,_that.messageKey,_that.messageOverride,_that.updateUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String minVersion,  String recommendedVersion,  bool maintenanceMode,  String messageKey,  Map<String, String>? messageOverride,  String? updateUrl)?  $default,) {final _that = this;
switch (_that) {
case _ForceUpdateConfig() when $default != null:
return $default(_that.schemaVersion,_that.minVersion,_that.recommendedVersion,_that.maintenanceMode,_that.messageKey,_that.messageOverride,_that.updateUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ForceUpdateConfig implements ForceUpdateConfig {
  const _ForceUpdateConfig({required this.schemaVersion, required this.minVersion, required this.recommendedVersion, required this.maintenanceMode, required this.messageKey, final  Map<String, String>? messageOverride, this.updateUrl}): _messageOverride = messageOverride;
  factory _ForceUpdateConfig.fromJson(Map<String, dynamic> json) => _$ForceUpdateConfigFromJson(json);

@override final  int schemaVersion;
@override final  String minVersion;
@override final  String recommendedVersion;
@override final  bool maintenanceMode;
@override final  String messageKey;
 final  Map<String, String>? _messageOverride;
@override Map<String, String>? get messageOverride {
  final value = _messageOverride;
  if (value == null) return null;
  if (_messageOverride is EqualUnmodifiableMapView) return _messageOverride;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? updateUrl;

/// Create a copy of ForceUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForceUpdateConfigCopyWith<_ForceUpdateConfig> get copyWith => __$ForceUpdateConfigCopyWithImpl<_ForceUpdateConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForceUpdateConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForceUpdateConfig&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.recommendedVersion, recommendedVersion) || other.recommendedVersion == recommendedVersion)&&(identical(other.maintenanceMode, maintenanceMode) || other.maintenanceMode == maintenanceMode)&&(identical(other.messageKey, messageKey) || other.messageKey == messageKey)&&const DeepCollectionEquality().equals(other._messageOverride, _messageOverride)&&(identical(other.updateUrl, updateUrl) || other.updateUrl == updateUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,minVersion,recommendedVersion,maintenanceMode,messageKey,const DeepCollectionEquality().hash(_messageOverride),updateUrl);

@override
String toString() {
  return 'ForceUpdateConfig(schemaVersion: $schemaVersion, minVersion: $minVersion, recommendedVersion: $recommendedVersion, maintenanceMode: $maintenanceMode, messageKey: $messageKey, messageOverride: $messageOverride, updateUrl: $updateUrl)';
}


}

/// @nodoc
abstract mixin class _$ForceUpdateConfigCopyWith<$Res> implements $ForceUpdateConfigCopyWith<$Res> {
  factory _$ForceUpdateConfigCopyWith(_ForceUpdateConfig value, $Res Function(_ForceUpdateConfig) _then) = __$ForceUpdateConfigCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String minVersion, String recommendedVersion, bool maintenanceMode, String messageKey, Map<String, String>? messageOverride, String? updateUrl
});




}
/// @nodoc
class __$ForceUpdateConfigCopyWithImpl<$Res>
    implements _$ForceUpdateConfigCopyWith<$Res> {
  __$ForceUpdateConfigCopyWithImpl(this._self, this._then);

  final _ForceUpdateConfig _self;
  final $Res Function(_ForceUpdateConfig) _then;

/// Create a copy of ForceUpdateConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? minVersion = null,Object? recommendedVersion = null,Object? maintenanceMode = null,Object? messageKey = null,Object? messageOverride = freezed,Object? updateUrl = freezed,}) {
  return _then(_ForceUpdateConfig(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,recommendedVersion: null == recommendedVersion ? _self.recommendedVersion : recommendedVersion // ignore: cast_nullable_to_non_nullable
as String,maintenanceMode: null == maintenanceMode ? _self.maintenanceMode : maintenanceMode // ignore: cast_nullable_to_non_nullable
as bool,messageKey: null == messageKey ? _self.messageKey : messageKey // ignore: cast_nullable_to_non_nullable
as String,messageOverride: freezed == messageOverride ? _self._messageOverride : messageOverride // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,updateUrl: freezed == updateUrl ? _self.updateUrl : updateUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
