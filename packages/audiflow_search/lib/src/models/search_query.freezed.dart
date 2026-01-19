// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchQuery {

/// The search term for finding podcasts (required, non-empty).
 String get term;/// ISO 3166-1 alpha-2 country code (2 lowercase letters).
 String? get country;/// Language code in format `{lang}_{country}` (both lowercase).
 String? get language;/// Maximum number of search results to return (1-200 inclusive).
 int? get limit;/// Search attribute to filter by specific fields.
 String? get attribute;/// Whether to include explicit content in results.
 bool? get explicit;/// Custom query parameters to append to the API request.
 Map<String, String>? get customParams;/// HTTP If-Modified-Since header value for conditional requests.
 String? get ifModifiedSince;/// HTTP If-None-Match header value for conditional requests.
 String? get ifNoneMatch;
/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchQueryCopyWith<SearchQuery> get copyWith => _$SearchQueryCopyWithImpl<SearchQuery>(this as SearchQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchQuery&&(identical(other.term, term) || other.term == term)&&(identical(other.country, country) || other.country == country)&&(identical(other.language, language) || other.language == language)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.attribute, attribute) || other.attribute == attribute)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&const DeepCollectionEquality().equals(other.customParams, customParams)&&(identical(other.ifModifiedSince, ifModifiedSince) || other.ifModifiedSince == ifModifiedSince)&&(identical(other.ifNoneMatch, ifNoneMatch) || other.ifNoneMatch == ifNoneMatch));
}


@override
int get hashCode => Object.hash(runtimeType,term,country,language,limit,attribute,explicit,const DeepCollectionEquality().hash(customParams),ifModifiedSince,ifNoneMatch);

@override
String toString() {
  return 'SearchQuery(term: $term, country: $country, language: $language, limit: $limit, attribute: $attribute, explicit: $explicit, customParams: $customParams, ifModifiedSince: $ifModifiedSince, ifNoneMatch: $ifNoneMatch)';
}


}

/// @nodoc
abstract mixin class $SearchQueryCopyWith<$Res>  {
  factory $SearchQueryCopyWith(SearchQuery value, $Res Function(SearchQuery) _then) = _$SearchQueryCopyWithImpl;
@useResult
$Res call({
 String term, String? country, String? language, int? limit, String? attribute, bool? explicit, Map<String, String>? customParams, String? ifModifiedSince, String? ifNoneMatch
});




}
/// @nodoc
class _$SearchQueryCopyWithImpl<$Res>
    implements $SearchQueryCopyWith<$Res> {
  _$SearchQueryCopyWithImpl(this._self, this._then);

  final SearchQuery _self;
  final $Res Function(SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? term = null,Object? country = freezed,Object? language = freezed,Object? limit = freezed,Object? attribute = freezed,Object? explicit = freezed,Object? customParams = freezed,Object? ifModifiedSince = freezed,Object? ifNoneMatch = freezed,}) {
  return _then(_self.copyWith(
term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,attribute: freezed == attribute ? _self.attribute : attribute // ignore: cast_nullable_to_non_nullable
as String?,explicit: freezed == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool?,customParams: freezed == customParams ? _self.customParams : customParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,ifModifiedSince: freezed == ifModifiedSince ? _self.ifModifiedSince : ifModifiedSince // ignore: cast_nullable_to_non_nullable
as String?,ifNoneMatch: freezed == ifNoneMatch ? _self.ifNoneMatch : ifNoneMatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchQuery].
extension SearchQueryPatterns on SearchQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchQuery value)  $default,){
final _that = this;
switch (_that) {
case _SearchQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchQuery value)?  $default,){
final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String term,  String? country,  String? language,  int? limit,  String? attribute,  bool? explicit,  Map<String, String>? customParams,  String? ifModifiedSince,  String? ifNoneMatch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.term,_that.country,_that.language,_that.limit,_that.attribute,_that.explicit,_that.customParams,_that.ifModifiedSince,_that.ifNoneMatch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String term,  String? country,  String? language,  int? limit,  String? attribute,  bool? explicit,  Map<String, String>? customParams,  String? ifModifiedSince,  String? ifNoneMatch)  $default,) {final _that = this;
switch (_that) {
case _SearchQuery():
return $default(_that.term,_that.country,_that.language,_that.limit,_that.attribute,_that.explicit,_that.customParams,_that.ifModifiedSince,_that.ifNoneMatch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String term,  String? country,  String? language,  int? limit,  String? attribute,  bool? explicit,  Map<String, String>? customParams,  String? ifModifiedSince,  String? ifNoneMatch)?  $default,) {final _that = this;
switch (_that) {
case _SearchQuery() when $default != null:
return $default(_that.term,_that.country,_that.language,_that.limit,_that.attribute,_that.explicit,_that.customParams,_that.ifModifiedSince,_that.ifNoneMatch);case _:
  return null;

}
}

}

