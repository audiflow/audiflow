import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen showing episodes within a single season.
class SeasonEpisodesScreen extends ConsumerWidget {
  const SeasonEpisodesScreen({
    super.key,
    required this.season,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
  });

  final Season season;
  final String podcastTitle;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(season.displayName)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _SeasonHeader(
              season: season,
              podcastTitle: podcastTitle,
              podcastArtworkUrl: podcastArtworkUrl,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${season.episodeCount} episodes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      // TODO: Show episode sort options
                    },
                    tooltip: 'Sort',
                  ),
                ],
              ),
            ),
          ),
          _buildEpisodeList(ref),
        ],
      ),
    );
  }

  Widget _buildEpisodeList(WidgetRef ref) {
    // TODO: Fetch actual episodes by IDs from season.episodeIds
    // For now, show placeholder
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Center(
          child: Text('${season.episodeCount} episodes in this season'),
        ),
      ),
    );
  }
}

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({
    required this.season,
    required this.podcastTitle,
    required this.podcastArtworkUrl,
  });

  final Season season;
  final String podcastTitle;
  final String? podcastArtworkUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildArtwork(colorScheme),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  podcastTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    if (podcastArtworkUrl != null) {
      return Image.network(
        podcastArtworkUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(colorScheme),
      );
    }
    return _buildPlaceholder(colorScheme);
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.folder_outlined,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
