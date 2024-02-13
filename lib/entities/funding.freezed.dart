// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'funding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Funding _$FundingFromJson(Map<String, dynamic> json) {
  return _Funding.fromJson(json);
}

/// @nodoc
mixin _$Funding {
  /// The URL to the funding/donation/information page.
  String get url => throw _privateConstructorUsedError;

  /// The label for the link which will be presented to the user.
  String get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FundingCopyWith<Funding> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FundingCopyWith<$Res> {
  factory $FundingCopyWith(Funding value, $Res Function(Funding) then) =
      _$FundingCopyWithImpl<$Res, Funding>;
  @useResult
  $Res call({String url, String value});
}

/// @nodoc
class _$FundingCopyWithImpl<$Res, $Val extends Funding>
    implements $FundingCopyWith<$Res> {
  _$FundingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FundingImplCopyWith<$Res> implements $FundingCopyWith<$Res> {
  factory _$$FundingImplCopyWith(
          _$FundingImpl value, $Res Function(_$FundingImpl) then) =
      __$$FundingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String value});
}

/// @nodoc
class __$$FundingImplCopyWithImpl<$Res>
    extends _$FundingCopyWithImpl<$Res, _$FundingImpl>
    implements _$$FundingImplCopyWith<$Res> {
  __$$FundingImplCopyWithImpl(
      _$FundingImpl _value, $Res Function(_$FundingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? value = null,
  }) {
    return _then(_$FundingImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FundingImpl implements _Funding {
  const _$FundingImpl({required this.url, required this.value});

  factory _$FundingImpl.fromJson(Map<String, dynamic> json) =>
      _$$FundingImplFromJson(json);

  /// The URL to the funding/donation/information page.
  @override
  final String url;

  /// The label for the link which will be presented to the user.
  @override
  final String value;

  @override
  String toString() {
    return 'Funding(url: $url, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FundingImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, url, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FundingImplCopyWith<_$FundingImpl> get copyWith =>
      __$$FundingImplCopyWithImpl<_$FundingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FundingImplToJson(
      this,
    );
  }
}

abstract class _Funding implements Funding {
  const factory _Funding(
      {required final String url, required final String value}) = _$FundingImpl;

  factory _Funding.fromJson(Map<String, dynamic> json) = _$FundingImpl.fromJson;

  @override

  /// The URL to the funding/donation/information page.
  String get url;
  @override

  /// The label for the link which will be presented to the user.
  String get value;
  @override
  @JsonKey(ignore: true)
  _$$FundingImplCopyWith<_$FundingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
