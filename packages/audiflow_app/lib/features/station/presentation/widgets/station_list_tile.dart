import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/station_detail_controller.dart';

/// ListTile for a single [Station] showing a 2x2 artwork mosaic and counts.
class StationListTile extends ConsumerWidget {
  const StationListTile({
    required this.station,
    required this.onTap,
    super.key,
  });

  final Station station;
  final VoidCallback onTap;

  static const double _mosaicSize = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastsAsync = ref.watch(stationPodcastsProvider(station.id));
    final episodesAsync = ref.watch(stationEpisodesProvider(station.id));
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final podcasts = podcastsAsync.value ?? [];
    final podcastCount = podcasts.length;
    final episodeCount = episodesAsync.value?.length ?? 0;

    final subscriptions = subscriptionsAsync.value ?? [];
    final artworkMap = {for (final s in subscriptions) s.id: s.artworkUrl};

    final artworkUrls = podcasts
        .take(4)
        .map((sp) => artworkMap[sp.podcastId])
        .toList();

    return ListTile(
      leading: _StationMosaic(
        artworkUrls: artworkUrls,
        colorScheme: colorScheme,
        size: _mosaicSize,
      ),
      title: Text(station.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${AppLocalizations.of(context).stationPodcastCount(podcastCount)}, '
        '${AppLocalizations.of(context).stationEpisodeCount(episodeCount)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

class _StationMosaic extends StatelessWidget {
  const _StationMosaic({
    required this.artworkUrls,
    required this.colorScheme,
    required this.size,
  });

  final List<String?> artworkUrls;
  final ColorScheme colorScheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cellSize = size / 2;
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: size,
        height: size,
        child: Wrap(
          children: List.generate(4, (index) {
            final url = index < artworkUrls.length ? artworkUrls[index] : null;
            return _buildCell(url, cellSize);
          }),
        ),
      ),
    );
  }

  Widget _buildCell(String? url, double cellSize) {
    final child = url != null
        ? Image.network(
            url,
            width: cellSize,
            height: cellSize,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(cellSize),
          )
        : _placeholder(cellSize);
    return SizedBox(width: cellSize, height: cellSize, child: child);
  }

  Widget _placeholder(double size) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: size * 0.5,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
