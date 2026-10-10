import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';

/// Which queue actions an episode row menu offers.
///
/// Resolved before the sheet opens so items never pop in after it shows.
class EpisodeQueueMenuOptions {
  const EpisodeQueueMenuOptions({
    required this.queueIsEmpty,
    required this.hasFollowing,
  });

  /// With nothing queued, "Add to queue" would do the same as "Play next",
  /// so only the latter is offered.
  final bool queueIsEmpty;

  /// Whether episodes follow this one in the list's play order; the
  /// "from here" actions are hidden when there are none.
  final bool hasFollowing;

  /// Offered when the queue cannot be read: the single-episode actions
  /// still work, and the rest of the row menu stays reachable.
  static const fallback = EpisodeQueueMenuOptions(
    queueIsEmpty: false,
    hasFollowing: false,
  );

  static Future<EpisodeQueueMenuOptions> resolve(
    WidgetRef ref, {
    required int episodeId,
    required List<int>? siblingEpisodeIds,
    required AutoPlayOrder? effectiveOrder,
  }) async {
    // Read up front: the row may unmount during the awaits, and a ref read
    // after that throws instead of reaching the fallback.
    final service = ref.read(queueServiceProvider);
    final logger = ref.read(namedLoggerProvider('EpisodeQueueMenu'));
    try {
      final queue = await service.getQueue();
      final fromHere = siblingEpisodeIds == null
          ? const <int>[]
          : await service.episodesFromHere(
              startingEpisodeId: episodeId,
              siblingEpisodeIds: siblingEpisodeIds,
              effectiveOrder: effectiveOrder,
            );
      return EpisodeQueueMenuOptions(
        queueIsEmpty: !queue.hasItems,
        hasFollowing: 1 < fromHere.length,
      );
    } on Object catch (error, stackTrace) {
      logger.w(
        'Failed to resolve queue menu options',
        error: error,
        stackTrace: stackTrace,
      );
      return fallback;
    }
  }
}

/// Queue section of an episode row menu: Play next, Play next from here,
/// Add to queue, Add to queue from here, filtered by [options].
///
/// [context] is the row's context, which outlives the sheet and shows the
/// confirmation snackbar; [sheetContext] is popped on selection.
List<Widget> buildEpisodeQueueMenuItems({
  required BuildContext context,
  required BuildContext sheetContext,
  required WidgetRef ref,
  required int episodeId,
  required EpisodeQueueMenuOptions options,
  required List<int>? siblingEpisodeIds,
  required AutoPlayOrder? effectiveOrder,
}) {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  // Read on tap: the auto-disposed controller may be gone by then.
  QueueController queue() => ref.read(queueControllerProvider.notifier);
  final siblings = siblingEpisodeIds;
  final offersFromHere = options.hasFollowing && siblings != null;

  void select(Future<String> Function() action) {
    Navigator.pop(sheetContext);
    action().then((message) => _showSnackBar(messenger, message));
  }

  return [
    ListTile(
      leading: const Icon(Icons.playlist_play),
      title: Text(l10n.playNext),
      onTap: () => select(() async {
        await queue().playNext(episodeId);
        return l10n.queuePlayingNext;
      }),
    ),
    if (offersFromHere)
      ListTile(
        leading: const Icon(Icons.playlist_play),
        title: Text(l10n.playNextFromHere),
        onTap: () => select(() async {
          final count = await queue().playNextFromHere(
            episodeId: episodeId,
            siblingEpisodeIds: siblings,
            effectiveOrder: effectiveOrder,
          );
          return l10n.queuePlayingNextCount(count);
        }),
      ),
    if (!options.queueIsEmpty) ...[
      ListTile(
        leading: const Icon(Icons.playlist_add),
        title: Text(l10n.addToQueue),
        onTap: () => select(() async {
          await queue().playLater(episodeId);
          return l10n.queueAddedToQueue;
        }),
      ),
      if (offersFromHere)
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: Text(l10n.addToQueueFromHere),
          onTap: () => select(() async {
            final count = await queue().playLaterFromHere(
              episodeId: episodeId,
              siblingEpisodeIds: siblings,
              effectiveOrder: effectiveOrder,
            );
            return l10n.queueAddedToQueueCount(count);
          }),
        ),
    ],
  ];
}

void _showSnackBar(ScaffoldMessengerState messenger, String message) {
  messenger.showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
  );
}
