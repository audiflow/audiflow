// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlaybackState()';
}


}

/// @nodoc
class $PlaybackStateCopyWith<$Res>  {
$PlaybackStateCopyWith(PlaybackState _, $Res Function(PlaybackState) __);
}


/// Adds pattern-matching-related methods to [PlaybackState].
extension PlaybackStatePatterns on PlaybackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PlaybackIdle value)?  idle,TResult Function( PlaybackLoading value)?  loading,TResult Function( PlaybackPlaying value)?  playing,TResult Function( PlaybackPaused value)?  paused,TResult Function( PlaybackError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PlaybackIdle() when idle != null:
return idle(_that);case PlaybackLoading() when loading != null:
return loading(_that);case PlaybackPlaying() when playing != null:
return playing(_that);case PlaybackPaused() when paused != null:
return paused(_that);case PlaybackError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PlaybackIdle value)  idle,required TResult Function( PlaybackLoading value)  loading,required TResult Function( PlaybackPlaying value)  playing,required TResult Function( PlaybackPaused value)  paused,required TResult Function( PlaybackError value)  error,}){
final _that = this;
switch (_that) {
case PlaybackIdle():
return idle(_that);case PlaybackLoading():
return loading(_that);case PlaybackPlaying():
return playing(_that);case PlaybackPaused():
return paused(_that);case PlaybackError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PlaybackIdle value)?  idle,TResult? Function( PlaybackLoading value)?  loading,TResult? Function( PlaybackPlaying value)?  playing,TResult? Function( PlaybackPaused value)?  paused,TResult? Function( PlaybackError value)?  error,}){
final _that = this;
switch (_that) {
case PlaybackIdle() when idle != null:
return idle(_that);case PlaybackLoading() when loading != null:
return loading(_that);case PlaybackPlaying() when playing != null:
return playing(_that);case PlaybackPaused() when paused != null:
return paused(_that);case PlaybackError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String episodeUrl)?  loading,TResult Function( String episodeUrl)?  playing,TResult Function( String episodeUrl)?  paused,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PlaybackIdle() when idle != null:
return idle();case PlaybackLoading() when loading != null:
return loading(_that.episodeUrl);case PlaybackPlaying() when playing != null:
return playing(_that.episodeUrl);case PlaybackPaused() when paused != null:
return paused(_that.episodeUrl);case PlaybackError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String episodeUrl)  loading,required TResult Function( String episodeUrl)  playing,required TResult Function( String episodeUrl)  paused,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case PlaybackIdle():
return idle();case PlaybackLoading():
return loading(_that.episodeUrl);case PlaybackPlaying():
return playing(_that.episodeUrl);case PlaybackPaused():
return paused(_that.episodeUrl);case PlaybackError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String episodeUrl)?  loading,TResult? Function( String episodeUrl)?  playing,TResult? Function( String episodeUrl)?  paused,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case PlaybackIdle() when idle != null:
return idle();case PlaybackLoading() when loading != null:
return loading(_that.episodeUrl);case PlaybackPlaying() when playing != null:
return playing(_that.episodeUrl);case PlaybackPaused() when paused != null:
return paused(_that.episodeUrl);case PlaybackError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class PlaybackIdle implements PlaybackState {
  const PlaybackIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PlaybackState.idle()';
}


}




/// @nodoc


class PlaybackLoading implements PlaybackState {
  const PlaybackLoading({required this.episodeUrl});
  

 final  String episodeUrl;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackLoadingCopyWith<PlaybackLoading> get copyWith => _$PlaybackLoadingCopyWithImpl<PlaybackLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackLoading&&(identical(other.episodeUrl, episodeUrl) || other.episodeUrl == episodeUrl));
}


@override
int get hashCode => Object.hash(runtimeType,episodeUrl);

@override
String toString() {
  return 'PlaybackState.loading(episodeUrl: $episodeUrl)';
}


}

