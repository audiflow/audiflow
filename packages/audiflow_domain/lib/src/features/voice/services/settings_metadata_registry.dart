import 'dart:collection';

import 'package:audiflow_core/audiflow_core.dart';

import '../models/settings_metadata.dart';

/// Registry of all voice-controllable app settings.
///
/// Provides a central lookup for NLU pipelines to match user utterances
/// against known settings and validate requested values against their
/// defined constraints.
class SettingsMetadataRegistry {
  SettingsMetadataRegistry() : _index = _buildIndex(_entries);

  static final List<SettingMetadata> _entries = [
    // -- Appearance --
    SettingMetadata(
      key: SettingsKeys.themeMode,
      displayNameKey: 'appearanceThemeMode',
      type: SettingType.enumValue,
      constraints: const SettingConstraints.options(
        values: ['light', 'dark', 'system'],
      ),
      synonyms: const [
        'theme',
        'theme mode',
        'appearance',
        'dark mode',
        'light mode',
        'color scheme',
        'テーマ',
        'テーマモード',
        'ダークモード',
        'ライトモード',
        '外観',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.locale,
      displayNameKey: 'appearanceLanguage',
      type: SettingType.enumValue,
      constraints: const SettingConstraints.options(
        values: ['en', 'ja', 'system'],
      ),
      synonyms: const [
        'language',
        'locale',
        'app language',
        'display language',
        '言語',
        'ロケール',
        '表示言語',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.textScale,
      displayNameKey: 'appearanceTextSize',
      type: SettingType.doubleValue,
      constraints: const SettingConstraints.range(
        min: 0.8,
        max: 1.4,
        step: 0.1,
      ),
      synonyms: const [
        'text size',
        'font size',
        'text scale',
        'text scaling',
        'font scale',
        'テキストサイズ',
        'フォントサイズ',
        'テキスト拡大',
        '文字サイズ',
      ],
    ),

    // -- Playback --
    SettingMetadata(
      key: SettingsKeys.playbackSpeed,
      displayNameKey: 'playbackDefaultSpeed',
      type: SettingType.doubleValue,
      constraints: const SettingConstraints.range(
        min: 0.5,
        max: 3.0,
        step: 0.1,
      ),
      synonyms: const [
        'playback speed',
        'speed',
        'play speed',
        'playback rate',
        'podcast speed',
        '再生速度',
        '速度',
        '再生スピード',
        '倍速',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.skipForwardSeconds,
      displayNameKey: 'playbackSkipForward',
      type: SettingType.intValue,
      constraints: const SettingConstraints.range(min: 5, max: 60, step: 5),
      synonyms: const [
        'skip forward',
        'forward skip',
        'fast forward seconds',
        'skip ahead',
        'forward seconds',
        '早送り',
        '前スキップ',
        'スキップ前',
        '早送り秒数',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.skipBackwardSeconds,
      displayNameKey: 'playbackSkipBackward',
      type: SettingType.intValue,
      constraints: const SettingConstraints.range(min: 5, max: 60, step: 5),
      synonyms: const [
        'skip back',
        'skip backward',
        'rewind seconds',
        'back seconds',
        'rewind',
        '巻き戻し',
        '後スキップ',
        'スキップ後',
        '巻き戻し秒数',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoCompleteThreshold,
      displayNameKey: 'playbackAutoCompleteThreshold',
      type: SettingType.doubleValue,
      constraints: const SettingConstraints.range(
        min: 0.8,
        max: 1.0,
        step: 0.01,
      ),
      synonyms: const [
        'auto complete threshold',
        'completion threshold',
        'mark as played threshold',
        'episode complete threshold',
        'listened threshold',
        '自動完了しきい値',
        '再生完了しきい値',
        '自動完了',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.continuousPlayback,
      displayNameKey: 'playbackContinuousTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'continuous playback',
        'auto play next',
        'auto play',
        'autoplay',
        'play next episode',
        'continuous play',
        '連続再生',
        '自動再生',
        '次のエピソード自動再生',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoPlayOrder,
      displayNameKey: 'playbackAutoPlayOrderTitle',
      type: SettingType.enumValue,
      constraints: const SettingConstraints.options(
        values: ['newestFirst', 'oldestFirst'],
      ),
      synonyms: const [
        'auto play order',
        'play order',
        'episode order',
        'playback order',
        'queue order',
        '再生順',
        '自動再生順',
        'エピソード順',
        '再生順序',
      ],
    ),

    // -- Downloads --
    SettingMetadata(
      key: SettingsKeys.wifiOnlyDownload,
      displayNameKey: 'downloadsWifiOnlyTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'wifi only download',
        'download over wifi',
        'wifi download',
        'download on wifi only',
        'mobile data download',
        'Wifiダウンロード',
        'Wi-Fiのみダウンロード',
        'ダウンロードWifi',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoDeletePlayed,
      displayNameKey: 'downloadsAutoDeleteTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'auto delete played',
        'delete played episodes',
        'auto delete',
        'remove played',
        'cleanup played',
        '再生済み自動削除',
        '自動削除',
        '再生後削除',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.maxConcurrentDownloads,
      displayNameKey: 'downloadsMaxConcurrent',
      type: SettingType.intValue,
      constraints: const SettingConstraints.range(min: 1, max: 5, step: 1),
      synonyms: const [
        'max concurrent downloads',
        'simultaneous downloads',
        'download limit',
        'parallel downloads',
        'concurrent downloads',
        '最大同時ダウンロード',
        '同時ダウンロード数',
        'ダウンロード上限',
      ],
    ),

    // -- Feed Sync --
    SettingMetadata(
      key: SettingsKeys.autoSync,
      displayNameKey: 'feedSyncAutoSyncTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'auto sync',
        'automatic sync',
        'background sync',
        'feed sync',
        'auto update feeds',
        '自動同期',
        'オートシンク',
        'バックグラウンド同期',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.syncIntervalMinutes,
      displayNameKey: 'feedSyncInterval',
      type: SettingType.intValue,
      constraints: const SettingConstraints.range(min: 15, max: 1440, step: 15),
      synonyms: const [
        'sync interval',
        'sync frequency',
        'update interval',
        'feed update frequency',
        'refresh interval',
        '同期間隔',
        '更新頻度',
        'フィード更新間隔',
        '同期周期',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.wifiOnlySync,
      displayNameKey: 'feedSyncWifiOnlyTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'wifi only sync',
        'sync over wifi',
        'wifi sync',
        'sync on wifi only',
        'WifiSync',
        'Wi-Fiのみ同期',
        'Wifi同期',
        '同期Wifi',
      ],
    ),

    // -- Notifications --
    SettingMetadata(
      key: SettingsKeys.notifyNewEpisodes,
      displayNameKey: 'feedSyncNotifyNewEpisodesTitle',
      type: SettingType.boolean,
      constraints: const SettingConstraints.boolean(),
      synonyms: const [
        'notify new episodes',
        'episode notifications',
        'new episode alerts',
        'podcast notifications',
        'episode alerts',
        '新着通知',
        'エピソード通知',
        '新エピソード通知',
        '通知',
      ],
    ),

    // -- Search --
    SettingMetadata(
      key: SettingsKeys.searchCountry,
      displayNameKey: 'searchCountry',
      type: SettingType.enumValue,
      constraints: const SettingConstraints.options(
        values: ['us', 'jp', 'gb', 'de', 'fr', 'au', 'ca'],
      ),
      synonyms: const [
        'search country',
        'country',
        'store country',
        'podcast store',
        'itunes country',
        'search region',
        '検索国',
        '国',
        'ストア国',
        '検索地域',
      ],
    ),
  ];

  final Map<String, SettingMetadata> _index;

  /// All registered settings as an unmodifiable list.
  List<SettingMetadata> get allSettings => UnmodifiableListView(_entries);

  /// Finds a setting by its exact [SettingsKeys] key, or returns null.
  SettingMetadata? findByKey(String key) => _index[key];

  static Map<String, SettingMetadata> _buildIndex(
    List<SettingMetadata> entries,
  ) {
    final index = <String, SettingMetadata>{};
    for (final entry in entries) {
      index[entry.key] = entry;
    }
    return Map.unmodifiable(index);
  }
}
