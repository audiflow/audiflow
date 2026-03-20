import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/station_detail_controller.dart';

/// Shows filtered episodes for a single [Station].
class StationDetailScreen extends ConsumerWidget {
  const StationDetailScreen({required this.stationId, super.key});

  final int stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationAsync = ref.watch(stationByIdProvider(stationId));

    return stationAsync.when(
      data: (station) {
        if (station == null) {
          return _buildNotFound(context);
        }
        return _StationDetailContent(station: station);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Station')),
        body: Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stationNotFoundTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: Spacing.md),
            Text(l10n.stationNotFoundMessage),
            const SizedBox(height: Spacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonGoBack),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationDetailContent extends ConsumerWidget {
  const _StationDetailContent({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(stationEpisodesProvider(station.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        actions: [
          IconButton(
            icon: const Icon(Symbols.edit),
            tooltip: AppLocalizations.of(context).stationEditTooltip,
            onPressed: () =>
                context.push('${AppRoutes.library}/station/${station.id}/edit'),
          ),
        ],
      ),
      body: episodesAsync.when(
        data: (episodes) => _buildEpisodeList(context, ref, episodes),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildEpisodeList(
    BuildContext context,
    WidgetRef ref,
    List<StationEpisode> stationEpisodes,
  ) {
    if (stationEpisodes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: stationEpisodes.length,
      itemBuilder: (context, index) {
        return _StationEpisodeTile(
          key: ValueKey(stationEpisodes[index].id),
          stationEpisode: stationEpisodes[index],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.radio,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              AppLocalizations.of(context).stationEmpty,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              AppLocalizations.of(context).stationEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Loads and renders a single episode from a [StationEpisode] row.
class _StationEpisodeTile extends ConsumerWidget {
  const _StationEpisodeTile({required this.stationEpisode, super.key});

  final StationEpisode stationEpisode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeAsync = ref.watch(
      episodeByIdProvider(stationEpisode.episodeId),
    );

    return episodeAsync.when(
      data: (episode) {
        if (episode == null) return const SizedBox.shrink();
        return _buildTile(context, episode);
      },
      loading: () => const ListTile(
        title: Text('Loading...'),
        leading: CircularProgressIndicator.adaptive(),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildTile(BuildContext context, Episode episode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final duration = episode.durationMs != null
        ? Duration(milliseconds: episode.durationMs!)
        : null;
    final durationText = duration != null ? _formatDuration(duration) : null;

    return ListTile(
      leading: episode.imageUrl != null
          ? ClipRRect(
              borderRadius: AppBorders.sm,
              child: Image.network(
                episode.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholderArtwork(colorScheme),
              ),
            )
          : _placeholderArtwork(colorScheme),
      title: Text(episode.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: durationText != null
          ? Text(
              durationText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
    );
  }

  Widget _placeholderArtwork(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: Container(
        width: 48,
        height: 48,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.podcasts,
          size: 24,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (0 < hours) {
      return '${hours}h ${minutes}m';
    }
    if (0 < minutes) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
