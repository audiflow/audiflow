// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'now_playing_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NowPlayingInfo {

 String get episodeUrl; String get episodeTitle; String get podcastTitle; String? get artworkUrl; Duration? get totalDuration; Duration? get savedPosition; Episode? get episode;
/// Create a copy of NowPlayingInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowPlayingInfoCopyWith<NowPlayingInfo> get copyWith => _$NowPlayingInfoCopyWithImpl<NowPlayingInfo>(this as NowPlayingInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingInfo&&(identical(other.episodeUrl, episodeUrl) || other.episodeUrl == episodeUrl)&&(identical(other.episodeTitle, episodeTitle) || other.episodeTitle == episodeTitle)&&(identical(other.podcastTitle, podcastTitle) || other.podcastTitle == podcastTitle)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration)&&(identical(other.savedPosition, savedPosition) || other.savedPosition == savedPosition)&&(identical(other.episode, episode) || other.episode == episode));
}


@override
int get hashCode => Object.hash(runtimeType,episodeUrl,episodeTitle,podcastTitle,artworkUrl,totalDuration,savedPosition,episode);

@override
String toString() {
  return 'NowPlayingInfo(episodeUrl: $episodeUrl, episodeTitle: $episodeTitle, podcastTitle: $podcastTitle, artworkUrl: $artworkUrl, totalDuration: $totalDuration, savedPosition: $savedPosition, episode: $episode)';
}


}

/// @nodoc
abstract mixin class $NowPlayingInfoCopyWith<$Res>  {
  factory $NowPlayingInfoCopyWith(NowPlayingInfo value, $Res Function(NowPlayingInfo) _then) = _$NowPlayingInfoCopyWithImpl;
@useResult
$Res call({
 String episodeUrl, String episodeTitle, String podcastTitle, String? artworkUrl, Duration? totalDuration, Duration? savedPosition, Episode? episode
});




}
/// @nodoc
class _$NowPlayingInfoCopyWithImpl<$Res>
    implements $NowPlayingInfoCopyWith<$Res> {
  _$NowPlayingInfoCopyWithImpl(this._self, this._then);

  final NowPlayingInfo _self;
  final $Res Function(NowPlayingInfo) _then;

/// Create a copy of NowPlayingInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? episodeUrl = null,Object? episodeTitle = null,Object? podcastTitle = null,Object? artworkUrl = freezed,Object? totalDuration = freezed,Object? savedPosition = freezed,Object? episode = freezed,}) {
  return _then(_self.copyWith(
episodeUrl: null == episodeUrl ? _self.episodeUrl : episodeUrl // ignore: cast_nullable_to_non_nullable
as String,episodeTitle: null == episodeTitle ? _self.episodeTitle : episodeTitle // ignore: cast_nullable_to_non_nullable
as String,podcastTitle: null == podcastTitle ? _self.podcastTitle : podcastTitle // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,totalDuration: freezed == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as Duration?,savedPosition: freezed == savedPosition ? _self.savedPosition : savedPosition // ignore: cast_nullable_to_non_nullable
as Duration?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode?,
  ));
}

}


