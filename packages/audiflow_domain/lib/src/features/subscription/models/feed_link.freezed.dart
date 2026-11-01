// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedLink {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedLink);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedLink()';
}


}

/// @nodoc
class $FeedLinkCopyWith<$Res>  {
$FeedLinkCopyWith(FeedLink _, $Res Function(FeedLink) __);
}


/// Adds pattern-matching-related methods to [FeedLink].
extension FeedLinkPatterns on FeedLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DirectFeedLink value)?  direct,TResult Function( ItunesFeedLink value)?  itunes,TResult Function( AppPageFeedLink value)?  appPage,TResult Function( UnsupportedFeedLink value)?  unsupported,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DirectFeedLink() when direct != null:
return direct(_that);case ItunesFeedLink() when itunes != null:
return itunes(_that);case AppPageFeedLink() when appPage != null:
return appPage(_that);case UnsupportedFeedLink() when unsupported != null:
return unsupported(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DirectFeedLink value)  direct,required TResult Function( ItunesFeedLink value)  itunes,required TResult Function( AppPageFeedLink value)  appPage,required TResult Function( UnsupportedFeedLink value)  unsupported,}){
final _that = this;
switch (_that) {
case DirectFeedLink():
return direct(_that);case ItunesFeedLink():
return itunes(_that);case AppPageFeedLink():
return appPage(_that);case UnsupportedFeedLink():
return unsupported(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DirectFeedLink value)?  direct,TResult? Function( ItunesFeedLink value)?  itunes,TResult? Function( AppPageFeedLink value)?  appPage,TResult? Function( UnsupportedFeedLink value)?  unsupported,}){
final _that = this;
switch (_that) {
case DirectFeedLink() when direct != null:
return direct(_that);case ItunesFeedLink() when itunes != null:
return itunes(_that);case AppPageFeedLink() when appPage != null:
return appPage(_that);case UnsupportedFeedLink() when unsupported != null:
return unsupported(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String url)?  direct,TResult Function( String itunesId)?  itunes,TResult Function( String url,  String platformName)?  appPage,TResult Function( String platformName)?  unsupported,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DirectFeedLink() when direct != null:
return direct(_that.url);case ItunesFeedLink() when itunes != null:
return itunes(_that.itunesId);case AppPageFeedLink() when appPage != null:
return appPage(_that.url,_that.platformName);case UnsupportedFeedLink() when unsupported != null:
return unsupported(_that.platformName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String url)  direct,required TResult Function( String itunesId)  itunes,required TResult Function( String url,  String platformName)  appPage,required TResult Function( String platformName)  unsupported,}) {final _that = this;
switch (_that) {
case DirectFeedLink():
return direct(_that.url);case ItunesFeedLink():
return itunes(_that.itunesId);case AppPageFeedLink():
return appPage(_that.url,_that.platformName);case UnsupportedFeedLink():
return unsupported(_that.platformName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String url)?  direct,TResult? Function( String itunesId)?  itunes,TResult? Function( String url,  String platformName)?  appPage,TResult? Function( String platformName)?  unsupported,}) {final _that = this;
switch (_that) {
case DirectFeedLink() when direct != null:
return direct(_that.url);case ItunesFeedLink() when itunes != null:
return itunes(_that.itunesId);case AppPageFeedLink() when appPage != null:
return appPage(_that.url,_that.platformName);case UnsupportedFeedLink() when unsupported != null:
return unsupported(_that.platformName);case _:
  return null;

}
}

}

/// @nodoc


class DirectFeedLink implements FeedLink {
  const DirectFeedLink({required this.url});
  

 final  String url;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectFeedLinkCopyWith<DirectFeedLink> get copyWith => _$DirectFeedLinkCopyWithImpl<DirectFeedLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectFeedLink&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,url);

@override
String toString() {
  return 'FeedLink.direct(url: $url)';
}


}

