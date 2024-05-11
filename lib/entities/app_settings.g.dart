// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      streamWarnMobileData: json['streamWarnMobileData'] as bool,
      downloadWarnMobileData: json['downloadWarnMobileData'] as bool,
      autoDownloadOnlyOnWifi: json['autoDownloadOnlyOnWifi'] as bool,
      autoDeleteEpisodes: json['autoDeleteEpisodes'] as bool,
      theme: $enumDecode(_$BrightnessModeEnumMap, json['theme']),
      markDeletedEpisodesAsPlayed: json['markDeletedEpisodesAsPlayed'] as bool,
      storeDownloadsSDCard: json['storeDownloadsSDCard'] as bool,
      playbackSpeed: (json['playbackSpeed'] as num).toDouble(),
      searchProvider: json['searchProvider'] as String,
      searchProviders: (json['searchProviders'] as List<dynamic>)
          .map((e) => SearchProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      externalLinkConsent: json['externalLinkConsent'] as bool,
      autoOpenNowPlaying: json['autoOpenNowPlaying'] as bool,
      showFunding: json['showFunding'] as bool,
      autoUpdateEpisodePeriod: json['autoUpdateEpisodePeriod'] as int,
      trimSilence: json['trimSilence'] as bool,
      volumeBoost: json['volumeBoost'] as bool,
      layout: json['layout'] as int,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
    <String, dynamic>{
      'streamWarnMobileData': instance.streamWarnMobileData,
      'downloadWarnMobileData': instance.downloadWarnMobileData,
      'autoDownloadOnlyOnWifi': instance.autoDownloadOnlyOnWifi,
      'autoDeleteEpisodes': instance.autoDeleteEpisodes,
      'theme': _$BrightnessModeEnumMap[instance.theme]!,
      'markDeletedEpisodesAsPlayed': instance.markDeletedEpisodesAsPlayed,
      'storeDownloadsSDCard': instance.storeDownloadsSDCard,
      'playbackSpeed': instance.playbackSpeed,
      'searchProvider': instance.searchProvider,
      'searchProviders':
          instance.searchProviders.map((e) => e.toJson()).toList(),
      'externalLinkConsent': instance.externalLinkConsent,
      'autoOpenNowPlaying': instance.autoOpenNowPlaying,
      'showFunding': instance.showFunding,
      'autoUpdateEpisodePeriod': instance.autoUpdateEpisodePeriod,
      'trimSilence': instance.trimSilence,
      'volumeBoost': instance.volumeBoost,
      'layout': instance.layout,
    };

const _$BrightnessModeEnumMap = {
  BrightnessMode.system: 'system',
  BrightnessMode.light: 'light',
  BrightnessMode.dark: 'dark',
};
