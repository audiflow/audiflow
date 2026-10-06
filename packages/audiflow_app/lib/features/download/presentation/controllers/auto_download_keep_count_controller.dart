import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/background/background_task_registrar.dart';

part 'auto_download_keep_count_controller.g.dart';

/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.
///
/// Kept alive: callers fire these actions without listening, and an
/// auto-disposed controller would be torn down mid-await, making the
/// following `ref.read` throw.
@Riverpod(keepAlive: true)
class AutoDownloadKeepCountController
    extends _$AutoDownloadKeepCountController {
  @override
  FutureOr<void> build() {}

  /// Saves the global keep count and trims every podcast that follows it.
  Future<void> setGlobal(int count) async {
    final settings = ref.read(appSettingsRepositoryProvider);
    await settings.setAutoDownloadKeepCount(count);
    ref.invalidate(appSettingsRepositoryProvider);
    // Re-register right after saving so the background isolate gets the new
    // snapshot even if the immediate trim below fails. Registration swallows
    // platform errors itself, so it cannot block the trim either.
    await BackgroundTaskRegistrar.syncWithSettings(
      settings,
      replaceExisting: true,
    );

    // Each trim is best-effort, so one podcast cannot stop the rest.
    final subscriptions = await ref
        .read(subscriptionRepositoryProvider)
        .getSubscriptions();
    final retention = ref.read(downloadRetentionServiceProvider);
    for (final subscription in subscriptions) {
      await retention.trimForSubscription(
        subscription,
        defaultKeepCount: count,
      );
    }
  }

  /// Saves a podcast's keep count override (null follows the global
  /// setting) and trims that podcast.
  Future<void> setForPodcast(int subscriptionId, int? count) async {
    final subscriptions = ref.read(subscriptionRepositoryProvider);
    await subscriptions.updateAutoDownloadKeepCount(subscriptionId, count);

    final updated = await subscriptions.getById(subscriptionId);
    if (updated == null) return;
    await ref
        .read(downloadRetentionServiceProvider)
        .trimForSubscription(
          updated,
          defaultKeepCount: ref
              .read(appSettingsRepositoryProvider)
              .getAutoDownloadKeepCount(),
        );
  }
}
