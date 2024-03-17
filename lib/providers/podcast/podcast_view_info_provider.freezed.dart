// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_view_info_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastViewInfoState {
  PodcastViewStats get viewStats => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PodcastViewInfoStateCopyWith<PodcastViewInfoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastViewInfoStateCopyWith<$Res> {
  factory $PodcastViewInfoStateCopyWith(PodcastViewInfoState value,
          $Res Function(PodcastViewInfoState) then) =
      _$PodcastViewInfoStateCopyWithImpl<$Res, PodcastViewInfoState>;
  @useResult
  $Res call({PodcastViewStats viewStats});

  $PodcastViewStatsCopyWith<$Res> get viewStats;
}

/// @nodoc
class _$PodcastViewInfoStateCopyWithImpl<$Res,
        $Val extends PodcastViewInfoState>
    implements $PodcastViewInfoStateCopyWith<$Res> {
  _$PodcastViewInfoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewStats = null,
  }) {
    return _then(_value.copyWith(
      viewStats: null == viewStats
          ? _value.viewStats
          : viewStats // ignore: cast_nullable_to_non_nullable
              as PodcastViewStats,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PodcastViewStatsCopyWith<$Res> get viewStats {
    return $PodcastViewStatsCopyWith<$Res>(_value.viewStats, (value) {
      return _then(_value.copyWith(viewStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PodcastViewInfoStateImplCopyWith<$Res>
    implements $PodcastViewInfoStateCopyWith<$Res> {
  factory _$$PodcastViewInfoStateImplCopyWith(_$PodcastViewInfoStateImpl value,
          $Res Function(_$PodcastViewInfoStateImpl) then) =
      __$$PodcastViewInfoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PodcastViewStats viewStats});

  @override
  $PodcastViewStatsCopyWith<$Res> get viewStats;
}

/// @nodoc
class __$$PodcastViewInfoStateImplCopyWithImpl<$Res>
    extends _$PodcastViewInfoStateCopyWithImpl<$Res, _$PodcastViewInfoStateImpl>
    implements _$$PodcastViewInfoStateImplCopyWith<$Res> {
  __$$PodcastViewInfoStateImplCopyWithImpl(_$PodcastViewInfoStateImpl _value,
      $Res Function(_$PodcastViewInfoStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? viewStats = null,
  }) {
    return _then(_$PodcastViewInfoStateImpl(
      viewStats: null == viewStats
          ? _value.viewStats
          : viewStats // ignore: cast_nullable_to_non_nullable
              as PodcastViewStats,
    ));
  }
}

/// @nodoc

class _$PodcastViewInfoStateImpl implements _PodcastViewInfoState {
  const _$PodcastViewInfoStateImpl({required this.viewStats});

  @override
  final PodcastViewStats viewStats;

  @override
  String toString() {
    return 'PodcastViewInfoState(viewStats: $viewStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastViewInfoStateImpl &&
            (identical(other.viewStats, viewStats) ||
                other.viewStats == viewStats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, viewStats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastViewInfoStateImplCopyWith<_$PodcastViewInfoStateImpl>
      get copyWith =>
          __$$PodcastViewInfoStateImplCopyWithImpl<_$PodcastViewInfoStateImpl>(
              this, _$identity);
}

abstract class _PodcastViewInfoState implements PodcastViewInfoState {
  const factory _PodcastViewInfoState(
      {required final PodcastViewStats viewStats}) = _$PodcastViewInfoStateImpl;

  @override
  PodcastViewStats get viewStats;
  @override
  @JsonKey(ignore: true)
  _$$PodcastViewInfoStateImplCopyWith<_$PodcastViewInfoStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
