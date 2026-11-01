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
import '../../station/presentation/controllers/station_list_controller.dart';
import '../../station/presentation/utils/station_recency.dart';
import '../../player/services/content_uri_artwork_preparer.dart';
import '../../player/services/now_playing_artwork_provider.dart';
import '../models/car_list_item.dart';
import 'car_artwork_resolver.dart';
import 'car_catalog.dart';
import 'car_change_batcher.dart';
import 'car_media_browser.dart';
import 'car_playback.dart';

part 'car_providers.g.dart';

/// The app's strings in the chosen language, or the device's when the
/// setting follows the system. The car has no `BuildContext` to read them
/// from.
AppLocalizations carAppLocalizations(Ref ref) {
  final locale =
      ref.read(localeControllerProvider) ?? PlatformDispatcher.instance.locale;
  return lookupAppLocalizations(
    resolveSupportedLocale(locale, AppLocalizations.supportedLocales),
  );
}

@Riverpod(keepAlive: true)
CarCatalog carCatalog(Ref ref) => CarCatalog(
  queueService: ref.watch(queueServiceProvider),
  historyRepository: ref.watch(playbackHistoryRepositoryProvider),
  episodeRepository: ref.watch(episodeRepositoryProvider),
  subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
  downloadRepository: ref.watch(downloadRepositoryProvider),
  parentalControlRepository: ref.watch(parentalControlRepositoryProvider),
  loadSubscriptions: () => _readOnce(ref, sortedSubscriptionsProvider.future),
  stationRepository: ref.watch(stationRepositoryProvider),
  stationEpisodeRepository: ref.watch(stationEpisodeRepositoryProvider),
  stationPodcastRepository: ref.watch(stationPodcastRepositoryProvider),
  loadStations: () async => recentlyPlayedStations(
    await _readOnce(ref, stationListProvider.future),
    limit: CarCatalog.itemLimit,
  ),
  nowPlayingUrl: () => ref.read(nowPlayingControllerProvider)?.episodeUrl,
  formatDuration: (duration) =>
      carAppLocalizations(ref).durationLabel(duration),
  formatEpisodeCount: (count) =>
      carAppLocalizations(ref).stationEpisodeCount(count),
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

/// Listens to the data behind each in-car list and reports the lists whose
/// data changed. Close the returned subscriptions to stop.
List<ProviderSubscription<Object?>> watchCarListChanges(
  Ref ref,
  void Function(Set<CarSection> sections) onChanged,
) {
  void Function(Object?, Object?) changes(Set<CarSection> sections) =>
      (_, _) => onChanged(sections);

  return [
    ref.listen(playbackQueueProvider, changes({CarSection.upNext})),
    ref.listen(
      continueListeningEpisodesProvider,
      // Podcast and station episode lists show the same progress bars.
      changes({CarSection.inProgress, CarSection.podcast, CarSection.station}),
    ),
    ref.listen(
      sortedSubscriptionsProvider,
      changes({CarSection.library, CarSection.podcast}),
    ),
    // A station's feed is not watched: the feed is rebuilt in the
    // background, and an open station list catches up when reopened.
    ref.listen(
      stationListProvider,
      changes({CarSection.stations, CarSection.station}),
    ),
    ref.listen(
      completedDownloadEpisodeIdsProvider,
      changes({CarSection.downloads}),
    ),
    // Every list marks the now-playing row.
    ref.listen(
      nowPlayingControllerProvider.select((info) => info?.episodeUrl),
      changes(CarSection.values.toSet()),
    ),
  ];
}

/// The audio handler's lasting hold on [carMediaBrowserProvider].
///
/// The browser follows list changes through its own `ref.listen` on
/// database watches. Each bare `read` leaves the browser with no listener
/// once it returns, and Riverpod then deactivates the browser's
/// subscriptions, which pauses those watches: open car lists would only
/// catch up on the next browse request. One listener held for the life of
/// the handler keeps them running.
class CarBrowserLink {
  CarBrowserLink(Ref ref)
    : _subscription = ref.listen(carMediaBrowserProvider.future, (_, _) {});

  final ProviderSubscription<Future<CarMediaBrowser>> _subscription;

  Future<CarMediaBrowser> get browser => _subscription.read();
}

/// Android Auto's media browser. Created on the first browse request.
@Riverpod(keepAlive: true)
Future<CarMediaBrowser> carMediaBrowser(Ref ref) async {
  final authority = await artworkProviderAuthority();
  // Read, not watched: a rebuild would close the change streams that
  // audio_service keeps listening to for the life of the process.
  final artwork = ContentProviderArtworkResolver(
    preparer: buildArtworkPreparer(
      dio: ref.read(dioProvider),
      cacheDir: ref.read(cacheDirProvider),
      folder: carArtworkCacheFolder,
      logger: ref.read(namedLoggerProvider('CarArtwork')),
      maxEdgePixels: carArtworkMaxEdgePixels,
      entryLimit: carArtworkCacheEntryLimit,
    ),
    authority: authority,
  );

  final watchers = <ProviderSubscription<Object?>>[];
  late final CarMediaBrowser browser;
  final changes = CarChangeBatcher(onFlush: (s) => browser.notifyChanged(s));
  browser = CarMediaBrowser(
    catalog: () => ref.read(carCatalogProvider),
    playback: CarPlayback(ref, catalog: () => ref.read(carCatalogProvider)),
    artwork: artwork,
    tabTitles: () {
      final l10n = carAppLocalizations(ref);
      return {
        CarSection.upNext: l10n.carUpNextTab,
        CarSection.stations: l10n.carStationsTab,
        CarSection.library: l10n.carLibraryTab,
        CarSection.downloads: l10n.carDownloadsTab,
      };
    },
    logger: ref.read(namedLoggerProvider('AndroidAuto')),
    onFirstBrowse: () => watchers.addAll(watchCarListChanges(ref, changes.add)),
  );
  ref.onDispose(() {
    for (final watcher in watchers) {
      watcher.close();
    }
    changes.dispose();
    browser.dispose();
  });
  return browser;
}
