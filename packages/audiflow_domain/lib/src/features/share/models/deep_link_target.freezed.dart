// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deep_link_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DeepLinkTarget {

 String get itunesId; String get feedUrl; String? get artworkUrl;
/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeepLinkTargetCopyWith<DeepLinkTarget> get copyWith => _$DeepLinkTargetCopyWithImpl<DeepLinkTarget>(this as DeepLinkTarget, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeepLinkTarget&&(identical(other.itunesId, itunesId) || other.itunesId == itunesId)&&(identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl));
}


@override
int get hashCode => Object.hash(runtimeType,itunesId,feedUrl,artworkUrl);

@override
String toString() {
  return 'DeepLinkTarget(itunesId: $itunesId, feedUrl: $feedUrl, artworkUrl: $artworkUrl)';
}


}

/// @nodoc
abstract mixin class $DeepLinkTargetCopyWith<$Res>  {
  factory $DeepLinkTargetCopyWith(DeepLinkTarget value, $Res Function(DeepLinkTarget) _then) = _$DeepLinkTargetCopyWithImpl;
@useResult
$Res call({
 String itunesId, String feedUrl, String? artworkUrl
});




}
/// @nodoc
class _$DeepLinkTargetCopyWithImpl<$Res>
    implements $DeepLinkTargetCopyWith<$Res> {
  _$DeepLinkTargetCopyWithImpl(this._self, this._then);

  final DeepLinkTarget _self;
  final $Res Function(DeepLinkTarget) _then;

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itunesId = null,Object? feedUrl = null,Object? artworkUrl = freezed,}) {
  return _then(_self.copyWith(
itunesId: null == itunesId ? _self.itunesId : itunesId // ignore: cast_nullable_to_non_nullable
as String,feedUrl: null == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeepLinkTarget].
extension DeepLinkTargetPatterns on DeepLinkTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PodcastDeepLinkTarget value)?  podcast,TResult Function( EpisodeDeepLinkTarget value)?  episode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PodcastDeepLinkTarget() when podcast != null:
return podcast(_that);case EpisodeDeepLinkTarget() when episode != null:
return episode(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PodcastDeepLinkTarget value)  podcast,required TResult Function( EpisodeDeepLinkTarget value)  episode,}){
final _that = this;
switch (_that) {
case PodcastDeepLinkTarget():
return podcast(_that);case EpisodeDeepLinkTarget():
return episode(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PodcastDeepLinkTarget value)?  podcast,TResult? Function( EpisodeDeepLinkTarget value)?  episode,}){
final _that = this;
switch (_that) {
case PodcastDeepLinkTarget() when podcast != null:
return podcast(_that);case EpisodeDeepLinkTarget() when episode != null:
return episode(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String itunesId,  String feedUrl,  String title,  String? artworkUrl)?  podcast,TResult Function( String itunesId,  String feedUrl,  PodcastItem episode,  String podcastTitle,  String? artworkUrl,  EpisodeWithProgress? progress)?  episode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PodcastDeepLinkTarget() when podcast != null:
return podcast(_that.itunesId,_that.feedUrl,_that.title,_that.artworkUrl);case EpisodeDeepLinkTarget() when episode != null:
return episode(_that.itunesId,_that.feedUrl,_that.episode,_that.podcastTitle,_that.artworkUrl,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String itunesId,  String feedUrl,  String title,  String? artworkUrl)  podcast,required TResult Function( String itunesId,  String feedUrl,  PodcastItem episode,  String podcastTitle,  String? artworkUrl,  EpisodeWithProgress? progress)  episode,}) {final _that = this;
switch (_that) {
case PodcastDeepLinkTarget():
return podcast(_that.itunesId,_that.feedUrl,_that.title,_that.artworkUrl);case EpisodeDeepLinkTarget():
return episode(_that.itunesId,_that.feedUrl,_that.episode,_that.podcastTitle,_that.artworkUrl,_that.progress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String itunesId,  String feedUrl,  String title,  String? artworkUrl)?  podcast,TResult? Function( String itunesId,  String feedUrl,  PodcastItem episode,  String podcastTitle,  String? artworkUrl,  EpisodeWithProgress? progress)?  episode,}) {final _that = this;
switch (_that) {
case PodcastDeepLinkTarget() when podcast != null:
return podcast(_that.itunesId,_that.feedUrl,_that.title,_that.artworkUrl);case EpisodeDeepLinkTarget() when episode != null:
return episode(_that.itunesId,_that.feedUrl,_that.episode,_that.podcastTitle,_that.artworkUrl,_that.progress);case _:
  return null;

}
}

}

/// @nodoc


