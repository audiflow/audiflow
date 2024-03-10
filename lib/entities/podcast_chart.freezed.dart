// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_chart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PodcastChartState _$PodcastChartStateFromJson(Map<String, dynamic> json) {
  return _PodcastChartState.fromJson(json);
}

/// @nodoc
mixin _$PodcastChartState {
  int? get size => throw _privateConstructorUsedError;
  String? get genre => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  List<PodcastMetadata> get podcasts => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastChartStateCopyWith<PodcastChartState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastChartStateCopyWith<$Res> {
  factory $PodcastChartStateCopyWith(
          PodcastChartState value, $Res Function(PodcastChartState) then) =
      _$PodcastChartStateCopyWithImpl<$Res, PodcastChartState>;
  @useResult
  $Res call(
      {int? size,
      String? genre,
      String? countryCode,
      List<PodcastMetadata> podcasts,
      DateTime? expiresAt});
}

/// @nodoc
class _$PodcastChartStateCopyWithImpl<$Res, $Val extends PodcastChartState>
    implements $PodcastChartStateCopyWith<$Res> {
  _$PodcastChartStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = freezed,
    Object? genre = freezed,
    Object? countryCode = freezed,
    Object? podcasts = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      podcasts: null == podcasts
          ? _value.podcasts
          : podcasts // ignore: cast_nullable_to_non_nullable
              as List<PodcastMetadata>,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastChartStateImplCopyWith<$Res>
    implements $PodcastChartStateCopyWith<$Res> {
  factory _$$PodcastChartStateImplCopyWith(_$PodcastChartStateImpl value,
          $Res Function(_$PodcastChartStateImpl) then) =
      __$$PodcastChartStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? size,
      String? genre,
      String? countryCode,
      List<PodcastMetadata> podcasts,
      DateTime? expiresAt});
}

/// @nodoc
class __$$PodcastChartStateImplCopyWithImpl<$Res>
    extends _$PodcastChartStateCopyWithImpl<$Res, _$PodcastChartStateImpl>
    implements _$$PodcastChartStateImplCopyWith<$Res> {
  __$$PodcastChartStateImplCopyWithImpl(_$PodcastChartStateImpl _value,
      $Res Function(_$PodcastChartStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = freezed,
    Object? genre = freezed,
    Object? countryCode = freezed,
    Object? podcasts = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PodcastChartStateImpl(
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      countryCode: freezed == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      podcasts: null == podcasts
          ? _value._podcasts
          : podcasts // ignore: cast_nullable_to_non_nullable
              as List<PodcastMetadata>,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastChartStateImpl implements _PodcastChartState {
  const _$PodcastChartStateImpl(
      {this.size,
      this.genre,
      this.countryCode,
      final List<PodcastMetadata> podcasts = const [],
      this.expiresAt})
      : _podcasts = podcasts;

  factory _$PodcastChartStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastChartStateImplFromJson(json);

  @override
  final int? size;
  @override
  final String? genre;
  @override
  final String? countryCode;
  final List<PodcastMetadata> _podcasts;
  @override
  @JsonKey()
  List<PodcastMetadata> get podcasts {
    if (_podcasts is EqualUnmodifiableListView) return _podcasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_podcasts);
  }

  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'PodcastChartState(size: $size, genre: $genre, countryCode: $countryCode, podcasts: $podcasts, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastChartStateImpl &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            const DeepCollectionEquality().equals(other._podcasts, _podcasts) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, size, genre, countryCode,
      const DeepCollectionEquality().hash(_podcasts), expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastChartStateImplCopyWith<_$PodcastChartStateImpl> get copyWith =>
      __$$PodcastChartStateImplCopyWithImpl<_$PodcastChartStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastChartStateImplToJson(
      this,
    );
  }
}

abstract class _PodcastChartState implements PodcastChartState {
  const factory _PodcastChartState(
      {final int? size,
      final String? genre,
      final String? countryCode,
      final List<PodcastMetadata> podcasts,
      final DateTime? expiresAt}) = _$PodcastChartStateImpl;

  factory _PodcastChartState.fromJson(Map<String, dynamic> json) =
      _$PodcastChartStateImpl.fromJson;

  @override
  int? get size;
  @override
  String? get genre;
  @override
  String? get countryCode;
  @override
  List<PodcastMetadata> get podcasts;
  @override
  DateTime? get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$PodcastChartStateImplCopyWith<_$PodcastChartStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
