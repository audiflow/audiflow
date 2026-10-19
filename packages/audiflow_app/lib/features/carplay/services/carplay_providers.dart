import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../l10n/app_localizations.dart';
import '../../car/services/car_playback.dart';
import '../../car/services/car_providers.dart';
import '../../settings/presentation/controllers/locale_controller.dart';
import 'carplay_bridge.dart';

part 'carplay_providers.g.dart';

/// The CarPlay strings, keyed as `CarPlayLabels` in
/// `ios/Runner/CarPlayChannel.swift` reads them.
Map<String, String> carPlayLabels(AppLocalizations l10n) => {
  'upNext': l10n.carUpNextTab,
  'inProgress': l10n.carInProgressTab,
  'library': l10n.carLibraryTab,
  'downloads': l10n.carDownloadsTab,
  'upNextEmpty': l10n.carUpNextEmpty,
  'inProgressEmpty': l10n.carInProgressEmpty,
  'libraryEmpty': l10n.carLibraryEmpty,
  'downloadsEmpty': l10n.carDownloadsEmpty,
  'podcastEmpty': l10n.carPodcastEmpty,
  'loadFailed': l10n.carLoadFailed,
};

/// The running CarPlay bridge. Read once at startup on iOS to activate.
///
/// The list data is watched only while a head unit is connected, so a
/// phone that never uses CarPlay pays nothing for it.
@Riverpod(keepAlive: true)
CarPlayBridge carPlayBridge(Ref ref) {
  final watchers = <ProviderSubscription<Object?>>[];
  void stopWatching() {
    for (final watcher in watchers) {
      watcher.close();
    }
    watchers.clear();
  }

  late final CarPlayBridge bridge;
  bridge = CarPlayBridge(
    catalog: () => ref.read(carCatalogProvider),
    playback: CarPlayback(ref),
    labels: () => carPlayLabels(carAppLocalizations(ref)),
    logger: ref.read(namedLoggerProvider('CarPlay')),
    onConnectionChanged: ({required connected}) {
      stopWatching();
      if (connected) {
        watchers.addAll(watchCarListChanges(ref, bridge.invalidate));
      }
    },
  )..start();

  ref.listen(localeControllerProvider, (_, _) => bridge.announce());
  ref.onDispose(() {
    stopWatching();
    bridge.dispose();
  });
  return bridge;
}
