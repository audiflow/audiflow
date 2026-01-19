// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchResult {

/// Total number of results found by the search/chart query.
 int get totalCount;/// List of podcast results returned by the search/chart query.
 List<Podcast> get podcasts;/// Identifier of the provider that generated these results.
 String get provider;/// Timestamp when these results were retrieved.
 DateTime? get timestamp;/// HTTP Last-Modified header value from the API response.
 String? get lastModified;/// HTTP ETag header value from the API response.
 String? get etag;
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultCopyWith<SearchResult> get copyWith => _$SearchResultCopyWithImpl<SearchResult>(this as SearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other.podcasts, podcasts)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.etag, etag) || other.etag == etag));
}


@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(podcasts),provider,timestamp,lastModified,etag);

@override
String toString() {
  return 'SearchResult(totalCount: $totalCount, podcasts: $podcasts, provider: $provider, timestamp: $timestamp, lastModified: $lastModified, etag: $etag)';
}


}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res>  {
  factory $SearchResultCopyWith(SearchResult value, $Res Function(SearchResult) _then) = _$SearchResultCopyWithImpl;
@useResult
$Res call({
 int totalCount, List<Podcast> podcasts, String provider, DateTime? timestamp, String? lastModified, String? etag
});




}
/// @nodoc
class _$SearchResultCopyWithImpl<$Res>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCount = null,Object? podcasts = null,Object? provider = null,Object? timestamp = freezed,Object? lastModified = freezed,Object? etag = freezed,}) {
  return _then(_self.copyWith(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,podcasts: null == podcasts ? _self.podcasts : podcasts // ignore: cast_nullable_to_non_nullable
as List<Podcast>,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as String?,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCount,  List<Podcast> podcasts,  String provider,  DateTime? timestamp,  String? lastModified,  String? etag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.totalCount,_that.podcasts,_that.provider,_that.timestamp,_that.lastModified,_that.etag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCount,  List<Podcast> podcasts,  String provider,  DateTime? timestamp,  String? lastModified,  String? etag)  $default,) {final _that = this;
switch (_that) {
case _SearchResult():
return $default(_that.totalCount,_that.podcasts,_that.provider,_that.timestamp,_that.lastModified,_that.etag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCount,  List<Podcast> podcasts,  String provider,  DateTime? timestamp,  String? lastModified,  String? etag)?  $default,) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.totalCount,_that.podcasts,_that.provider,_that.timestamp,_that.lastModified,_that.etag);case _:
  return null;

}
}

}

/// @nodoc


class _SearchResult extends SearchResult {
  const _SearchResult({required this.totalCount, required final  List<Podcast> podcasts, required this.provider, this.timestamp, this.lastModified, this.etag}): _podcasts = podcasts,super._();


/// Total number of results found by the search/chart query.
@override final  int totalCount;
/// List of podcast results returned by the search/chart query.
 final  List<Podcast> _podcasts;
/// List of podcast results returned by the search/chart query.
@override List<Podcast> get podcasts {
  if (_podcasts is EqualUnmodifiableListView) return _podcasts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_podcasts);
}

/// Identifier of the provider that generated these results.
@override final  String provider;
/// Timestamp when these results were retrieved.
@override final  DateTime? timestamp;
/// HTTP Last-Modified header value from the API response.
@override final  String? lastModified;
/// HTTP ETag header value from the API response.
@override final  String? etag;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultCopyWith<_SearchResult> get copyWith => __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResult&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&const DeepCollectionEquality().equals(other._podcasts, _podcasts)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.etag, etag) || other.etag == etag));
}


@override
int get hashCode => Object.hash(runtimeType,totalCount,const DeepCollectionEquality().hash(_podcasts),provider,timestamp,lastModified,etag);

@override
String toString() {
  return 'SearchResult(totalCount: $totalCount, podcasts: $podcasts, provider: $provider, timestamp: $timestamp, lastModified: $lastModified, etag: $etag)';
}


}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res> implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(_SearchResult value, $Res Function(_SearchResult) _then) = __$SearchResultCopyWithImpl;
@override @useResult
$Res call({
 int totalCount, List<Podcast> podcasts, String provider, DateTime? timestamp, String? lastModified, String? etag
});




}
/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCount = null,Object? podcasts = null,Object? provider = null,Object? timestamp = freezed,Object? lastModified = freezed,Object? etag = freezed,}) {
  return _then(_SearchResult(
totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,podcasts: null == podcasts ? _self._podcasts : podcasts // ignore: cast_nullable_to_non_nullable
as List<Podcast>,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as String?,etag: freezed == etag ? _self.etag : etag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
