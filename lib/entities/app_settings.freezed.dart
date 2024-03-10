// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) {
  return _AppSettings.fromJson(json);
}

/// @nodoc
mixin _$AppSettings {
  /// The current theme name.
  BrightnessMode get theme => throw _privateConstructorUsedError;

  /// True if episodes are marked as played when deleted.
  bool get markDeletedEpisodesAsPlayed => throw _privateConstructorUsedError;

  /// True if downloads should be saved to the SD card.
  bool get storeDownloadsSDCard => throw _privateConstructorUsedError;

  /// The default playback speed.
  double get playbackSpeed => throw _privateConstructorUsedError;

  /// The search provider: itunes or podcastindex.
  String? get searchProvider => throw _privateConstructorUsedError;

  /// List of search providers: currently itunes or podcastindex.
  List<SearchProvider> get searchProviders =>
      throw _privateConstructorUsedError;

  /// True if the user has confirmed dialog accepting funding links.
  bool get externalLinkConsent => throw _privateConstructorUsedError;

  /// If true the main player window will open as soon as an episode starts.
  bool get autoOpenNowPlaying => throw _privateConstructorUsedError;

  /// If true the funding link icon will appear (if the podcast supports it).
  bool get showFunding => throw _privateConstructorUsedError;

  /// If -1 never; 0 always; otherwise time in minutes.
  int get autoUpdateEpisodePeriod => throw _privateConstructorUsedError;

  /// If true, silence in audio playback is trimmed. Currently Android only.
  bool get trimSilence => throw _privateConstructorUsedError;

  /// If true, volume is boosted. Currently Android only.
  bool get volumeBoost => throw _privateConstructorUsedError;

  /// If 0, list view; else grid view
  int get layout => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {BrightnessMode theme,
      bool markDeletedEpisodesAsPlayed,
      bool storeDownloadsSDCard,
      double playbackSpeed,
      String? searchProvider,
      List<SearchProvider> searchProviders,
      bool externalLinkConsent,
      bool autoOpenNowPlaying,
      bool showFunding,
      int autoUpdateEpisodePeriod,
      bool trimSilence,
      bool volumeBoost,
      int layout});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? markDeletedEpisodesAsPlayed = null,
    Object? storeDownloadsSDCard = null,
    Object? playbackSpeed = null,
    Object? searchProvider = freezed,
    Object? searchProviders = null,
    Object? externalLinkConsent = null,
    Object? autoOpenNowPlaying = null,
    Object? showFunding = null,
    Object? autoUpdateEpisodePeriod = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
    Object? layout = null,
  }) {
    return _then(_value.copyWith(
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as BrightnessMode,
      markDeletedEpisodesAsPlayed: null == markDeletedEpisodesAsPlayed
          ? _value.markDeletedEpisodesAsPlayed
          : markDeletedEpisodesAsPlayed // ignore: cast_nullable_to_non_nullable
              as bool,
      storeDownloadsSDCard: null == storeDownloadsSDCard
          ? _value.storeDownloadsSDCard
          : storeDownloadsSDCard // ignore: cast_nullable_to_non_nullable
              as bool,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      searchProvider: freezed == searchProvider
          ? _value.searchProvider
          : searchProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      searchProviders: null == searchProviders
          ? _value.searchProviders
          : searchProviders // ignore: cast_nullable_to_non_nullable
              as List<SearchProvider>,
      externalLinkConsent: null == externalLinkConsent
          ? _value.externalLinkConsent
          : externalLinkConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      autoOpenNowPlaying: null == autoOpenNowPlaying
          ? _value.autoOpenNowPlaying
          : autoOpenNowPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      showFunding: null == showFunding
          ? _value.showFunding
          : showFunding // ignore: cast_nullable_to_non_nullable
              as bool,
      autoUpdateEpisodePeriod: null == autoUpdateEpisodePeriod
          ? _value.autoUpdateEpisodePeriod
          : autoUpdateEpisodePeriod // ignore: cast_nullable_to_non_nullable
              as int,
      trimSilence: null == trimSilence
          ? _value.trimSilence
          : trimSilence // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeBoost: null == volumeBoost
          ? _value.volumeBoost
          : volumeBoost // ignore: cast_nullable_to_non_nullable
              as bool,
      layout: null == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BrightnessMode theme,
      bool markDeletedEpisodesAsPlayed,
      bool storeDownloadsSDCard,
      double playbackSpeed,
      String? searchProvider,
      List<SearchProvider> searchProviders,
      bool externalLinkConsent,
      bool autoOpenNowPlaying,
      bool showFunding,
      int autoUpdateEpisodePeriod,
      bool trimSilence,
      bool volumeBoost,
      int layout});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? theme = null,
    Object? markDeletedEpisodesAsPlayed = null,
    Object? storeDownloadsSDCard = null,
    Object? playbackSpeed = null,
    Object? searchProvider = freezed,
    Object? searchProviders = null,
    Object? externalLinkConsent = null,
    Object? autoOpenNowPlaying = null,
    Object? showFunding = null,
    Object? autoUpdateEpisodePeriod = null,
    Object? trimSilence = null,
    Object? volumeBoost = null,
    Object? layout = null,
  }) {
    return _then(_$AppSettingsImpl(
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as BrightnessMode,
      markDeletedEpisodesAsPlayed: null == markDeletedEpisodesAsPlayed
          ? _value.markDeletedEpisodesAsPlayed
          : markDeletedEpisodesAsPlayed // ignore: cast_nullable_to_non_nullable
              as bool,
      storeDownloadsSDCard: null == storeDownloadsSDCard
          ? _value.storeDownloadsSDCard
          : storeDownloadsSDCard // ignore: cast_nullable_to_non_nullable
              as bool,
      playbackSpeed: null == playbackSpeed
          ? _value.playbackSpeed
          : playbackSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      searchProvider: freezed == searchProvider
          ? _value.searchProvider
          : searchProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      searchProviders: null == searchProviders
          ? _value._searchProviders
          : searchProviders // ignore: cast_nullable_to_non_nullable
              as List<SearchProvider>,
      externalLinkConsent: null == externalLinkConsent
          ? _value.externalLinkConsent
          : externalLinkConsent // ignore: cast_nullable_to_non_nullable
              as bool,
      autoOpenNowPlaying: null == autoOpenNowPlaying
          ? _value.autoOpenNowPlaying
          : autoOpenNowPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      showFunding: null == showFunding
          ? _value.showFunding
          : showFunding // ignore: cast_nullable_to_non_nullable
              as bool,
      autoUpdateEpisodePeriod: null == autoUpdateEpisodePeriod
          ? _value.autoUpdateEpisodePeriod
          : autoUpdateEpisodePeriod // ignore: cast_nullable_to_non_nullable
              as int,
      trimSilence: null == trimSilence
          ? _value.trimSilence
          : trimSilence // ignore: cast_nullable_to_non_nullable
              as bool,
      volumeBoost: null == volumeBoost
          ? _value.volumeBoost
          : volumeBoost // ignore: cast_nullable_to_non_nullable
              as bool,
      layout: null == layout
          ? _value.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {required this.theme,
      required this.markDeletedEpisodesAsPlayed,
      required this.storeDownloadsSDCard,
      required this.playbackSpeed,
      required this.searchProvider,
      required final List<SearchProvider> searchProviders,
      required this.externalLinkConsent,
      required this.autoOpenNowPlaying,
      required this.showFunding,
      required this.autoUpdateEpisodePeriod,
      required this.trimSilence,
      required this.volumeBoost,
      required this.layout})
      : _searchProviders = searchProviders;

  factory _$AppSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsImplFromJson(json);

  /// The current theme name.
  @override
  final BrightnessMode theme;

  /// True if episodes are marked as played when deleted.
  @override
  final bool markDeletedEpisodesAsPlayed;

  /// True if downloads should be saved to the SD card.
  @override
  final bool storeDownloadsSDCard;

  /// The default playback speed.
  @override
  final double playbackSpeed;

  /// The search provider: itunes or podcastindex.
  @override
  final String? searchProvider;

  /// List of search providers: currently itunes or podcastindex.
  final List<SearchProvider> _searchProviders;

  /// List of search providers: currently itunes or podcastindex.
  @override
  List<SearchProvider> get searchProviders {
    if (_searchProviders is EqualUnmodifiableListView) return _searchProviders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchProviders);
  }

  /// True if the user has confirmed dialog accepting funding links.
  @override
  final bool externalLinkConsent;

  /// If true the main player window will open as soon as an episode starts.
  @override
  final bool autoOpenNowPlaying;

  /// If true the funding link icon will appear (if the podcast supports it).
  @override
  final bool showFunding;

  /// If -1 never; 0 always; otherwise time in minutes.
  @override
  final int autoUpdateEpisodePeriod;

  /// If true, silence in audio playback is trimmed. Currently Android only.
  @override
  final bool trimSilence;

  /// If true, volume is boosted. Currently Android only.
  @override
  final bool volumeBoost;

  /// If 0, list view; else grid view
  @override
  final int layout;

  @override
  String toString() {
    return 'AppSettings(theme: $theme, markDeletedEpisodesAsPlayed: $markDeletedEpisodesAsPlayed, storeDownloadsSDCard: $storeDownloadsSDCard, playbackSpeed: $playbackSpeed, searchProvider: $searchProvider, searchProviders: $searchProviders, externalLinkConsent: $externalLinkConsent, autoOpenNowPlaying: $autoOpenNowPlaying, showFunding: $showFunding, autoUpdateEpisodePeriod: $autoUpdateEpisodePeriod, trimSilence: $trimSilence, volumeBoost: $volumeBoost, layout: $layout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.markDeletedEpisodesAsPlayed,
                    markDeletedEpisodesAsPlayed) ||
                other.markDeletedEpisodesAsPlayed ==
                    markDeletedEpisodesAsPlayed) &&
            (identical(other.storeDownloadsSDCard, storeDownloadsSDCard) ||
                other.storeDownloadsSDCard == storeDownloadsSDCard) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.searchProvider, searchProvider) ||
                other.searchProvider == searchProvider) &&
            const DeepCollectionEquality()
                .equals(other._searchProviders, _searchProviders) &&
            (identical(other.externalLinkConsent, externalLinkConsent) ||
                other.externalLinkConsent == externalLinkConsent) &&
            (identical(other.autoOpenNowPlaying, autoOpenNowPlaying) ||
                other.autoOpenNowPlaying == autoOpenNowPlaying) &&
            (identical(other.showFunding, showFunding) ||
                other.showFunding == showFunding) &&
            (identical(
                    other.autoUpdateEpisodePeriod, autoUpdateEpisodePeriod) ||
                other.autoUpdateEpisodePeriod == autoUpdateEpisodePeriod) &&
            (identical(other.trimSilence, trimSilence) ||
                other.trimSilence == trimSilence) &&
            (identical(other.volumeBoost, volumeBoost) ||
                other.volumeBoost == volumeBoost) &&
            (identical(other.layout, layout) || other.layout == layout));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      theme,
      markDeletedEpisodesAsPlayed,
      storeDownloadsSDCard,
      playbackSpeed,
      searchProvider,
      const DeepCollectionEquality().hash(_searchProviders),
      externalLinkConsent,
      autoOpenNowPlaying,
      showFunding,
      autoUpdateEpisodePeriod,
      trimSilence,
      volumeBoost,
      layout);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsImplToJson(
      this,
    );
  }
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {required final BrightnessMode theme,
      required final bool markDeletedEpisodesAsPlayed,
      required final bool storeDownloadsSDCard,
      required final double playbackSpeed,
      required final String? searchProvider,
      required final List<SearchProvider> searchProviders,
      required final bool externalLinkConsent,
      required final bool autoOpenNowPlaying,
      required final bool showFunding,
      required final int autoUpdateEpisodePeriod,
      required final bool trimSilence,
      required final bool volumeBoost,
      required final int layout}) = _$AppSettingsImpl;

  factory _AppSettings.fromJson(Map<String, dynamic> json) =
      _$AppSettingsImpl.fromJson;

  @override

  /// The current theme name.
  BrightnessMode get theme;
  @override

  /// True if episodes are marked as played when deleted.
  bool get markDeletedEpisodesAsPlayed;
  @override

  /// True if downloads should be saved to the SD card.
  bool get storeDownloadsSDCard;
  @override

  /// The default playback speed.
  double get playbackSpeed;
  @override

  /// The search provider: itunes or podcastindex.
  String? get searchProvider;
  @override

  /// List of search providers: currently itunes or podcastindex.
  List<SearchProvider> get searchProviders;
  @override

  /// True if the user has confirmed dialog accepting funding links.
  bool get externalLinkConsent;
  @override

  /// If true the main player window will open as soon as an episode starts.
  bool get autoOpenNowPlaying;
  @override

  /// If true the funding link icon will appear (if the podcast supports it).
  bool get showFunding;
  @override

  /// If -1 never; 0 always; otherwise time in minutes.
  int get autoUpdateEpisodePeriod;
  @override

  /// If true, silence in audio playback is trimmed. Currently Android only.
  bool get trimSilence;
  @override

  /// If true, volume is boosted. Currently Android only.
  bool get volumeBoost;
  @override

  /// If 0, list view; else grid view
  int get layout;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