/// @nodoc


class _SearchQuery extends SearchQuery {
  const _SearchQuery({required this.term, this.country, this.language, this.limit, this.attribute, this.explicit, final  Map<String, String>? customParams, this.ifModifiedSince, this.ifNoneMatch}): _customParams = customParams,super._();


/// The search term for finding podcasts (required, non-empty).
@override final  String term;
/// ISO 3166-1 alpha-2 country code (2 lowercase letters).
@override final  String? country;
/// Language code in format `{lang}_{country}` (both lowercase).
@override final  String? language;
/// Maximum number of search results to return (1-200 inclusive).
@override final  int? limit;
/// Search attribute to filter by specific fields.
@override final  String? attribute;
/// Whether to include explicit content in results.
@override final  bool? explicit;
/// Custom query parameters to append to the API request.
 final  Map<String, String>? _customParams;
/// Custom query parameters to append to the API request.
@override Map<String, String>? get customParams {
  final value = _customParams;
  if (value == null) return null;
  if (_customParams is EqualUnmodifiableMapView) return _customParams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// HTTP If-Modified-Since header value for conditional requests.
@override final  String? ifModifiedSince;
/// HTTP If-None-Match header value for conditional requests.
@override final  String? ifNoneMatch;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchQueryCopyWith<_SearchQuery> get copyWith => __$SearchQueryCopyWithImpl<_SearchQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchQuery&&(identical(other.term, term) || other.term == term)&&(identical(other.country, country) || other.country == country)&&(identical(other.language, language) || other.language == language)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.attribute, attribute) || other.attribute == attribute)&&(identical(other.explicit, explicit) || other.explicit == explicit)&&const DeepCollectionEquality().equals(other._customParams, _customParams)&&(identical(other.ifModifiedSince, ifModifiedSince) || other.ifModifiedSince == ifModifiedSince)&&(identical(other.ifNoneMatch, ifNoneMatch) || other.ifNoneMatch == ifNoneMatch));
}


@override
int get hashCode => Object.hash(runtimeType,term,country,language,limit,attribute,explicit,const DeepCollectionEquality().hash(_customParams),ifModifiedSince,ifNoneMatch);

@override
String toString() {
  return 'SearchQuery(term: $term, country: $country, language: $language, limit: $limit, attribute: $attribute, explicit: $explicit, customParams: $customParams, ifModifiedSince: $ifModifiedSince, ifNoneMatch: $ifNoneMatch)';
}


}

/// @nodoc
abstract mixin class _$SearchQueryCopyWith<$Res> implements $SearchQueryCopyWith<$Res> {
  factory _$SearchQueryCopyWith(_SearchQuery value, $Res Function(_SearchQuery) _then) = __$SearchQueryCopyWithImpl;
@override @useResult
$Res call({
 String term, String? country, String? language, int? limit, String? attribute, bool? explicit, Map<String, String>? customParams, String? ifModifiedSince, String? ifNoneMatch
});




}
/// @nodoc
class __$SearchQueryCopyWithImpl<$Res>
    implements _$SearchQueryCopyWith<$Res> {
  __$SearchQueryCopyWithImpl(this._self, this._then);

  final _SearchQuery _self;
  final $Res Function(_SearchQuery) _then;

/// Create a copy of SearchQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? term = null,Object? country = freezed,Object? language = freezed,Object? limit = freezed,Object? attribute = freezed,Object? explicit = freezed,Object? customParams = freezed,Object? ifModifiedSince = freezed,Object? ifNoneMatch = freezed,}) {
  return _then(_SearchQuery(
term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,attribute: freezed == attribute ? _self.attribute : attribute // ignore: cast_nullable_to_non_nullable
as String?,explicit: freezed == explicit ? _self.explicit : explicit // ignore: cast_nullable_to_non_nullable
as bool?,customParams: freezed == customParams ? _self._customParams : customParams // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,ifModifiedSince: freezed == ifModifiedSince ? _self.ifModifiedSince : ifModifiedSince // ignore: cast_nullable_to_non_nullable
as String?,ifNoneMatch: freezed == ifNoneMatch ? _self.ifNoneMatch : ifNoneMatch // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
