// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_search_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastSearchState {
  String? get term => throw _privateConstructorUsedError;
  Country? get country => throw _privateConstructorUsedError;
  Attribute? get attribute => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  bool get explicit => throw _privateConstructorUsedError;
  List<ITunesSearchItem> get items => throw _privateConstructorUsedError;

  /// Create a copy of PodcastSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastSearchStateCopyWith<PodcastSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastSearchStateCopyWith<$Res> {
  factory $PodcastSearchStateCopyWith(
          PodcastSearchState value, $Res Function(PodcastSearchState) then) =
      _$PodcastSearchStateCopyWithImpl<$Res, PodcastSearchState>;
  @useResult
  $Res call(
      {String? term,
      Country? country,
      Attribute? attribute,
      int limit,
      String? language,
      int version,
      bool explicit,
      List<ITunesSearchItem> items});
}

/// @nodoc
class _$PodcastSearchStateCopyWithImpl<$Res, $Val extends PodcastSearchState>
    implements $PodcastSearchStateCopyWith<$Res> {
  _$PodcastSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = freezed,
    Object? country = freezed,
    Object? attribute = freezed,
    Object? limit = null,
    Object? language = freezed,
    Object? version = null,
    Object? explicit = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      term: freezed == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as Country?,
      attribute: freezed == attribute
          ? _value.attribute
          : attribute // ignore: cast_nullable_to_non_nullable
              as Attribute?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      explicit: null == explicit
          ? _value.explicit
          : explicit // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ITunesSearchItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastSearchStateImplCopyWith<$Res>
    implements $PodcastSearchStateCopyWith<$Res> {
  factory _$$PodcastSearchStateImplCopyWith(_$PodcastSearchStateImpl value,
          $Res Function(_$PodcastSearchStateImpl) then) =
      __$$PodcastSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? term,
      Country? country,
      Attribute? attribute,
      int limit,
      String? language,
      int version,
      bool explicit,
      List<ITunesSearchItem> items});
}

/// @nodoc
class __$$PodcastSearchStateImplCopyWithImpl<$Res>
    extends _$PodcastSearchStateCopyWithImpl<$Res, _$PodcastSearchStateImpl>
    implements _$$PodcastSearchStateImplCopyWith<$Res> {
  __$$PodcastSearchStateImplCopyWithImpl(_$PodcastSearchStateImpl _value,
      $Res Function(_$PodcastSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = freezed,
    Object? country = freezed,
    Object? attribute = freezed,
    Object? limit = null,
    Object? language = freezed,
    Object? version = null,
    Object? explicit = null,
    Object? items = null,
  }) {
    return _then(_$PodcastSearchStateImpl(
      term: freezed == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as Country?,
      attribute: freezed == attribute
          ? _value.attribute
          : attribute // ignore: cast_nullable_to_non_nullable
              as Attribute?,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      explicit: null == explicit
          ? _value.explicit
          : explicit // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ITunesSearchItem>,
    ));
  }
}

/// @nodoc

class _$PodcastSearchStateImpl implements _PodcastSearchState {
  const _$PodcastSearchStateImpl(
      {this.term,
      this.country,
      this.attribute,
      this.limit = 20,
      this.language,
      this.version = 0,
      this.explicit = false,
      final List<ITunesSearchItem> items = const []})
      : _items = items;

  @override
  final String? term;
  @override
  final Country? country;
  @override
  final Attribute? attribute;
  @override
  @JsonKey()
  final int limit;
  @override
  final String? language;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey()
  final bool explicit;
  final List<ITunesSearchItem> _items;
  @override
  @JsonKey()
  List<ITunesSearchItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'PodcastSearchState(term: $term, country: $country, attribute: $attribute, limit: $limit, language: $language, version: $version, explicit: $explicit, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastSearchStateImpl &&
            (identical(other.term, term) || other.term == term) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.attribute, attribute) ||
                other.attribute == attribute) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.explicit, explicit) ||
                other.explicit == explicit) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode => Object.hash(runtimeType, term, country, attribute, limit,
      language, version, explicit, const DeepCollectionEquality().hash(_items));

  /// Create a copy of PodcastSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastSearchStateImplCopyWith<_$PodcastSearchStateImpl> get copyWith =>
      __$$PodcastSearchStateImplCopyWithImpl<_$PodcastSearchStateImpl>(
          this, _$identity);
}

abstract class _PodcastSearchState implements PodcastSearchState {
  const factory _PodcastSearchState(
      {final String? term,
      final Country? country,
      final Attribute? attribute,
      final int limit,
      final String? language,
      final int version,
      final bool explicit,
      final List<ITunesSearchItem> items}) = _$PodcastSearchStateImpl;

  @override
  String? get term;
  @override
  Country? get country;
  @override
  Attribute? get attribute;
  @override
  int get limit;
  @override
  String? get language;
  @override
  int get version;
  @override
  bool get explicit;
  @override
  List<ITunesSearchItem> get items;

  /// Create a copy of PodcastSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastSearchStateImplCopyWith<_$PodcastSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
