import 'dart:ui';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/app_locale.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/duration_label.dart';
import '../../library/presentation/controllers/continue_listening_controller.dart';
import '../../library/presentation/controllers/library_controller.dart';
import '../../settings/presentation/controllers/locale_controller.dart';
import '../models/carplay_list_item.dart';
import 'carplay_bridge.dart';
import 'carplay_catalog.dart';
import 'carplay_playback.dart';

part 'carplay_providers.g.dart';

/// The CarPlay strings, keyed as `CarPlayLabels` in
/// `ios/Runner/CarPlayChannel.swift` reads them.
Map<String, String> carPlayLabels(AppLocalizations l10n) => {
  'upNext': l10n.carPlayUpNextTab,
  'inProgress': l10n.carPlayInProgressTab,
  'library': l10n.carPlayLibraryTab,
  'downloads': l10n.carPlayDownloadsTab,
  'upNextEmpty': l10n.carPlayUpNextEmpty,
  'inProgressEmpty': l10n.carPlayInProgressEmpty,
  'libraryEmpty': l10n.carPlayLibraryEmpty,
  'downloadsEmpty': l10n.carPlayDownloadsEmpty,
  'podcastEmpty': l10n.carPlayPodcastEmpty,
  'loadFailed': l10n.carPlayLoadFailed,
};

/// The app's strings in the chosen language, or the device's when the
/// setting follows the system. CarPlay has no `BuildContext` to read them
/// from.
AppLocalizations _appLocalizations(Ref ref) {
  final locale =
      ref.read(localeControllerProvider) ?? PlatformDispatcher.instance.locale;
  return lookupAppLocalizations(
    resolveSupportedLocale(locale, AppLocalizations.supportedLocales),
  );
}

@Riverpod(keepAlive: true)
CarPlayCatalog carPlayCatalog(Ref ref) => CarPlayCatalog(
  queueService: ref.watch(queueServiceProvider),
  historyRepository: ref.watch(playbackHistoryRepositoryProvider),
  episodeRepository: ref.watch(episodeRepositoryProvider),
  subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
  downloadRepository: ref.watch(downloadRepositoryProvider),
  parentalControlRepository: ref.watch(parentalControlRepositoryProvider),
  loadSubscriptions: () => _readOnce(ref, sortedSubscriptionsProvider.future),
  nowPlayingUrl: () => ref.read(nowPlayingControllerProvider)?.episodeUrl,
  formatDuration: (duration) => _appLocalizations(ref).durationLabel(duration),
);

/// Reads auto-dispose [provider] while holding a listener, so it is not
/// disposed before its future completes.
Future<T> _readOnce<T>(Ref ref, ProviderListenable<Future<T>> provider) async {
  final subscription = ref.listen(provider, (_, _) {});
  try {
    return await subscription.read();
  } finally {
    subscription.close();
  }
}

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
    catalog: ref.watch(carPlayCatalogProvider),
    playback: CarPlayPlayback(ref),
    labels: () => carPlayLabels(_appLocalizations(ref)),
    logger: ref.read(namedLoggerProvider('CarPlay')),
    onConnectionChanged: ({required connected}) {
      stopWatching();
      if (connected) watchers.addAll(_watchListChanges(ref, bridge));
    },
  )..start();

  ref.listen(localeControllerProvider, (_, _) => bridge.announce());
  ref.onDispose(() {
    stopWatching();
    bridge.dispose();
  });
  return bridge;
}

/// Listens to the data behind each CarPlay list and invalidates the list
/// when it changes.
List<ProviderSubscription<Object?>> _watchListChanges(
  Ref ref,
  CarPlayBridge bridge,
) {
  void Function(Object?, Object?) invalidates(Set<CarPlaySection> sections) =>
      (_, _) => bridge.invalidate(sections);

  return [
    ref.listen(playbackQueueProvider, invalidates({CarPlaySection.upNext})),
    ref.listen(
      continueListeningEpisodesProvider,
      invalidates({CarPlaySection.inProgress}),
    ),
    ref.listen(
      sortedSubscriptionsProvider,
      invalidates({CarPlaySection.library, CarPlaySection.podcast}),
    ),
    ref.listen(
      completedDownloadEpisodeIdsProvider,
      invalidates({CarPlaySection.downloads}),
    ),
    // Every list marks the now-playing row.
    ref.listen(
      nowPlayingControllerProvider.select((info) => info?.episodeUrl),
      invalidates(CarPlaySection.values.toSet()),
    ),
  ];
}