/// @nodoc
abstract mixin class $DirectFeedLinkCopyWith<$Res> implements $FeedLinkCopyWith<$Res> {
  factory $DirectFeedLinkCopyWith(DirectFeedLink value, $Res Function(DirectFeedLink) _then) = _$DirectFeedLinkCopyWithImpl;
@useResult
$Res call({
 String url
});




}
/// @nodoc
class _$DirectFeedLinkCopyWithImpl<$Res>
    implements $DirectFeedLinkCopyWith<$Res> {
  _$DirectFeedLinkCopyWithImpl(this._self, this._then);

  final DirectFeedLink _self;
  final $Res Function(DirectFeedLink) _then;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,}) {
  return _then(DirectFeedLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ItunesFeedLink implements FeedLink {
  const ItunesFeedLink({required this.itunesId});
  

 final  String itunesId;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItunesFeedLinkCopyWith<ItunesFeedLink> get copyWith => _$ItunesFeedLinkCopyWithImpl<ItunesFeedLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItunesFeedLink&&(identical(other.itunesId, itunesId) || other.itunesId == itunesId));
}


@override
int get hashCode => Object.hash(runtimeType,itunesId);

@override
String toString() {
  return 'FeedLink.itunes(itunesId: $itunesId)';
}


}

/// @nodoc
abstract mixin class $ItunesFeedLinkCopyWith<$Res> implements $FeedLinkCopyWith<$Res> {
  factory $ItunesFeedLinkCopyWith(ItunesFeedLink value, $Res Function(ItunesFeedLink) _then) = _$ItunesFeedLinkCopyWithImpl;
@useResult
$Res call({
 String itunesId
});




}
/// @nodoc
class _$ItunesFeedLinkCopyWithImpl<$Res>
    implements $ItunesFeedLinkCopyWith<$Res> {
  _$ItunesFeedLinkCopyWithImpl(this._self, this._then);

  final ItunesFeedLink _self;
  final $Res Function(ItunesFeedLink) _then;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? itunesId = null,}) {
  return _then(ItunesFeedLink(
itunesId: null == itunesId ? _self.itunesId : itunesId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AppPageFeedLink implements FeedLink {
  const AppPageFeedLink({required this.url, required this.platformName});
  

 final  String url;
 final  String platformName;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppPageFeedLinkCopyWith<AppPageFeedLink> get copyWith => _$AppPageFeedLinkCopyWithImpl<AppPageFeedLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppPageFeedLink&&(identical(other.url, url) || other.url == url)&&(identical(other.platformName, platformName) || other.platformName == platformName));
}


@override
int get hashCode => Object.hash(runtimeType,url,platformName);

@override
String toString() {
  return 'FeedLink.appPage(url: $url, platformName: $platformName)';
}


}

/// @nodoc
abstract mixin class $AppPageFeedLinkCopyWith<$Res> implements $FeedLinkCopyWith<$Res> {
  factory $AppPageFeedLinkCopyWith(AppPageFeedLink value, $Res Function(AppPageFeedLink) _then) = _$AppPageFeedLinkCopyWithImpl;
@useResult
$Res call({
 String url, String platformName
});




}
/// @nodoc
class _$AppPageFeedLinkCopyWithImpl<$Res>
    implements $AppPageFeedLinkCopyWith<$Res> {
  _$AppPageFeedLinkCopyWithImpl(this._self, this._then);

  final AppPageFeedLink _self;
  final $Res Function(AppPageFeedLink) _then;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,Object? platformName = null,}) {
  return _then(AppPageFeedLink(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,platformName: null == platformName ? _self.platformName : platformName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnsupportedFeedLink implements FeedLink {
  const UnsupportedFeedLink({required this.platformName});
  

 final  String platformName;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnsupportedFeedLinkCopyWith<UnsupportedFeedLink> get copyWith => _$UnsupportedFeedLinkCopyWithImpl<UnsupportedFeedLink>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnsupportedFeedLink&&(identical(other.platformName, platformName) || other.platformName == platformName));
}


@override
int get hashCode => Object.hash(runtimeType,platformName);

@override
String toString() {
  return 'FeedLink.unsupported(platformName: $platformName)';
}


}

/// @nodoc
abstract mixin class $UnsupportedFeedLinkCopyWith<$Res> implements $FeedLinkCopyWith<$Res> {
  factory $UnsupportedFeedLinkCopyWith(UnsupportedFeedLink value, $Res Function(UnsupportedFeedLink) _then) = _$UnsupportedFeedLinkCopyWithImpl;
@useResult
$Res call({
 String platformName
});




}
/// @nodoc
class _$UnsupportedFeedLinkCopyWithImpl<$Res>
    implements $UnsupportedFeedLinkCopyWith<$Res> {
  _$UnsupportedFeedLinkCopyWithImpl(this._self, this._then);

  final UnsupportedFeedLink _self;
  final $Res Function(UnsupportedFeedLink) _then;

/// Create a copy of FeedLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? platformName = null,}) {
  return _then(UnsupportedFeedLink(
platformName: null == platformName ? _self.platformName : platformName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
