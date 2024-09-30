import 'dart:async';

import 'package:audiflow/common/data/isar_repository.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:audiflow/features/preference/model/preference.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'isar_preference_repository.g.dart';

@Riverpod(keepAlive: true)
class IsarAppPreferenceRepository extends _$IsarAppPreferenceRepository
    implements PreferenceRepository {
  Isar get isar => ref.read(isarRepositoryProvider);

  final _updateStreamController = StreamController<PreferenceUpdateParam>();

  @override
  Preference build() {
    isar.preferences.get(1).then((record) {
      if (record != null) {
        state = record;
      }
    });

    _updateStreamController.stream.flatMap(
      (updateParam) async* {
        await _update(updateParam);
      },
      maxConcurrent: 1,
    ).drain<void>();

    return Preference.sensibleDefaults();
  }

  void dispose() {
    _updateStreamController.close();
  }

  @override
  Future<void> update(PreferenceUpdateParam param) async {
    _updateStreamController.add(param);
  }

  Future<void> _update(PreferenceUpdateParam param) async {
    final record =
        (await isar.preferences.get(1) ?? Preference.sensibleDefaults())
            .copyWith(
      streamWarnMobileData: param.streamWarnMobileData,
      downloadWarnMobileData: param.downloadWarnMobileData,
      autoDownloadOnlyOnWifi: param.autoDownloadOnlyOnWifi,
      autoDeleteEpisodes: param.autoDeleteEpisodes,
      markDeletedEpisodesAsPlayed: param.markDeletedEpisodesAsPlayed,
      storeDownloadsSDCard: param.storeDownloadsSDCard,
      theme: param.theme,
      playbackSpeed: param.playbackSpeed,
      playbackSleepType: param.playbackSleep?.type,
      playbackSleepMinutes: param.playbackSleep?.duration.inMinutes,
      searchProvider: param.searchProvider,
      externalLinkConsent: param.externalLinkConsent,
      autoOpenNowPlaying: param.autoOpenNowPlaying,
      showFunding: param.showFunding,
      autoUpdateEpisodePeriod: param.autoUpdateEpisodePeriod,
      trimSilence: param.trimSilence,
      volumeBoost: param.volumeBoost,
      layout: param.layout,
    );
    await isar.writeTxn(() => isar.preferences.put(record));
    state = record;
  }
}
