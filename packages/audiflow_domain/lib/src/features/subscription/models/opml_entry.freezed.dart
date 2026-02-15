// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'opml_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OpmlEntry {

 String get title; String get feedUrl; String? get htmlUrl;
/// Create a copy of OpmlEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OpmlEntryCopyWith<OpmlEntry> get copyWith => _$OpmlEntryCopyWithImpl<OpmlEntry>(this as OpmlEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OpmlEntry&&(identical(other.title, title) || other.title == title)&&(identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl));
}


@override
int get hashCode => Object.hash(runtimeType,title,feedUrl,htmlUrl);

@override
String toString() {
  return 'OpmlEntry(title: $title, feedUrl: $feedUrl, htmlUrl: $htmlUrl)';
}


}

/// @nodoc
abstract mixin class $OpmlEntryCopyWith<$Res>  {
  factory $OpmlEntryCopyWith(OpmlEntry value, $Res Function(OpmlEntry) _then) = _$OpmlEntryCopyWithImpl;
@useResult
$Res call({
 String title, String feedUrl, String? htmlUrl
});




}
/// @nodoc
class _$OpmlEntryCopyWithImpl<$Res>
    implements $OpmlEntryCopyWith<$Res> {
  _$OpmlEntryCopyWithImpl(this._self, this._then);

  final OpmlEntry _self;
  final $Res Function(OpmlEntry) _then;

/// Create a copy of OpmlEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? feedUrl = null,Object? htmlUrl = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,feedUrl: null == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OpmlEntry].
extension OpmlEntryPatterns on OpmlEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OpmlEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OpmlEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OpmlEntry value)  $default,){
final _that = this;
switch (_that) {
case _OpmlEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OpmlEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OpmlEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String feedUrl,  String? htmlUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OpmlEntry() when $default != null:
return $default(_that.title,_that.feedUrl,_that.htmlUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String feedUrl,  String? htmlUrl)  $default,) {final _that = this;
switch (_that) {
case _OpmlEntry():
return $default(_that.title,_that.feedUrl,_that.htmlUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String feedUrl,  String? htmlUrl)?  $default,) {final _that = this;
switch (_that) {
case _OpmlEntry() when $default != null:
return $default(_that.title,_that.feedUrl,_that.htmlUrl);case _:
  return null;

}
}

}

/// @nodoc


class _OpmlEntry implements OpmlEntry {
  const _OpmlEntry({required this.title, required this.feedUrl, this.htmlUrl});
  

@override final  String title;
@override final  String feedUrl;
@override final  String? htmlUrl;

/// Create a copy of OpmlEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OpmlEntryCopyWith<_OpmlEntry> get copyWith => __$OpmlEntryCopyWithImpl<_OpmlEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OpmlEntry&&(identical(other.title, title) || other.title == title)&&(identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl)&&(identical(other.htmlUrl, htmlUrl) || other.htmlUrl == htmlUrl));
}


@override
int get hashCode => Object.hash(runtimeType,title,feedUrl,htmlUrl);

@override
String toString() {
  return 'OpmlEntry(title: $title, feedUrl: $feedUrl, htmlUrl: $htmlUrl)';
}


}

/// @nodoc
abstract mixin class _$OpmlEntryCopyWith<$Res> implements $OpmlEntryCopyWith<$Res> {
  factory _$OpmlEntryCopyWith(_OpmlEntry value, $Res Function(_OpmlEntry) _then) = __$OpmlEntryCopyWithImpl;
@override @useResult
$Res call({
 String title, String feedUrl, String? htmlUrl
});




}
/// @nodoc
class __$OpmlEntryCopyWithImpl<$Res>
    implements _$OpmlEntryCopyWith<$Res> {
  __$OpmlEntryCopyWithImpl(this._self, this._then);

  final _OpmlEntry _self;
  final $Res Function(_OpmlEntry) _then;

/// Create a copy of OpmlEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? feedUrl = null,Object? htmlUrl = freezed,}) {
  return _then(_OpmlEntry(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,feedUrl: null == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String,htmlUrl: freezed == htmlUrl ? _self.htmlUrl : htmlUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
