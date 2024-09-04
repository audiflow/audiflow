// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_episodes_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EpisodeListState {
  int get pid => throw _privateConstructorUsedError;
  EpisodeFilterMode get filterMode => throw _privateConstructorUsedError;
  bool get ascending => throw _privateConstructorUsedError;
  int get episodesPerPage => throw _privateConstructorUsedError;
  int get totalEpisodes => throw _privateConstructorUsedError;

  /// Create a copy of EpisodeListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodeListStateCopyWith<EpisodeListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeListStateCopyWith<$Res> {
  factory $EpisodeListStateCopyWith(
          EpisodeListState value, $Res Function(EpisodeListState) then) =
      _$EpisodeListStateCopyWithImpl<$Res, EpisodeListState>;
  @useResult
  $Res call(
      {int pid,
      EpisodeFilterMode filterMode,
      bool ascending,
      int episodesPerPage,
      int totalEpisodes});
}

/// @nodoc
class _$EpisodeListStateCopyWithImpl<$Res, $Val extends EpisodeListState>
    implements $EpisodeListStateCopyWith<$Res> {
  _$EpisodeListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EpisodeListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pid = null,
    Object? filterMode = null,
    Object? ascending = null,
    Object? episodesPerPage = null,
    Object? totalEpisodes = null,
  }) {
    return _then(_value.copyWith(
      pid: null == pid
          ? _value.pid
          : pid // ignore: cast_nullable_to_non_nullable
              as int,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
      episodesPerPage: null == episodesPerPage
          ? _value.episodesPerPage
          : episodesPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalEpisodes: null == totalEpisodes
          ? _value.totalEpisodes
          : totalEpisodes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EpisodeListStateImplCopyWith<$Res>
    implements $EpisodeListStateCopyWith<$Res> {
  factory _$$EpisodeListStateImplCopyWith(_$EpisodeListStateImpl value,
          $Res Function(_$EpisodeListStateImpl) then) =
      __$$EpisodeListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int pid,
      EpisodeFilterMode filterMode,
      bool ascending,
      int episodesPerPage,
      int totalEpisodes});
}

/// @nodoc
class __$$EpisodeListStateImplCopyWithImpl<$Res>
    extends _$EpisodeListStateCopyWithImpl<$Res, _$EpisodeListStateImpl>
    implements _$$EpisodeListStateImplCopyWith<$Res> {
  __$$EpisodeListStateImplCopyWithImpl(_$EpisodeListStateImpl _value,
      $Res Function(_$EpisodeListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EpisodeListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pid = null,
    Object? filterMode = null,
    Object? ascending = null,
    Object? episodesPerPage = null,
    Object? totalEpisodes = null,
  }) {
    return _then(_$EpisodeListStateImpl(
      pid: null == pid
          ? _value.pid
          : pid // ignore: cast_nullable_to_non_nullable
              as int,
      filterMode: null == filterMode
          ? _value.filterMode
          : filterMode // ignore: cast_nullable_to_non_nullable
              as EpisodeFilterMode,
      ascending: null == ascending
          ? _value.ascending
          : ascending // ignore: cast_nullable_to_non_nullable
              as bool,
      episodesPerPage: null == episodesPerPage
          ? _value.episodesPerPage
          : episodesPerPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalEpisodes: null == totalEpisodes
          ? _value.totalEpisodes
          : totalEpisodes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$EpisodeListStateImpl
    with DiagnosticableTreeMixin
    implements _EpisodeListState {
  const _$EpisodeListStateImpl(
      {required this.pid,
      required this.filterMode,
      required this.ascending,
      required this.episodesPerPage,
      required this.totalEpisodes});

  @override
  final int pid;
  @override
  final EpisodeFilterMode filterMode;
  @override
  final bool ascending;
  @override
  final int episodesPerPage;
  @override
  final int totalEpisodes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EpisodeListState(pid: $pid, filterMode: $filterMode, ascending: $ascending, episodesPerPage: $episodesPerPage, totalEpisodes: $totalEpisodes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EpisodeListState'))
      ..add(DiagnosticsProperty('pid', pid))
      ..add(DiagnosticsProperty('filterMode', filterMode))
      ..add(DiagnosticsProperty('ascending', ascending))
      ..add(DiagnosticsProperty('episodesPerPage', episodesPerPage))
      ..add(DiagnosticsProperty('totalEpisodes', totalEpisodes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeListStateImpl &&
            (identical(other.pid, pid) || other.pid == pid) &&
            (identical(other.filterMode, filterMode) ||
                other.filterMode == filterMode) &&
            (identical(other.ascending, ascending) ||
                other.ascending == ascending) &&
            (identical(other.episodesPerPage, episodesPerPage) ||
                other.episodesPerPage == episodesPerPage) &&
            (identical(other.totalEpisodes, totalEpisodes) ||
                other.totalEpisodes == totalEpisodes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, pid, filterMode, ascending, episodesPerPage, totalEpisodes);

  /// Create a copy of EpisodeListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeListStateImplCopyWith<_$EpisodeListStateImpl> get copyWith =>
      __$$EpisodeListStateImplCopyWithImpl<_$EpisodeListStateImpl>(
          this, _$identity);
}

abstract class _EpisodeListState implements EpisodeListState {
  const factory _EpisodeListState(
      {required final int pid,
      required final EpisodeFilterMode filterMode,
      required final bool ascending,
      required final int episodesPerPage,
      required final int totalEpisodes}) = _$EpisodeListStateImpl;

  @override
  int get pid;
  @override
  EpisodeFilterMode get filterMode;
  @override
  bool get ascending;
  @override
  int get episodesPerPage;
  @override
  int get totalEpisodes;

  /// Create a copy of EpisodeListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodeListStateImplCopyWith<_$EpisodeListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
