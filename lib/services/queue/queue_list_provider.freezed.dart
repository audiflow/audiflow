// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_list_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QueueListState {
  List<Episode> get primary => throw _privateConstructorUsedError;
  List<Episode> get adhoc => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QueueListStateCopyWith<QueueListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueListStateCopyWith<$Res> {
  factory $QueueListStateCopyWith(
          QueueListState value, $Res Function(QueueListState) then) =
      _$QueueListStateCopyWithImpl<$Res, QueueListState>;
  @useResult
  $Res call({List<Episode> primary, List<Episode> adhoc});
}

/// @nodoc
class _$QueueListStateCopyWithImpl<$Res, $Val extends QueueListState>
    implements $QueueListStateCopyWith<$Res> {
  _$QueueListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? adhoc = null,
  }) {
    return _then(_value.copyWith(
      primary: null == primary
          ? _value.primary
          : primary // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      adhoc: null == adhoc
          ? _value.adhoc
          : adhoc // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueListStateImplCopyWith<$Res>
    implements $QueueListStateCopyWith<$Res> {
  factory _$$QueueListStateImplCopyWith(_$QueueListStateImpl value,
          $Res Function(_$QueueListStateImpl) then) =
      __$$QueueListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Episode> primary, List<Episode> adhoc});
}

/// @nodoc
class __$$QueueListStateImplCopyWithImpl<$Res>
    extends _$QueueListStateCopyWithImpl<$Res, _$QueueListStateImpl>
    implements _$$QueueListStateImplCopyWith<$Res> {
  __$$QueueListStateImplCopyWithImpl(
      _$QueueListStateImpl _value, $Res Function(_$QueueListStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primary = null,
    Object? adhoc = null,
  }) {
    return _then(_$QueueListStateImpl(
      primary: null == primary
          ? _value._primary
          : primary // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
      adhoc: null == adhoc
          ? _value._adhoc
          : adhoc // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ));
  }
}

/// @nodoc

class _$QueueListStateImpl implements _QueueListState {
  const _$QueueListStateImpl(
      {final List<Episode> primary = const <Episode>[],
      final List<Episode> adhoc = const <Episode>[]})
      : _primary = primary,
        _adhoc = adhoc;

  final List<Episode> _primary;
  @override
  @JsonKey()
  List<Episode> get primary {
    if (_primary is EqualUnmodifiableListView) return _primary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primary);
  }

  final List<Episode> _adhoc;
  @override
  @JsonKey()
  List<Episode> get adhoc {
    if (_adhoc is EqualUnmodifiableListView) return _adhoc;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_adhoc);
  }

  @override
  String toString() {
    return 'QueueListState(primary: $primary, adhoc: $adhoc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueListStateImpl &&
            const DeepCollectionEquality().equals(other._primary, _primary) &&
            const DeepCollectionEquality().equals(other._adhoc, _adhoc));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_primary),
      const DeepCollectionEquality().hash(_adhoc));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueListStateImplCopyWith<_$QueueListStateImpl> get copyWith =>
      __$$QueueListStateImplCopyWithImpl<_$QueueListStateImpl>(
          this, _$identity);
}

abstract class _QueueListState implements QueueListState {
  const factory _QueueListState(
      {final List<Episode> primary,
      final List<Episode> adhoc}) = _$QueueListStateImpl;

  @override
  List<Episode> get primary;
  @override
  List<Episode> get adhoc;
  @override
  @JsonKey(ignore: true)
  _$$QueueListStateImplCopyWith<_$QueueListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
