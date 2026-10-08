import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/station_detail_controller.dart';
import 'station_artwork.dart';

/// Library grid tile for a [Station]: square stacked artwork, name, and
/// podcast and episode counts on a `surface` card (redesign 4.1).
class StationGridTile extends ConsumerWidget {
  const StationGridTile({
    required this.station,
    required this.onTap,
    super.key,
  });

  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final loadedPodcasts = ref.watch(stationPodcastsProvider(station.id)).value;
    final podcasts = loadedPodcasts ?? [];
    final episodeCount =
        ref.watch(stationEpisodesProvider(station.id)).value?.length ?? 0;
    final subscriptions = ref.watch(librarySubscriptionsProvider).value ?? [];
    final artworkById = {for (final s in subscriptions) s.id: s.artworkUrl};
    final artworkUrls = [
      for (final podcast in podcasts.take(StationArtwork.maxCards))
        artworkById[podcast.podcastId],
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorders.card,
        boxShadow: AppShadows.groupedSurface,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppBorders.card,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm + Spacing.xxs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: AppBorders.artworkList,
                    // Blank until loaded, so a station never flashes empty.
                    child: loadedPodcasts == null
                        ? ColoredBox(color: colors.surfaceSunken)
                        : StationArtwork(
                            artworkUrls: artworkUrls,
                            onAdd: () => context.push(
                              AppRoutes.stationPickPodcasts(station.id),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
                ),
                Text(
                  '${l10n.stationPodcastCount(podcasts.length)} · '
                  '${l10n.stationEpisodeCount(episodeCount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: colors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
