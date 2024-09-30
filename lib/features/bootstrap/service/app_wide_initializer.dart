import 'dart:io';

import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/events/transcript_event.dart';
import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/browser/common/service/subscribed_podcast_refresher.dart';
import 'package:audiflow/features/browser/episode/service/episode_stats_updater.dart';
import 'package:audiflow/features/download/service/download_task_controller.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/service/audio_position_recorder.dart';
import 'package:audiflow/features/player/service/last_episode_service.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_wide_initializer.g.dart';

@Riverpod(keepAlive: true)
bool appWide(AppWideRef ref) {
  ref
    ..listen(preferenceRepositoryProvider, (_, __) {})
    ..listen(audioQueueServiceProvider, (_, __) {})
    ..listen(audioPlayerEventStreamProvider, (_, __) {})
    ..listen(audioPlayerServiceProvider, (_, __) {})
    ..listen(audioPositionRecorderProvider, (_, __) {})
    ..listen(connectivityProvider, (_, __) {})
    ..listen(downloadEventStreamProvider, (_, __) {})
    ..listen(downloadTaskControllerProvider, (_, __) {})
    ..listen(episodeEventStreamProvider, (_, __) {})
    ..listen(episodeStatsUpdaterProvider, (_, __) {})
    ..listen(podcastApiRepositoryProvider, (_, __) {})
    ..listen(podcastEventStreamProvider, (_, __) {})
    ..listen(subscribedPodcastRefresherProvider, (_, __) {})
    ..listen(transcriptEventStreamProvider, (_, __) {});
  return true;
}

class AppWideProvidersInitializer extends HookConsumerWidget {
  const AppWideProvidersInitializer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = useState(false);
    useEffect(
      () {
        if (initState.value) {
          return;
        }

        Future.wait([
          ref.read(downloadTaskControllerProvider.notifier).ensureInitialized(),
          ref.read(queueControllerProvider.notifier).ensureInitialized(),
          ref
              .read(audioPlayerServiceProvider.notifier)
              .ensureInitialized()
              .then(
                (_) => ref.read(lastEpisodeServiceProvider).resumeEpisode(),
              ),
          _setupCertificateAuthority().then((ca) {
            ref.read(podcastApiRepositoryProvider).setClientAuthorityBytes(ca);
          }),
        ]).then((_) {
          initState.value = true;
        });
        return;
      },
      [],
    );
    return initState.value
        ? child
        : ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
  }
}

/// The Let's Encrypt certificate authority expired at the end of September
/// 2021.
/// Android devices running v7.1.1 or earlier will no longer trust their root
/// certificate which will cause issues when trying to fetch feeds and images
/// from sites secured with LE. This routine is called to add the new CA to the
/// trusted list at app start.
Future<List<int>> _setupCertificateAuthority() async {
  var ca = <int>[];

  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final major = androidInfo.version.release.split('.');

    if ((int.tryParse(major[0]) ?? 100.0) < 8.0) {
      final data =
          await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
      ca = data.buffer.asUint8List();
      SecurityContext.defaultContext.setTrustedCertificatesBytes(ca);
    }
  }

  return ca;
}
