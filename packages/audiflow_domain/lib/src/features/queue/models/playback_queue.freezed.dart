// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QueueItemWithEpisode {

 QueueItem get queueItem; Episode get episode;/// Resolved artwork URL (episode image, falling back to podcast artwork).
 String? get artworkUrl;
/// Create a copy of QueueItemWithEpisode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QueueItemWithEpisodeCopyWith<QueueItemWithEpisode> get copyWith => _$QueueItemWithEpisodeCopyWithImpl<QueueItemWithEpisode>(this as QueueItemWithEpisode, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QueueItemWithEpisode&&(identical(other.queueItem, queueItem) || other.queueItem == queueItem)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl));
}


@override
int get hashCode => Object.hash(runtimeType,queueItem,episode,artworkUrl);

@override
String toString() {
  return 'QueueItemWithEpisode(queueItem: $queueItem, episode: $episode, artworkUrl: $artworkUrl)';
}


}

/// @nodoc
abstract mixin class $QueueItemWithEpisodeCopyWith<$Res>  {
  factory $QueueItemWithEpisodeCopyWith(QueueItemWithEpisode value, $Res Function(QueueItemWithEpisode) _then) = _$QueueItemWithEpisodeCopyWithImpl;
@useResult
$Res call({
 QueueItem queueItem, Episode episode, String? artworkUrl
});




}
/// @nodoc
class _$QueueItemWithEpisodeCopyWithImpl<$Res>
    implements $QueueItemWithEpisodeCopyWith<$Res> {
  _$QueueItemWithEpisodeCopyWithImpl(this._self, this._then);

  final QueueItemWithEpisode _self;
  final $Res Function(QueueItemWithEpisode) _then;

/// Create a copy of QueueItemWithEpisode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queueItem = null,Object? episode = null,Object? artworkUrl = freezed,}) {
  return _then(_self.copyWith(
queueItem: null == queueItem ? _self.queueItem : queueItem // ignore: cast_nullable_to_non_nullable
as QueueItem,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QueueItemWithEpisode].
extension QueueItemWithEpisodePatterns on QueueItemWithEpisode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QueueItemWithEpisode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QueueItemWithEpisode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QueueItemWithEpisode value)  $default,){
final _that = this;
switch (_that) {
case _QueueItemWithEpisode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QueueItemWithEpisode value)?  $default,){
final _that = this;
switch (_that) {
case _QueueItemWithEpisode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( QueueItem queueItem,  Episode episode,  String? artworkUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QueueItemWithEpisode() when $default != null:
return $default(_that.queueItem,_that.episode,_that.artworkUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( QueueItem queueItem,  Episode episode,  String? artworkUrl)  $default,) {final _that = this;
switch (_that) {
case _QueueItemWithEpisode():
return $default(_that.queueItem,_that.episode,_that.artworkUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( QueueItem queueItem,  Episode episode,  String? artworkUrl)?  $default,) {final _that = this;
switch (_that) {
case _QueueItemWithEpisode() when $default != null:
return $default(_that.queueItem,_that.episode,_that.artworkUrl);case _:
  return null;

}
}

}

/// @nodoc


class _QueueItemWithEpisode implements QueueItemWithEpisode {
  const _QueueItemWithEpisode({required this.queueItem, required this.episode, this.artworkUrl});


@override final  QueueItem queueItem;
@override final  Episode episode;
/// Resolved artwork URL (episode image, falling back to podcast artwork).
@override final  String? artworkUrl;

/// Create a copy of QueueItemWithEpisode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueItemWithEpisodeCopyWith<_QueueItemWithEpisode> get copyWith => __$QueueItemWithEpisodeCopyWithImpl<_QueueItemWithEpisode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueItemWithEpisode&&(identical(other.queueItem, queueItem) || other.queueItem == queueItem)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl));
}


@override
int get hashCode => Object.hash(runtimeType,queueItem,episode,artworkUrl);

@override
String toString() {
  return 'QueueItemWithEpisode(queueItem: $queueItem, episode: $episode, artworkUrl: $artworkUrl)';
}


}

/// @nodoc
abstract mixin class _$QueueItemWithEpisodeCopyWith<$Res> implements $QueueItemWithEpisodeCopyWith<$Res> {
  factory _$QueueItemWithEpisodeCopyWith(_QueueItemWithEpisode value, $Res Function(_QueueItemWithEpisode) _then) = __$QueueItemWithEpisodeCopyWithImpl;
@override @useResult
$Res call({
 QueueItem queueItem, Episode episode, String? artworkUrl
});




}
/// @nodoc
class __$QueueItemWithEpisodeCopyWithImpl<$Res>
    implements _$QueueItemWithEpisodeCopyWith<$Res> {
  __$QueueItemWithEpisodeCopyWithImpl(this._self, this._then);

  final _QueueItemWithEpisode _self;
  final $Res Function(_QueueItemWithEpisode) _then;

/// Create a copy of QueueItemWithEpisode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queueItem = null,Object? episode = null,Object? artworkUrl = freezed,}) {
  return _then(_QueueItemWithEpisode(
queueItem: null == queueItem ? _self.queueItem : queueItem // ignore: cast_nullable_to_non_nullable
as QueueItem,episode: null == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as Episode,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$PlaybackQueue {

/// Currently playing episode (not in queue items).
 Episode? get currentEpisode;/// Manually added queue items (Play Next / Play Later).
 List<QueueItemWithEpisode> get manualItems;/// Auto-generated queue items from episode list playback.
 List<QueueItemWithEpisode> get adhocItems;/// Source context for adhoc items (e.g., "Season 2").
 String? get adhocSourceContext;
/// Create a copy of PlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackQueueCopyWith<PlaybackQueue> get copyWith => _$PlaybackQueueCopyWithImpl<PlaybackQueue>(this as PlaybackQueue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackQueue&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&const DeepCollectionEquality().equals(other.manualItems, manualItems)&&const DeepCollectionEquality().equals(other.adhocItems, adhocItems)&&(identical(other.adhocSourceContext, adhocSourceContext) || other.adhocSourceContext == adhocSourceContext));
}


@override
int get hashCode => Object.hash(runtimeType,currentEpisode,const DeepCollectionEquality().hash(manualItems),const DeepCollectionEquality().hash(adhocItems),adhocSourceContext);

@override
String toString() {
  return 'PlaybackQueue(currentEpisode: $currentEpisode, manualItems: $manualItems, adhocItems: $adhocItems, adhocSourceContext: $adhocSourceContext)';
}


}

/// @nodoc
abstract mixin class $PlaybackQueueCopyWith<$Res>  {
  factory $PlaybackQueueCopyWith(PlaybackQueue value, $Res Function(PlaybackQueue) _then) = _$PlaybackQueueCopyWithImpl;
@useResult
$Res call({
 Episode? currentEpisode, List<QueueItemWithEpisode> manualItems, List<QueueItemWithEpisode> adhocItems, String? adhocSourceContext
});




}
/// @nodoc
class _$PlaybackQueueCopyWithImpl<$Res>
    implements $PlaybackQueueCopyWith<$Res> {
  _$PlaybackQueueCopyWithImpl(this._self, this._then);

  final PlaybackQueue _self;
  final $Res Function(PlaybackQueue) _then;

/// Create a copy of PlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentEpisode = freezed,Object? manualItems = null,Object? adhocItems = null,Object? adhocSourceContext = freezed,}) {
  return _then(_self.copyWith(
currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as Episode?,manualItems: null == manualItems ? _self.manualItems : manualItems // ignore: cast_nullable_to_non_nullable
as List<QueueItemWithEpisode>,adhocItems: null == adhocItems ? _self.adhocItems : adhocItems // ignore: cast_nullable_to_non_nullable
as List<QueueItemWithEpisode>,adhocSourceContext: freezed == adhocSourceContext ? _self.adhocSourceContext : adhocSourceContext // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackQueue].
extension PlaybackQueuePatterns on PlaybackQueue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackQueue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackQueue value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackQueue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackQueue value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackQueue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Episode? currentEpisode,  List<QueueItemWithEpisode> manualItems,  List<QueueItemWithEpisode> adhocItems,  String? adhocSourceContext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackQueue() when $default != null:
return $default(_that.currentEpisode,_that.manualItems,_that.adhocItems,_that.adhocSourceContext);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Episode? currentEpisode,  List<QueueItemWithEpisode> manualItems,  List<QueueItemWithEpisode> adhocItems,  String? adhocSourceContext)  $default,) {final _that = this;
switch (_that) {
case _PlaybackQueue():
return $default(_that.currentEpisode,_that.manualItems,_that.adhocItems,_that.adhocSourceContext);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Episode? currentEpisode,  List<QueueItemWithEpisode> manualItems,  List<QueueItemWithEpisode> adhocItems,  String? adhocSourceContext)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackQueue() when $default != null:
return $default(_that.currentEpisode,_that.manualItems,_that.adhocItems,_that.adhocSourceContext);case _:
  return null;

}
}

}

/// @nodoc


class _PlaybackQueue extends PlaybackQueue {
  const _PlaybackQueue({this.currentEpisode, final  List<QueueItemWithEpisode> manualItems = const [], final  List<QueueItemWithEpisode> adhocItems = const [], this.adhocSourceContext}): _manualItems = manualItems,_adhocItems = adhocItems,super._();


/// Currently playing episode (not in queue items).
@override final  Episode? currentEpisode;
/// Manually added queue items (Play Next / Play Later).
 final  List<QueueItemWithEpisode> _manualItems;
/// Manually added queue items (Play Next / Play Later).
@override@JsonKey() List<QueueItemWithEpisode> get manualItems {
  if (_manualItems is EqualUnmodifiableListView) return _manualItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_manualItems);
}

/// Auto-generated queue items from episode list playback.
 final  List<QueueItemWithEpisode> _adhocItems;
/// Auto-generated queue items from episode list playback.
@override@JsonKey() List<QueueItemWithEpisode> get adhocItems {
  if (_adhocItems is EqualUnmodifiableListView) return _adhocItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adhocItems);
}

/// Source context for adhoc items (e.g., "Season 2").
@override final  String? adhocSourceContext;

/// Create a copy of PlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackQueueCopyWith<_PlaybackQueue> get copyWith => __$PlaybackQueueCopyWithImpl<_PlaybackQueue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackQueue&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&const DeepCollectionEquality().equals(other._manualItems, _manualItems)&&const DeepCollectionEquality().equals(other._adhocItems, _adhocItems)&&(identical(other.adhocSourceContext, adhocSourceContext) || other.adhocSourceContext == adhocSourceContext));
}


@override
int get hashCode => Object.hash(runtimeType,currentEpisode,const DeepCollectionEquality().hash(_manualItems),const DeepCollectionEquality().hash(_adhocItems),adhocSourceContext);

@override
String toString() {
  return 'PlaybackQueue(currentEpisode: $currentEpisode, manualItems: $manualItems, adhocItems: $adhocItems, adhocSourceContext: $adhocSourceContext)';
}


}

/// @nodoc
abstract mixin class _$PlaybackQueueCopyWith<$Res> implements $PlaybackQueueCopyWith<$Res> {
  factory _$PlaybackQueueCopyWith(_PlaybackQueue value, $Res Function(_PlaybackQueue) _then) = __$PlaybackQueueCopyWithImpl;
@override @useResult
$Res call({
 Episode? currentEpisode, List<QueueItemWithEpisode> manualItems, List<QueueItemWithEpisode> adhocItems, String? adhocSourceContext
});




}
/// @nodoc
class __$PlaybackQueueCopyWithImpl<$Res>
    implements _$PlaybackQueueCopyWith<$Res> {
  __$PlaybackQueueCopyWithImpl(this._self, this._then);

  final _PlaybackQueue _self;
  final $Res Function(_PlaybackQueue) _then;

/// Create a copy of PlaybackQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentEpisode = freezed,Object? manualItems = null,Object? adhocItems = null,Object? adhocSourceContext = freezed,}) {
  return _then(_PlaybackQueue(
currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as Episode?,manualItems: null == manualItems ? _self._manualItems : manualItems // ignore: cast_nullable_to_non_nullable
as List<QueueItemWithEpisode>,adhocItems: null == adhocItems ? _self._adhocItems : adhocItems // ignore: cast_nullable_to_non_nullable
as List<QueueItemWithEpisode>,adhocSourceContext: freezed == adhocSourceContext ? _self.adhocSourceContext : adhocSourceContext // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
