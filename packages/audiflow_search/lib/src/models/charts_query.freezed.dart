// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'charts_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChartsQuery {

/// ISO 3166-1 alpha-2 country code (2 lowercase letters, required).
 String get country;/// Maximum number of chart results to return (1-200 inclusive).
 int? get limit;/// Genre filter for chart retrieval.
 ItunesGenre? get genre;/// Whether to include explicit content in chart results.
 bool? get explicit;/// HTTP If-Modified-Since header value for conditional requests.
 String? get ifModifiedSince;/// HTTP If-None-Match header value for conditional requests.
 String? get ifNoneMatch;
/// Create a copy of ChartsQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChartsQueryCopyWith<ChartsQuery> get copyWith => _$ChartsQueryCopyWithImpl<ChartsQuery>(this as ChartsQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChartsQuery&&(identical(other.country, country) || other.country == country)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&(identical(other.ifModifiedSince, ifModifiedSince) || other.ifModifiedSince == ifModifiedSince)&&(identical(other.ifNoneMatch, ifNoneMatch) || other.ifNoneMatch == ifNoneMatch));
}


@override
int get hashCode => Object.hash(runtimeType,country,limit,genre,explicit,ifModifiedSince,ifNoneMatch);

@override
String toString() {
  return 'ChartsQuery(country: $country, limit: $limit, genre: $genre, explicit: $explicit, ifModifiedSince: $ifModifiedSince, ifNoneMatch: $ifNoneMatch)';
}


}

/// @nodoc
abstract mixin class $ChartsQueryCopyWith<$Res>  {
  factory $ChartsQueryCopyWith(ChartsQuery value, $Res Function(ChartsQuery) _then) = _$ChartsQueryCopyWithImpl;
@useResult
$Res call({
 String country, int? limit, ItunesGenre? genre, bool? explicit, String? ifModifiedSince, String? ifNoneMatch
});




}
/// @nodoc
class _$ChartsQueryCopyWithImpl<$Res>
    implements $ChartsQueryCopyWith<$Res> {
  _$ChartsQueryCopyWithImpl(this._self, this._then);

  final ChartsQuery _self;
  final $Res Function(ChartsQuery) _then;

/// Create a copy of ChartsQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? country = null,Object? limit = freezed,Object? genre = freezed,Object? explicit = freezed,Object? ifModifiedSince = freezed,Object? ifNoneMatch = freezed,}) {
  return _then(_self.copyWith(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as ItunesGenre?,explicit: freezed == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool?,ifModifiedSince: freezed == ifModifiedSince ? _self.ifModifiedSince : ifModifiedSince // ignore: cast_nullable_to_non_nullable
as String?,ifNoneMatch: freezed == ifNoneMatch ? _self.ifNoneMatch : ifNoneMatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChartsQuery].
extension ChartsQueryPatterns on ChartsQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChartsQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChartsQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChartsQuery value)  $default,){
final _that = this;
switch (_that) {
case _ChartsQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChartsQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ChartsQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String country,  int? limit,  ItunesGenre? genre,  bool? explicit,  String? ifModifiedSince,  String? ifNoneMatch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChartsQuery() when $default != null:
return $default(_that.country,_that.limit,_that.genre,_that.explicit,_that.ifModifiedSince,_that.ifNoneMatch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String country,  int? limit,  ItunesGenre? genre,  bool? explicit,  String? ifModifiedSince,  String? ifNoneMatch)  $default,) {final _that = this;
switch (_that) {
case _ChartsQuery():
return $default(_that.country,_that.limit,_that.genre,_that.explicit,_that.ifModifiedSince,_that.ifNoneMatch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String country,  int? limit,  ItunesGenre? genre,  bool? explicit,  String? ifModifiedSince,  String? ifNoneMatch)?  $default,) {final _that = this;
switch (_that) {
case _ChartsQuery() when $default != null:
return $default(_that.country,_that.limit,_that.genre,_that.explicit,_that.ifModifiedSince,_that.ifNoneMatch);case _:
  return null;

}
}

}

/// @nodoc


class _ChartsQuery extends ChartsQuery {
  const _ChartsQuery({required this.country, this.limit, this.genre, this.explicit, this.ifModifiedSince, this.ifNoneMatch}): super._();


/// ISO 3166-1 alpha-2 country code (2 lowercase letters, required).
@override final  String country;
/// Maximum number of chart results to return (1-200 inclusive).
@override final  int? limit;
/// Genre filter for chart retrieval.
@override final  ItunesGenre? genre;
/// Whether to include explicit content in chart results.
@override final  bool? explicit;
/// HTTP If-Modified-Since header value for conditional requests.
@override final  String? ifModifiedSince;
/// HTTP If-None-Match header value for conditional requests.
@override final  String? ifNoneMatch;

/// Create a copy of ChartsQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChartsQueryCopyWith<_ChartsQuery> get copyWith => __$ChartsQueryCopyWithImpl<_ChartsQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChartsQuery&&(identical(other.country, country) || other.country == country)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&(identical(other.ifModifiedSince, ifModifiedSince) || other.ifModifiedSince == ifModifiedSince)&&(identical(other.ifNoneMatch, ifNoneMatch) || other.ifNoneMatch == ifNoneMatch));
}


@override
int get hashCode => Object.hash(runtimeType,country,limit,genre,explicit,ifModifiedSince,ifNoneMatch);

@override
String toString() {
  return 'ChartsQuery(country: $country, limit: $limit, genre: $genre, explicit: $explicit, ifModifiedSince: $ifModifiedSince, ifNoneMatch: $ifNoneMatch)';
}


}

/// @nodoc
abstract mixin class _$ChartsQueryCopyWith<$Res> implements $ChartsQueryCopyWith<$Res> {
  factory _$ChartsQueryCopyWith(_ChartsQuery value, $Res Function(_ChartsQuery) _then) = __$ChartsQueryCopyWithImpl;
@override @useResult
$Res call({
 String country, int? limit, ItunesGenre? genre, bool? explicit, String? ifModifiedSince, String? ifNoneMatch
});




}
/// @nodoc
class __$ChartsQueryCopyWithImpl<$Res>
    implements _$ChartsQueryCopyWith<$Res> {
  __$ChartsQueryCopyWithImpl(this._self, this._then);

  final _ChartsQuery _self;
  final $Res Function(_ChartsQuery) _then;

/// Create a copy of ChartsQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? country = null,Object? limit = freezed,Object? genre = freezed,Object? explicit = freezed,Object? ifModifiedSince = freezed,Object? ifNoneMatch = freezed,}) {
  return _then(_ChartsQuery(
country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as ItunesGenre?,explicit: freezed == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool?,ifModifiedSince: freezed == ifModifiedSince ? _self.ifModifiedSince : ifModifiedSince // ignore: cast_nullable_to_non_nullable
as String?,ifNoneMatch: freezed == ifNoneMatch ? _self.ifNoneMatch : ifNoneMatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