/// @nodoc
abstract mixin class $PlaybackLoadingCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory $PlaybackLoadingCopyWith(PlaybackLoading value, $Res Function(PlaybackLoading) _then) = _$PlaybackLoadingCopyWithImpl;
@useResult
$Res call({
 String episodeUrl
});




}
/// @nodoc
class _$PlaybackLoadingCopyWithImpl<$Res>
    implements $PlaybackLoadingCopyWith<$Res> {
  _$PlaybackLoadingCopyWithImpl(this._self, this._then);

  final PlaybackLoading _self;
  final $Res Function(PlaybackLoading) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? episodeUrl = null,}) {
  return _then(PlaybackLoading(
episodeUrl: null == episodeUrl ? _self.episodeUrl : episodeUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlaybackPlaying implements PlaybackState {
  const PlaybackPlaying({required this.episodeUrl});
  

 final  String episodeUrl;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackPlayingCopyWith<PlaybackPlaying> get copyWith => _$PlaybackPlayingCopyWithImpl<PlaybackPlaying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackPlaying&&(identical(other.episodeUrl, episodeUrl) || other.episodeUrl == episodeUrl));
}


@override
int get hashCode => Object.hash(runtimeType,episodeUrl);

@override
String toString() {
  return 'PlaybackState.playing(episodeUrl: $episodeUrl)';
}


}

/// @nodoc
abstract mixin class $PlaybackPlayingCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory $PlaybackPlayingCopyWith(PlaybackPlaying value, $Res Function(PlaybackPlaying) _then) = _$PlaybackPlayingCopyWithImpl;
@useResult
$Res call({
 String episodeUrl
});




}
/// @nodoc
class _$PlaybackPlayingCopyWithImpl<$Res>
    implements $PlaybackPlayingCopyWith<$Res> {
  _$PlaybackPlayingCopyWithImpl(this._self, this._then);

  final PlaybackPlaying _self;
  final $Res Function(PlaybackPlaying) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? episodeUrl = null,}) {
  return _then(PlaybackPlaying(
episodeUrl: null == episodeUrl ? _self.episodeUrl : episodeUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlaybackPaused implements PlaybackState {
  const PlaybackPaused({required this.episodeUrl});
  

 final  String episodeUrl;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackPausedCopyWith<PlaybackPaused> get copyWith => _$PlaybackPausedCopyWithImpl<PlaybackPaused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackPaused&&(identical(other.episodeUrl, episodeUrl) || other.episodeUrl == episodeUrl));
}


@override
int get hashCode => Object.hash(runtimeType,episodeUrl);

@override
String toString() {
  return 'PlaybackState.paused(episodeUrl: $episodeUrl)';
}


}

/// @nodoc
abstract mixin class $PlaybackPausedCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory $PlaybackPausedCopyWith(PlaybackPaused value, $Res Function(PlaybackPaused) _then) = _$PlaybackPausedCopyWithImpl;
@useResult
$Res call({
 String episodeUrl
});




}
/// @nodoc
class _$PlaybackPausedCopyWithImpl<$Res>
    implements $PlaybackPausedCopyWith<$Res> {
  _$PlaybackPausedCopyWithImpl(this._self, this._then);

  final PlaybackPaused _self;
  final $Res Function(PlaybackPaused) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? episodeUrl = null,}) {
  return _then(PlaybackPaused(
episodeUrl: null == episodeUrl ? _self.episodeUrl : episodeUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlaybackError implements PlaybackState {
  const PlaybackError({required this.message});
  

 final  String message;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackErrorCopyWith<PlaybackError> get copyWith => _$PlaybackErrorCopyWithImpl<PlaybackError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'PlaybackState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $PlaybackErrorCopyWith<$Res> implements $PlaybackStateCopyWith<$Res> {
  factory $PlaybackErrorCopyWith(PlaybackError value, $Res Function(PlaybackError) _then) = _$PlaybackErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PlaybackErrorCopyWithImpl<$Res>
    implements $PlaybackErrorCopyWith<$Res> {
  _$PlaybackErrorCopyWithImpl(this._self, this._then);

  final PlaybackError _self;
  final $Res Function(PlaybackError) _then;

/// Create a copy of PlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PlaybackError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
