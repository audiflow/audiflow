// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episodes_group_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodesGroupState {
  List<Episode> get episodes => throw _privateConstructorUsedError;

  /// Create a copy of EpisodesGroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodesGroupStateCopyWith<EpisodesGroupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodesGroupStateCopyWith<$Res> {
  factory $EpisodesGroupStateCopyWith(
          EpisodesGroupState value, $Res Function(EpisodesGroupState) then) =
      _$EpisodesGroupStateCopyWithImpl<$Res, EpisodesGroupState>;
  @useResult
  $Res call({List<Episode> episodes});
}

/// @nodoc
class _$EpisodesGroupStateCopyWithImpl<$Res, $Val extends EpisodesGroupState>
    implements $EpisodesGroupStateCopyWith<$Res> {
  _$EpisodesGroupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EpisodesGroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
  }) {
    return _then(_value.copyWith(
      episodes: null == episodes
          ? _value.episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodesGroupStateImplCopyWith<$Res>
    implements $EpisodesGroupStateCopyWith<$Res> {
  factory _$$EpisodesGroupStateImplCopyWith(_$EpisodesGroupStateImpl value,
          $Res Function(_$EpisodesGroupStateImpl) then) =
      __$$EpisodesGroupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Episode> episodes});
}

/// @nodoc
class __$$EpisodesGroupStateImplCopyWithImpl<$Res>
    extends _$EpisodesGroupStateCopyWithImpl<$Res, _$EpisodesGroupStateImpl>
    implements _$$EpisodesGroupStateImplCopyWith<$Res> {
  __$$EpisodesGroupStateImplCopyWithImpl(_$EpisodesGroupStateImpl _value,
      $Res Function(_$EpisodesGroupStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EpisodesGroupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? episodes = null,
  }) {
    return _then(_$EpisodesGroupStateImpl(
      episodes: null == episodes
          ? _value._episodes
          : episodes // ignore: cast_nullable_to_non_nullable
              as List<Episode>,
    ));
  }
}

/// @nodoc

class _$EpisodesGroupStateImpl
    with DiagnosticableTreeMixin
    implements _EpisodesGroupState {
  const _$EpisodesGroupStateImpl({required final List<Episode> episodes})
      : _episodes = episodes;

  final List<Episode> _episodes;
  @override
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodesGroupState(episodes: $episodes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodesGroupState'))
      ..add(DiagnosticsProperty('episodes', episodes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodesGroupStateImpl &&
            const DeepCollectionEquality().equals(other._episodes, _episodes));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_episodes));

  /// Create a copy of EpisodesGroupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodesGroupStateImplCopyWith<_$EpisodesGroupStateImpl> get copyWith =>
      __$$EpisodesGroupStateImplCopyWithImpl<_$EpisodesGroupStateImpl>(
          this, _$identity);
}

abstract class _EpisodesGroupState implements EpisodesGroupState {
  const factory _EpisodesGroupState({required final List<Episode> episodes}) =
      _$EpisodesGroupStateImpl;

  @override
  List<Episode> get episodes;

  /// Create a copy of EpisodesGroupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodesGroupStateImplCopyWith<_$EpisodesGroupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
