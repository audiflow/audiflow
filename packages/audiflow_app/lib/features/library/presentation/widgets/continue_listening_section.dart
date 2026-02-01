import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/continue_listening_controller.dart';

/// Horizontal scrolling section showing episodes in progress.
///
/// Hidden when there are no in-progress episodes.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({super.key, this.onEpisodeTap});

  final void Function(EpisodeWithProgress episode)? onEpisodeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(continueListeningEpisodesProvider);

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) return const SizedBox.shrink();
        return _buildSection(context, episodes);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<EpisodeWithProgress> episodes,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            Spacing.sm,
          ),
          child: Text(
            'Continue Listening',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return _ContinueListeningCard(
                episode: episode,
                onTap: () => onEpisodeTap?.call(episode),
              );
            },
          ),
        ),
        const SizedBox(height: Spacing.md),
        const Divider(height: 1),
      ],
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({required this.episode, this.onTap});

  final EpisodeWithProgress episode;
  final VoidCallback? onTap;

  static const double _cardWidth = 100.0;
  static const double _artworkSize = 100.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label:
          'Continue listening to ${episode.episode.title}. '
          '${episode.remainingTimeFormatted ?? ""}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArtwork(colorScheme),
              const SizedBox(height: Spacing.xs),
              _buildTitle(theme),
              _buildRemainingTime(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: _artworkSize,
        height: _artworkSize,
        child: episode.episode.imageUrl != null
            ? ExtendedImage.network(
                episode.episode.imageUrl!,
                fit: BoxFit.cover,
                cache: true,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.failed) {
                    return _buildPlaceholder(colorScheme);
                  }
                  return null;
                },
              )
            : _buildPlaceholder(colorScheme),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      episode.episode.title,
      style: theme.textTheme.bodySmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRemainingTime(ThemeData theme, ColorScheme colorScheme) {
    final remainingText = episode.remainingTimeFormatted;
    if (remainingText == null) return const SizedBox.shrink();

    return Text(
      remainingText,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.podcasts,
          size: 40,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
