// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastSearchState {
  String get term => throw _privateConstructorUsedError;
  List<PodcastSearchResultItem> get results =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastSearchStateCopyWith<PodcastSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastSearchStateCopyWith<$Res> {
  factory $PodcastSearchStateCopyWith(
          PodcastSearchState value, $Res Function(PodcastSearchState) then) =
      _$PodcastSearchStateCopyWithImpl<$Res, PodcastSearchState>;
  @useResult
  $Res call({String term, List<PodcastSearchResultItem> results});
}

/// @nodoc
class _$PodcastSearchStateCopyWithImpl<$Res, $Val extends PodcastSearchState>
    implements $PodcastSearchStateCopyWith<$Res> {
  _$PodcastSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = null,
    Object? results = null,
  }) {
    return _then(_value.copyWith(
      term: null == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PodcastSearchResultItem>,
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
  $Res call({String term, List<PodcastSearchResultItem> results});
}

/// @nodoc
class __$$PodcastSearchStateImplCopyWithImpl<$Res>
    extends _$PodcastSearchStateCopyWithImpl<$Res, _$PodcastSearchStateImpl>
    implements _$$PodcastSearchStateImplCopyWith<$Res> {
  __$$PodcastSearchStateImplCopyWithImpl(_$PodcastSearchStateImpl _value,
      $Res Function(_$PodcastSearchStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? term = null,
    Object? results = null,
  }) {
    return _then(_$PodcastSearchStateImpl(
      term: null == term
          ? _value.term
          : term // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PodcastSearchResultItem>,
    ));
  }
}

/// @nodoc

class _$PodcastSearchStateImpl implements _PodcastSearchState {
  const _$PodcastSearchStateImpl(
      {this.term = '', final List<PodcastSearchResultItem> results = const []})
      : _results = results;

  @override
  @JsonKey()
  final String term;
  final List<PodcastSearchResultItem> _results;
  @override
  @JsonKey()
  List<PodcastSearchResultItem> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'PodcastSearchState(term: $term, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastSearchStateImpl &&
            (identical(other.term, term) || other.term == term) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, term, const DeepCollectionEquality().hash(_results));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastSearchStateImplCopyWith<_$PodcastSearchStateImpl> get copyWith =>
      __$$PodcastSearchStateImplCopyWithImpl<_$PodcastSearchStateImpl>(
          this, _$identity);
}

abstract class _PodcastSearchState implements PodcastSearchState {
  const factory _PodcastSearchState(
      {final String term,
      final List<PodcastSearchResultItem> results}) = _$PodcastSearchStateImpl;

  @override
  String get term;
  @override
  List<PodcastSearchResultItem> get results;
  @override
  @JsonKey(ignore: true)
  _$$PodcastSearchStateImplCopyWith<_$PodcastSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
