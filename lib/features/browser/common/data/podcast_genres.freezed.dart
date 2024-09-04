// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_genres.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastGenresState {
  List<String> get categories => throw _privateConstructorUsedError;
  List<String> get intlCategories => throw _privateConstructorUsedError;
  List<String> get intlCategoriesSorted => throw _privateConstructorUsedError;

  /// Create a copy of PodcastGenresState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PodcastGenresStateCopyWith<PodcastGenresState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastGenresStateCopyWith<$Res> {
  factory $PodcastGenresStateCopyWith(
          PodcastGenresState value, $Res Function(PodcastGenresState) then) =
      _$PodcastGenresStateCopyWithImpl<$Res, PodcastGenresState>;
  @useResult
  $Res call(
      {List<String> categories,
      List<String> intlCategories,
      List<String> intlCategoriesSorted});
}

/// @nodoc
class _$PodcastGenresStateCopyWithImpl<$Res, $Val extends PodcastGenresState>
    implements $PodcastGenresStateCopyWith<$Res> {
  _$PodcastGenresStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PodcastGenresState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? intlCategories = null,
    Object? intlCategoriesSorted = null,
  }) {
    return _then(_value.copyWith(
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      intlCategories: null == intlCategories
          ? _value.intlCategories
          : intlCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      intlCategoriesSorted: null == intlCategoriesSorted
          ? _value.intlCategoriesSorted
          : intlCategoriesSorted // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastGenresStateImplCopyWith<$Res>
    implements $PodcastGenresStateCopyWith<$Res> {
  factory _$$PodcastGenresStateImplCopyWith(_$PodcastGenresStateImpl value,
          $Res Function(_$PodcastGenresStateImpl) then) =
      __$$PodcastGenresStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> categories,
      List<String> intlCategories,
      List<String> intlCategoriesSorted});
}

/// @nodoc
class __$$PodcastGenresStateImplCopyWithImpl<$Res>
    extends _$PodcastGenresStateCopyWithImpl<$Res, _$PodcastGenresStateImpl>
    implements _$$PodcastGenresStateImplCopyWith<$Res> {
  __$$PodcastGenresStateImplCopyWithImpl(_$PodcastGenresStateImpl _value,
      $Res Function(_$PodcastGenresStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastGenresState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? intlCategories = null,
    Object? intlCategoriesSorted = null,
  }) {
    return _then(_$PodcastGenresStateImpl(
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      intlCategories: null == intlCategories
          ? _value._intlCategories
          : intlCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      intlCategoriesSorted: null == intlCategoriesSorted
          ? _value._intlCategoriesSorted
          : intlCategoriesSorted // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$PodcastGenresStateImpl implements _PodcastGenresState {
  const _$PodcastGenresStateImpl(
      {final List<String> categories = const [],
      final List<String> intlCategories = const [],
      final List<String> intlCategoriesSorted = const []})
      : _categories = categories,
        _intlCategories = intlCategories,
        _intlCategoriesSorted = intlCategoriesSorted;

  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<String> _intlCategories;
  @override
  @JsonKey()
  List<String> get intlCategories {
    if (_intlCategories is EqualUnmodifiableListView) return _intlCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_intlCategories);
  }

  final List<String> _intlCategoriesSorted;
  @override
  @JsonKey()
  List<String> get intlCategoriesSorted {
    if (_intlCategoriesSorted is EqualUnmodifiableListView)
      return _intlCategoriesSorted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_intlCategoriesSorted);
  }

  @override
  String toString() {
    return 'PodcastGenresState(categories: $categories, intlCategories: $intlCategories, intlCategoriesSorted: $intlCategoriesSorted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastGenresStateImpl &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._intlCategories, _intlCategories) &&
            const DeepCollectionEquality()
                .equals(other._intlCategoriesSorted, _intlCategoriesSorted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_intlCategories),
      const DeepCollectionEquality().hash(_intlCategoriesSorted));

  /// Create a copy of PodcastGenresState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastGenresStateImplCopyWith<_$PodcastGenresStateImpl> get copyWith =>
      __$$PodcastGenresStateImplCopyWithImpl<_$PodcastGenresStateImpl>(
          this, _$identity);
}

abstract class _PodcastGenresState implements PodcastGenresState {
  const factory _PodcastGenresState(
      {final List<String> categories,
      final List<String> intlCategories,
      final List<String> intlCategoriesSorted}) = _$PodcastGenresStateImpl;

  @override
  List<String> get categories;
  @override
  List<String> get intlCategories;
  @override
  List<String> get intlCategoriesSorted;

  /// Create a copy of PodcastGenresState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastGenresStateImplCopyWith<_$PodcastGenresStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