class PodcastDeepLinkTarget implements DeepLinkTarget {
  const PodcastDeepLinkTarget({required this.itunesId, required this.feedUrl, required this.title, this.artworkUrl});
  

@override final  String itunesId;
@override final  String feedUrl;
 final  String title;
@override final  String? artworkUrl;

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PodcastDeepLinkTargetCopyWith<PodcastDeepLinkTarget> get copyWith => _$PodcastDeepLinkTargetCopyWithImpl<PodcastDeepLinkTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PodcastDeepLinkTarget&&(identical(other.itunesId, itunesId) || other.itunesId == itunesId)&&(identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl));
}


@override
int get hashCode => Object.hash(runtimeType,itunesId,feedUrl,title,artworkUrl);

@override
String toString() {
  return 'DeepLinkTarget.podcast(itunesId: $itunesId, feedUrl: $feedUrl, title: $title, artworkUrl: $artworkUrl)';
}


}

/// @nodoc
abstract mixin class $PodcastDeepLinkTargetCopyWith<$Res> implements $DeepLinkTargetCopyWith<$Res> {
  factory $PodcastDeepLinkTargetCopyWith(PodcastDeepLinkTarget value, $Res Function(PodcastDeepLinkTarget) _then) = _$PodcastDeepLinkTargetCopyWithImpl;
@override @useResult
$Res call({
 String itunesId, String feedUrl, String title, String? artworkUrl
});




}
/// @nodoc
class _$PodcastDeepLinkTargetCopyWithImpl<$Res>
    implements $PodcastDeepLinkTargetCopyWith<$Res> {
  _$PodcastDeepLinkTargetCopyWithImpl(this._self, this._then);

  final PodcastDeepLinkTarget _self;
  final $Res Function(PodcastDeepLinkTarget) _then;

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itunesId = null,Object? feedUrl = null,Object? title = null,Object? artworkUrl = freezed,}) {
  return _then(PodcastDeepLinkTarget(
itunesId: null == itunesId ? _self.itunesId : itunesId // ignore: cast_nullable_to_non_nullable
as String,feedUrl: null == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class EpisodeDeepLinkTarget implements DeepLinkTarget {
  const EpisodeDeepLinkTarget({required this.itunesId, required this.feedUrl, required this.episode, required this.podcastTitle, this.artworkUrl, this.progress});
  

@override final  String itunesId;
@override final  String feedUrl;
 final  PodcastItem episode;
 final  String podcastTitle;
@override final  String? artworkUrl;
 final  EpisodeWithProgress? progress;

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EpisodeDeepLinkTargetCopyWith<EpisodeDeepLinkTarget> get copyWith => _$EpisodeDeepLinkTargetCopyWithImpl<EpisodeDeepLinkTarget>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EpisodeDeepLinkTarget&&(identical(other.itunesId, itunesId) || other.itunesId == itunesId)&&(identical(other.feedUrl, feedUrl) || other.feedUrl == feedUrl)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.podcastTitle, podcastTitle) || other.podcastTitle == podcastTitle)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,itunesId,feedUrl,episode,podcastTitle,artworkUrl,progress);

@override
String toString() {
  return 'DeepLinkTarget.episode(itunesId: $itunesId, feedUrl: $feedUrl, episode: $episode, podcastTitle: $podcastTitle, artworkUrl: $artworkUrl, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $EpisodeDeepLinkTargetCopyWith<$Res> implements $DeepLinkTargetCopyWith<$Res> {
  factory $EpisodeDeepLinkTargetCopyWith(EpisodeDeepLinkTarget value, $Res Function(EpisodeDeepLinkTarget) _then) = _$EpisodeDeepLinkTargetCopyWithImpl;
@override @useResult
$Res call({
 String itunesId, String feedUrl, PodcastItem episode, String podcastTitle, String? artworkUrl, EpisodeWithProgress? progress
});


$EpisodeWithProgressCopyWith<$Res>? get progress;

}
/// @nodoc
class _$EpisodeDeepLinkTargetCopyWithImpl<$Res>
    implements $EpisodeDeepLinkTargetCopyWith<$Res> {
  _$EpisodeDeepLinkTargetCopyWithImpl(this._self, this._then);

  final EpisodeDeepLinkTarget _self;
  final $Res Function(EpisodeDeepLinkTarget) _then;

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itunesId = null,Object? feedUrl = null,Object? episode = null,Object? podcastTitle = null,Object? artworkUrl = freezed,Object? progress = freezed,}) {
  return _then(EpisodeDeepLinkTarget(
itunesId: null == itunesId ? _self.itunesId : itunesId // ignore: cast_nullable_to_non_nullable
as String,feedUrl: null == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as PodcastItem,podcastTitle: null == podcastTitle ? _self.podcastTitle : podcastTitle // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EpisodeWithProgress?,
  ));
}

/// Create a copy of DeepLinkTarget
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EpisodeWithProgressCopyWith<$Res>? get progress {
    if (_self.progress == null) {
    return null;
  }

  return $EpisodeWithProgressCopyWith<$Res>(_self.progress!, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
