// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_list_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SeasonListState {
  List<SeasonPair> get pairs => throw _privateConstructorUsedError;
  SeasonFilterMode get filterMode => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;

  /// Create a copy of SeasonListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonListStateCopyWith<SeasonListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonListStateCopyWith<$Res> {
  factory $SeasonListStateCopyWith(
          SeasonListState value, $Res Function(SeasonListState) then) =
      _$SeasonListStateCopyWithImpl<$Res, SeasonListState>;
  @useResult
  $Res call(
      {List<SeasonPair> pairs, SeasonFilterMode filterMode, bool ascending});
}

/// @nodoc
class _$SeasonListStateCopyWithImpl<$Res, $Val extends SeasonListState>
    implements $SeasonListStateCopyWith<$Res> {
  _$SeasonListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pairs = null,
    Object? filterMode = null,
    Object? ascending = null,
  }) {
    return _then(_value.copyWith(
      pairs: null == pairs
          ? _value.pairs
          : pairs // ignore: cast_nullable_to_non_nullable
              as List<SeasonPair>,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as SeasonFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonListStateImplCopyWith<$Res>
    implements $SeasonListStateCopyWith<$Res> {
  factory _$$SeasonListStateImplCopyWith(_$SeasonListStateImpl value,
          $Res Function(_$SeasonListStateImpl) then) =
      __$$SeasonListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<SeasonPair> pairs, SeasonFilterMode filterMode, bool ascending});
}

/// @nodoc
class __$$SeasonListStateImplCopyWithImpl<$Res>
    extends _$SeasonListStateCopyWithImpl<$Res, _$SeasonListStateImpl>
    implements _$$SeasonListStateImplCopyWith<$Res> {
  __$$SeasonListStateImplCopyWithImpl(
      _$SeasonListStateImpl _value, $Res Function(_$SeasonListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pairs = null,
    Object? filterMode = null,
    Object? ascending = null,
  }) {
    return _then(_$SeasonListStateImpl(
      pairs: null == pairs
          ? _value._pairs
          : pairs // ignore: cast_nullable_to_non_nullable
              as List<SeasonPair>,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as SeasonFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SeasonListStateImpl implements _SeasonListState {
  const _$SeasonListStateImpl(
      {required final List<SeasonPair> pairs,
      required this.filterMode,
      required this.ascending})
      : _pairs = pairs;

  final List<SeasonPair> _pairs;
  @override
  List<SeasonPair> get pairs {
    if (_pairs is EqualUnmodifiableListView) return _pairs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pairs);
  }

  @override
  final SeasonFilterMode filterMode;
  @override
  final bool ascending;

  @override
  String toString() {
    return 'SeasonListState(pairs: $pairs, filterMode: $filterMode, ascending: $ascending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonListStateImpl &&
            const DeepCollectionEquality().equals(other._pairs, _pairs) &&
            (identical(other.filterMode, filterMode) ||
                other.filterMode == filterMode) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_pairs), filterMode, ascending);

  /// Create a copy of SeasonListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonListStateImplCopyWith<_$SeasonListStateImpl> get copyWith =>
      __$$SeasonListStateImplCopyWithImpl<_$SeasonListStateImpl>(
          this, _$identity);
}

abstract class _SeasonListState implements SeasonListState {
  const factory _SeasonListState(
      {required final List<SeasonPair> pairs,
      required final SeasonFilterMode filterMode,
      required final bool ascending}) = _$SeasonListStateImpl;

  @override
  List<SeasonPair> get pairs;
  @override
  SeasonFilterMode get filterMode;
  @override
  bool get ascending;

  /// Create a copy of SeasonListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonListStateImplCopyWith<_$SeasonListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
