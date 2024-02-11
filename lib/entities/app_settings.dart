// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/search_providers.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    /// The current theme name.
    required String theme,

    /// True if episodes are marked as played when deleted.
    required bool markDeletedEpisodesAsPlayed,

    /// True if downloads should be saved to the SD card.
    required bool storeDownloadsSDCard,

    /// The default playback speed.
    required double playbackSpeed,

    /// The search provider: itunes or podcastindex.
    required String? searchProvider,

    /// List of search providers: currently itunes or podcastindex.
    required List<SearchProvider> searchProviders,

    /// True if the user has confirmed dialog accepting funding links.
    required bool externalLinkConsent,

    /// If true the main player window will open as soon as an episode starts.
    required bool autoOpenNowPlaying,

    /// If true the funding link icon will appear (if the podcast supports it).
    required bool showFunding,

    /// If -1 never; 0 always; otherwise time in minutes.
    required int autoUpdateEpisodePeriod,

    /// If true, silence in audio playback is trimmed. Currently Android only.
    required bool trimSilence,

    /// If true, volume is boosted. Currently Android only.
    required bool volumeBoost,

    /// If 0, list view; else grid view
    required int layout,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

// static AppSettings.sensibleDefaults()
//     : theme = 'dark',
//       markDeletedEpisodesAsPlayed = false,
//       storeDownloadsSDCard = false,
//       playbackSpeed = 1.0,
//       searchProvider = 'itunes',
//       searchProviders = <SearchProvider>[],
//       externalLinkConsent = false,
//       autoOpenNowPlaying = false,
//       showFunding = true,
//       autoUpdateEpisodePeriod = -1,
//       trimSilence = false,
//       volumeBoost = false,
//       layout = 0;
}
