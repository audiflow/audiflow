// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Podcast {

/// Unique identifier for this podcast (iTunes collection ID or track ID).
 String get id;/// The name of the podcast.
 String get name;/// The name of the podcast creator or host.
 String get artistName;/// List of genre names this podcast belongs to.
 List<String> get genres;/// Whether this podcast contains explicit content.
 bool get explicit;/// The RSS feed URL for this podcast.
 String? get feedUrl;/// A text description of the podcast.
 String? get description;/// URL to the podcast artwork image.
 String? get artworkUrl;/// The release date of the most recent episode.
 DateTime? get releaseDate;/// The total number of episodes/tracks in this podcast.
 int? get trackCount;
/// Create a copy of Podcast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PodcastCopyWith<Podcast> get copyWith => _$PodcastCopyWithImpl<Podcast>(this as Podcast, _$identity);





@override
String toString() {
  return 'Podcast(id: $id, name: $name, artistName: $artistName, genres: $genres, explicit: $explicit, feedUrl: $feedUrl, description: $description, artworkUrl: $artworkUrl, releaseDate: $releaseDate, trackCount: $trackCount)';
}


}

/// @nodoc
abstract mixin class $PodcastCopyWith<$Res>  {
  factory $PodcastCopyWith(Podcast value, $Res Function(Podcast) _then) = _$PodcastCopyWithImpl;
@useResult
$Res call({
 String id, String name, String artistName, List<String> genres, bool explicit, String? feedUrl, String? description, String? artworkUrl, DateTime? releaseDate, int? trackCount
});




}
/// @nodoc
class _$PodcastCopyWithImpl<$Res>
    implements $PodcastCopyWith<$Res> {
  _$PodcastCopyWithImpl(this._self, this._then);

  final Podcast _self;
  final $Res Function(Podcast) _then;

/// Create a copy of Podcast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? artistName = null,Object? genres = null,Object? explicit = null,Object? feedUrl = freezed,Object? description = freezed,Object? artworkUrl = freezed,Object? releaseDate = freezed,Object? trackCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,feedUrl: freezed == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,trackCount: freezed == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Podcast].
extension PodcastPatterns on Podcast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Podcast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Podcast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Podcast value)  $default,){
final _that = this;
switch (_that) {
case _Podcast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Podcast value)?  $default,){
final _that = this;
switch (_that) {
case _Podcast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String artistName,  List<String> genres,  bool explicit,  String? feedUrl,  String? description,  String? artworkUrl,  DateTime? releaseDate,  int? trackCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Podcast() when $default != null:
return $default(_that.id,_that.name,_that.artistName,_that.genres,_that.explicit,_that.feedUrl,_that.description,_that.artworkUrl,_that.releaseDate,_that.trackCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String artistName,  List<String> genres,  bool explicit,  String? feedUrl,  String? description,  String? artworkUrl,  DateTime? releaseDate,  int? trackCount)  $default,) {final _that = this;
switch (_that) {
case _Podcast():
return $default(_that.id,_that.name,_that.artistName,_that.genres,_that.explicit,_that.feedUrl,_that.description,_that.artworkUrl,_that.releaseDate,_that.trackCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String artistName,  List<String> genres,  bool explicit,  String? feedUrl,  String? description,  String? artworkUrl,  DateTime? releaseDate,  int? trackCount)?  $default,) {final _that = this;
switch (_that) {
case _Podcast() when $default != null:
return $default(_that.id,_that.name,_that.artistName,_that.genres,_that.explicit,_that.feedUrl,_that.description,_that.artworkUrl,_that.releaseDate,_that.trackCount);case _:
  return null;

}
}

}

/// @nodoc


class _Podcast extends Podcast {
  const _Podcast({required this.id, required this.name, required this.artistName, final  List<String> genres = const <String>[], this.explicit = false, this.feedUrl, this.description, this.artworkUrl, this.releaseDate, this.trackCount}): _genres = genres,super._();


/// Unique identifier for this podcast (iTunes collection ID or track ID).
@override final  String id;
/// The name of the podcast.
@override final  String name;
/// The name of the podcast creator or host.
@override final  String artistName;
/// List of genre names this podcast belongs to.
 final  List<String> _genres;
/// List of genre names this podcast belongs to.
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

/// Whether this podcast contains explicit content.
@override@JsonKey() final  bool explicit;
/// The RSS feed URL for this podcast.
@override final  String? feedUrl;
/// A text description of the podcast.
@override final  String? description;
/// URL to the podcast artwork image.
@override final  String? artworkUrl;
/// The release date of the most recent episode.
@override final  DateTime? releaseDate;
/// The total number of episodes/tracks in this podcast.
@override final  int? trackCount;

/// Create a copy of Podcast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PodcastCopyWith<_Podcast> get copyWith => __$PodcastCopyWithImpl<_Podcast>(this, _$identity);





@override
String toString() {
  return 'Podcast(id: $id, name: $name, artistName: $artistName, genres: $genres, explicit: $explicit, feedUrl: $feedUrl, description: $description, artworkUrl: $artworkUrl, releaseDate: $releaseDate, trackCount: $trackCount)';
}


}

/// @nodoc
abstract mixin class _$PodcastCopyWith<$Res> implements $PodcastCopyWith<$Res> {
  factory _$PodcastCopyWith(_Podcast value, $Res Function(_Podcast) _then) = __$PodcastCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String artistName, List<String> genres, bool explicit, String? feedUrl, String? description, String? artworkUrl, DateTime? releaseDate, int? trackCount
});




}
/// @nodoc
class __$PodcastCopyWithImpl<$Res>
    implements _$PodcastCopyWith<$Res> {
  __$PodcastCopyWithImpl(this._self, this._then);

  final _Podcast _self;
  final $Res Function(_Podcast) _then;

/// Create a copy of Podcast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? artistName = null,Object? genres = null,Object? explicit = null,Object? feedUrl = freezed,Object? description = freezed,Object? artworkUrl = freezed,Object? releaseDate = freezed,Object? trackCount = freezed,}) {
  return _then(_Podcast(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,explicit: null == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool,feedUrl: freezed == feedUrl ? _self.feedUrl : feedUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,trackCount: freezed == trackCount ? _self.trackCount : trackCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
