// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'podcast_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PodcastSummary _$PodcastSummaryFromJson(Map<String, dynamic> json) {
  return _PodcastSummary.fromJson(json);
}

/// @nodoc
mixin _$PodcastSummary {
  /// Database ID
  int? get id => throw _privateConstructorUsedError;

  /// Unique identifier for podcast.
  String get guid => throw _privateConstructorUsedError;

  /// The link to the podcast RSS feed.
  String get url => throw _privateConstructorUsedError;

  /// Podcast title.
  String get title => throw _privateConstructorUsedError;

  /// URL for thumbnail version of artwork image.
  String get thumbImageUrl => throw _privateConstructorUsedError;

  /// Copyright owner of the podcast.
  String get copyright => throw _privateConstructorUsedError;

  /// Release date of the latest episode.
  DateTime? get releaseDate => throw _privateConstructorUsedError;

  /// Date and time user subscribed to the podcast.
  DateTime? get subscribedDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PodcastSummaryCopyWith<PodcastSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PodcastSummaryCopyWith<$Res> {
  factory $PodcastSummaryCopyWith(
          PodcastSummary value, $Res Function(PodcastSummary) then) =
      _$PodcastSummaryCopyWithImpl<$Res, PodcastSummary>;
  @useResult
  $Res call(
      {int? id,
      String guid,
      String url,
      String title,
      String thumbImageUrl,
      String copyright,
      DateTime? releaseDate,
      DateTime? subscribedDate});
}

/// @nodoc
class _$PodcastSummaryCopyWithImpl<$Res, $Val extends PodcastSummary>
    implements $PodcastSummaryCopyWith<$Res> {
  _$PodcastSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? guid = null,
    Object? url = null,
    Object? title = null,
    Object? thumbImageUrl = null,
    Object? copyright = null,
    Object? releaseDate = freezed,
    Object? subscribedDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PodcastSummaryImplCopyWith<$Res>
    implements $PodcastSummaryCopyWith<$Res> {
  factory _$$PodcastSummaryImplCopyWith(_$PodcastSummaryImpl value,
          $Res Function(_$PodcastSummaryImpl) then) =
      __$$PodcastSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String guid,
      String url,
      String title,
      String thumbImageUrl,
      String copyright,
      DateTime? releaseDate,
      DateTime? subscribedDate});
}

/// @nodoc
class __$$PodcastSummaryImplCopyWithImpl<$Res>
    extends _$PodcastSummaryCopyWithImpl<$Res, _$PodcastSummaryImpl>
    implements _$$PodcastSummaryImplCopyWith<$Res> {
  __$$PodcastSummaryImplCopyWithImpl(
      _$PodcastSummaryImpl _value, $Res Function(_$PodcastSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? guid = null,
    Object? url = null,
    Object? title = null,
    Object? thumbImageUrl = null,
    Object? copyright = null,
    Object? releaseDate = freezed,
    Object? subscribedDate = freezed,
  }) {
    return _then(_$PodcastSummaryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      guid: null == guid
          ? _value.guid
          : guid // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbImageUrl: null == thumbImageUrl
          ? _value.thumbImageUrl
          : thumbImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      copyright: null == copyright
          ? _value.copyright
          : copyright // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscribedDate: freezed == subscribedDate
          ? _value.subscribedDate
          : subscribedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PodcastSummaryImpl implements _PodcastSummary {
  const _$PodcastSummaryImpl(
      {this.id,
      required this.guid,
      required this.url,
      required this.title,
      required this.thumbImageUrl,
      required this.copyright,
      required this.releaseDate,
      this.subscribedDate});

  factory _$PodcastSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PodcastSummaryImplFromJson(json);

  /// Database ID
  @override
  final int? id;

  /// Unique identifier for podcast.
  @override
  final String guid;

  /// The link to the podcast RSS feed.
  @override
  final String url;

  /// Podcast title.
  @override
  final String title;

  /// URL for thumbnail version of artwork image.
  @override
  final String thumbImageUrl;

  /// Copyright owner of the podcast.
  @override
  final String copyright;

  /// Release date of the latest episode.
  @override
  final DateTime? releaseDate;

  /// Date and time user subscribed to the podcast.
  @override
  final DateTime? subscribedDate;

  @override
  String toString() {
    return 'PodcastSummary(id: $id, guid: $guid, url: $url, title: $title, thumbImageUrl: $thumbImageUrl, copyright: $copyright, releaseDate: $releaseDate, subscribedDate: $subscribedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PodcastSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.guid, guid) || other.guid == guid) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbImageUrl, thumbImageUrl) ||
                other.thumbImageUrl == thumbImageUrl) &&
            (identical(other.copyright, copyright) ||
                other.copyright == copyright) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.subscribedDate, subscribedDate) ||
                other.subscribedDate == subscribedDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, guid, url, title,
      thumbImageUrl, copyright, releaseDate, subscribedDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PodcastSummaryImplCopyWith<_$PodcastSummaryImpl> get copyWith =>
      __$$PodcastSummaryImplCopyWithImpl<_$PodcastSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PodcastSummaryImplToJson(
      this,
    );
  }
}

abstract class _PodcastSummary implements PodcastSummary {
  const factory _PodcastSummary(
      {final int? id,
      required final String guid,
      required final String url,
      required final String title,
      required final String thumbImageUrl,
      required final String copyright,
      required final DateTime? releaseDate,
      final DateTime? subscribedDate}) = _$PodcastSummaryImpl;

  factory _PodcastSummary.fromJson(Map<String, dynamic> json) =
      _$PodcastSummaryImpl.fromJson;

  @override

  /// Database ID
  int? get id;
  @override

  /// Unique identifier for podcast.
  String get guid;
  @override

  /// The link to the podcast RSS feed.
  String get url;
  @override

  /// Podcast title.
  String get title;
  @override

  /// URL for thumbnail version of artwork image.
  String get thumbImageUrl;
  @override

  /// Copyright owner of the podcast.
  String get copyright;
  @override

  /// Release date of the latest episode.
  DateTime? get releaseDate;
  @override

  /// Date and time user subscribed to the podcast.
  DateTime? get subscribedDate;
  @override
  @JsonKey(ignore: true)
  _$$PodcastSummaryImplCopyWith<_$PodcastSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
