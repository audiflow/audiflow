// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SearchProvider _$SearchProviderFromJson(Map<String, dynamic> json) {
  return _SearchProvider.fromJson(json);
}

/// @nodoc
mixin _$SearchProvider {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SearchProviderCopyWith<SearchProvider> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchProviderCopyWith<$Res> {
  factory $SearchProviderCopyWith(
          SearchProvider value, $Res Function(SearchProvider) then) =
      _$SearchProviderCopyWithImpl<$Res, SearchProvider>;
  @useResult
  $Res call({String key, String name});
}

/// @nodoc
class _$SearchProviderCopyWithImpl<$Res, $Val extends SearchProvider>
    implements $SearchProviderCopyWith<$Res> {
  _$SearchProviderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchProviderImplCopyWith<$Res>
    implements $SearchProviderCopyWith<$Res> {
  factory _$$SearchProviderImplCopyWith(_$SearchProviderImpl value,
          $Res Function(_$SearchProviderImpl) then) =
      __$$SearchProviderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name});
}

/// @nodoc
class __$$SearchProviderImplCopyWithImpl<$Res>
    extends _$SearchProviderCopyWithImpl<$Res, _$SearchProviderImpl>
    implements _$$SearchProviderImplCopyWith<$Res> {
  __$$SearchProviderImplCopyWithImpl(
      _$SearchProviderImpl _value, $Res Function(_$SearchProviderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
  }) {
    return _then(_$SearchProviderImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchProviderImpl implements _SearchProvider {
  const _$SearchProviderImpl({required this.key, required this.name});

  factory _$SearchProviderImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchProviderImplFromJson(json);

  @override
  final String key;
  @override
  final String name;

  @override
  String toString() {
    return 'SearchProvider(key: $key, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchProviderImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, key, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchProviderImplCopyWith<_$SearchProviderImpl> get copyWith =>
      __$$SearchProviderImplCopyWithImpl<_$SearchProviderImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchProviderImplToJson(
      this,
    );
  }
}

abstract class _SearchProvider implements SearchProvider {
  const factory _SearchProvider(
      {required final String key,
      required final String name}) = _$SearchProviderImpl;

  factory _SearchProvider.fromJson(Map<String, dynamic> json) =
      _$SearchProviderImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$SearchProviderImplCopyWith<_$SearchProviderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
