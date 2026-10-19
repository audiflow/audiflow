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
import '../models/car_list_item.dart';
import 'car_catalog.dart';

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
  nowPlayingUrl: () => ref.read(nowPlayingControllerProvider)?.episodeUrl,
  formatDuration: (duration) =>
      carAppLocalizations(ref).durationLabel(duration),
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
      // A podcast's episode list shows the same progress bars.
      changes({CarSection.inProgress, CarSection.podcast}),
    ),
    ref.listen(
      sortedSubscriptionsProvider,
      changes({CarSection.library, CarSection.podcast}),
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