/// Adds pattern-matching-related methods to [NowPlayingInfo].
extension NowPlayingInfoPatterns on NowPlayingInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NowPlayingInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NowPlayingInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NowPlayingInfo value)  $default,){
final _that = this;
switch (_that) {
case _NowPlayingInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NowPlayingInfo value)?  $default,){
final _that = this;
switch (_that) {
case _NowPlayingInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String episodeUrl,  String episodeTitle,  String podcastTitle,  String? artworkUrl,  Duration? totalDuration,  Duration? savedPosition,  Episode? episode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NowPlayingInfo() when $default != null:
return $default(_that.episodeUrl,_that.episodeTitle,_that.podcastTitle,_that.artworkUrl,_that.totalDuration,_that.savedPosition,_that.episode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String episodeUrl,  String episodeTitle,  String podcastTitle,  String? artworkUrl,  Duration? totalDuration,  Duration? savedPosition,  Episode? episode)  $default,) {final _that = this;
switch (_that) {
case _NowPlayingInfo():
return $default(_that.episodeUrl,_that.episodeTitle,_that.podcastTitle,_that.artworkUrl,_that.totalDuration,_that.savedPosition,_that.episode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String episodeUrl,  String episodeTitle,  String podcastTitle,  String? artworkUrl,  Duration? totalDuration,  Duration? savedPosition,  Episode? episode)?  $default,) {final _that = this;
switch (_that) {
case _NowPlayingInfo() when $default != null:
return $default(_that.episodeUrl,_that.episodeTitle,_that.podcastTitle,_that.artworkUrl,_that.totalDuration,_that.savedPosition,_that.episode);case _:
  return null;

}
}

}

/// @nodoc


class _NowPlayingInfo implements NowPlayingInfo {
  const _NowPlayingInfo({required this.episodeUrl, required this.episodeTitle, required this.podcastTitle, this.artworkUrl, this.totalDuration, this.savedPosition, this.episode});


@override final  String episodeUrl;
@override final  String episodeTitle;
@override final  String podcastTitle;
@override final  String? artworkUrl;
@override final  Duration? totalDuration;
@override final  Duration? savedPosition;
@override final  Episode? episode;

/// Create a copy of NowPlayingInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NowPlayingInfoCopyWith<_NowPlayingInfo> get copyWith => __$NowPlayingInfoCopyWithImpl<_NowPlayingInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NowPlayingInfo&&(identical(other.episodeUrl, episodeUrl) || other.episodeUrl == episodeUrl)&&(identical(other.episodeTitle, episodeTitle) || other.episodeTitle == episodeTitle)&&(identical(other.podcastTitle, podcastTitle) || other.podcastTitle == podcastTitle)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.totalDuration, totalDuration) || other.totalDuration == totalDuration)&&(identical(other.savedPosition, savedPosition) || other.savedPosition == savedPosition)&&(identical(other.episode, episode) || other.episode == episode));
}


@override
int get hashCode => Object.hash(runtimeType,episodeUrl,episodeTitle,podcastTitle,artworkUrl,totalDuration,savedPosition,episode);

@override
String toString() {
  return 'NowPlayingInfo(episodeUrl: $episodeUrl, episodeTitle: $episodeTitle, podcastTitle: $podcastTitle, artworkUrl: $artworkUrl, totalDuration: $totalDuration, savedPosition: $savedPosition, episode: $episode)';
}


}

/// @nodoc
abstract mixin class _$NowPlayingInfoCopyWith<$Res> implements $NowPlayingInfoCopyWith<$Res> {
  factory _$NowPlayingInfoCopyWith(_NowPlayingInfo value, $Res Function(_NowPlayingInfo) _then) = __$NowPlayingInfoCopyWithImpl;
@override @useResult
$Res call({
 String episodeUrl, String episodeTitle, String podcastTitle, String? artworkUrl, Duration? totalDuration, Duration? savedPosition, Episode? episode
});




}
/// @nodoc
class __$NowPlayingInfoCopyWithImpl<$Res>
    implements _$NowPlayingInfoCopyWith<$Res> {
  __$NowPlayingInfoCopyWithImpl(this._self, this._then);

  final _NowPlayingInfo _self;
  final $Res Function(_NowPlayingInfo) _then;

/// Create a copy of NowPlayingInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? episodeUrl = null,Object? episodeTitle = null,Object? podcastTitle = null,Object? artworkUrl = freezed,Object? totalDuration = freezed,Object? savedPosition = freezed,Object? episode = freezed,}) {
  return _then(_NowPlayingInfo(
episodeUrl: null == episodeUrl ? _self.episodeUrl : episodeUrl // ignore: cast_nullable_to_non_nullable
as String,episodeTitle: null == episodeTitle ? _self.episodeTitle : episodeTitle // ignore: cast_nullable_to_non_nullable
as String,podcastTitle: null == podcastTitle ? _self.podcastTitle : podcastTitle // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,totalDuration: freezed == totalDuration ? _self.totalDuration : totalDuration // ignore: cast_nullable_to_non_nullable
as Duration?,savedPosition: freezed == savedPosition ? _self.savedPosition : savedPosition // ignore: cast_nullable_to_non_nullable
as Duration?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode?,
  ));
}


}

// dart format on
