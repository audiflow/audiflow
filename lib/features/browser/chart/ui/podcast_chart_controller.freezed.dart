// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_chart_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PodcastChartState {
  String? get genre => throw _privateConstructorUsedError;
  Country get chartCountry => throw _privateConstructorUsedError;
  List<Country> get chartCountries => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  List<ITunesChartItem> get chartItems => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Create a copy of PodcastChartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      {String? genre,
      Country chartCountry,
      List<Country> chartCountries,
      int size,
      List<ITunesChartItem> chartItems,
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

  /// Create a copy of PodcastChartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? genre = freezed,
    Object? chartCountry = null,
    Object? chartCountries = null,
    Object? size = null,
    Object? chartItems = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      chartCountry: null == chartCountry
          ? _value.chartCountry
          : chartCountry // ignore: cast_nullable_to_non_nullable
              as Country,
      chartCountries: null == chartCountries
          ? _value.chartCountries
          : chartCountries // ignore: cast_nullable_to_non_nullable
              as List<Country>,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      chartItems: null == chartItems
          ? _value.chartItems
          : chartItems // ignore: cast_nullable_to_non_nullable
              as List<ITunesChartItem>,
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
      {String? genre,
      Country chartCountry,
      List<Country> chartCountries,
      int size,
      List<ITunesChartItem> chartItems,
      DateTime? expiresAt});
}

/// @nodoc
class __$$PodcastChartStateImplCopyWithImpl<$Res>
    extends _$PodcastChartStateCopyWithImpl<$Res, _$PodcastChartStateImpl>
    implements _$$PodcastChartStateImplCopyWith<$Res> {
  __$$PodcastChartStateImplCopyWithImpl(_$PodcastChartStateImpl _value,
      $Res Function(_$PodcastChartStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PodcastChartState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? genre = freezed,
    Object? chartCountry = null,
    Object? chartCountries = null,
    Object? size = null,
    Object? chartItems = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PodcastChartStateImpl(
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      chartCountry: null == chartCountry
          ? _value.chartCountry
          : chartCountry // ignore: cast_nullable_to_non_nullable
              as Country,
      chartCountries: null == chartCountries
          ? _value._chartCountries
          : chartCountries // ignore: cast_nullable_to_non_nullable
              as List<Country>,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      chartItems: null == chartItems
          ? _value._chartItems
          : chartItems // ignore: cast_nullable_to_non_nullable
              as List<ITunesChartItem>,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$PodcastChartStateImpl implements _PodcastChartState {
  const _$PodcastChartStateImpl(
      {this.genre,
      this.chartCountry = Country.none,
      final List<Country> chartCountries = const <Country>[],
      required this.size,
      final List<ITunesChartItem> chartItems = const [],
      this.expiresAt})
      : _chartCountries = chartCountries,
        _chartItems = chartItems;

  @override
  final String? genre;
  @override
  @JsonKey()
  final Country chartCountry;
  final List<Country> _chartCountries;
  @override
  @JsonKey()
  List<Country> get chartCountries {
    if (_chartCountries is EqualUnmodifiableListView) return _chartCountries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chartCountries);
  }

  @override
  final int size;
  final List<ITunesChartItem> _chartItems;
  @override
  @JsonKey()
  List<ITunesChartItem> get chartItems {
    if (_chartItems is EqualUnmodifiableListView) return _chartItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chartItems);
  }

  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'PodcastChartState(genre: $genre, chartCountry: $chartCountry, chartCountries: $chartCountries, size: $size, chartItems: $chartItems, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastChartStateImpl &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.chartCountry, chartCountry) ||
                other.chartCountry == chartCountry) &&
            const DeepCollectionEquality()
                .equals(other._chartCountries, _chartCountries) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality()
                .equals(other._chartItems, _chartItems) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      genre,
      chartCountry,
      const DeepCollectionEquality().hash(_chartCountries),
      size,
      const DeepCollectionEquality().hash(_chartItems),
      expiresAt);

  /// Create a copy of PodcastChartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastChartStateImplCopyWith<_$PodcastChartStateImpl> get copyWith =>
      __$$PodcastChartStateImplCopyWithImpl<_$PodcastChartStateImpl>(
          this, _$identity);
}

abstract class _PodcastChartState implements PodcastChartState {
  const factory _PodcastChartState(
      {final String? genre,
      final Country chartCountry,
      final List<Country> chartCountries,
      required final int size,
      final List<ITunesChartItem> chartItems,
      final DateTime? expiresAt}) = _$PodcastChartStateImpl;

  @override
  String? get genre;
  @override
  Country get chartCountry;
  @override
  List<Country> get chartCountries;
  @override
  int get size;
  @override
  List<ITunesChartItem> get chartItems;
  @override
  DateTime? get expiresAt;

  /// Create a copy of PodcastChartState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PodcastChartStateImplCopyWith<_$PodcastChartStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
