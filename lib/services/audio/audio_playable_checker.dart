import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/connectivity/connectivity.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/dialogs/warn_no_wifi.dart';
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
        await _ref.read(repositoryProvider).findDownload(episode.id);
    if (download?.state == DownloadState.downloaded) {
      return true;
    }

    final settings = _ref.read(settingsServiceProvider);
    if (!settings.streamWarnMobileData) {
      return true;
    }

    final router = _ref.read(routerProvider);
    assert(router.context.mounted);
    if (!router.context.mounted) {
      return false;
    }

    final l10n = L10n.of(router.context);
    return await warnNoWifi(
          router.context,
          caption: l10n.captionStreamingNoWifi,
          proceedCaption: l10n.proceedPlaying,
        ) ??
        false;
  }
}
