import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/common/ui/warn_no_wifi.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_playable_checker.g.dart';

@Riverpod(keepAlive: true)
AudioPlayableChecker audioPlayableChecker(AudioPlayableCheckerRef ref) {
  return AudioPlayableChecker._(ref);
}

class AudioPlayableChecker {
  AudioPlayableChecker._(this._ref);

  final Ref _ref;

  Future<bool> canStartPlayback(Episode episode) async {
    final playerState = _ref.read(audioPlayerServiceProvider);
    if (playerState?.episode.guid == episode.guid) {
      return true;
    }

    if (!await usesCellularConnection()) {
      return true;
    }

    final download =
        await _ref.read(downloadRepositoryProvider).findDownload(episode.id);
    if (download?.state == DownloadState.downloaded) {
      return true;
    }

    final prefs = _ref.read(appPreferenceRepositoryProvider);
    if (!prefs.streamWarnMobileData) {
      return true;
    }

    final routerContext = _ref.read(routerContextProvider);
    assert(routerContext.mounted);
    if (!routerContext.mounted) {
      return false;
    }

    final l10n = L10n.of(routerContext);
    return await warnNoWifi(
          routerContext,
          caption: l10n.captionStreamingNoWifi,
          proceedCaption: l10n.proceedPlaying,
        ) ??
        false;
  }
}
