import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../podcast_detail/presentation/widgets/episode_pill_duration_label.dart';
import '../controllers/continue_listening_controller.dart';

/// Horizontal cards for in-progress episodes (redesign 4.1).
///
/// Collapses to nothing when there are no in-progress episodes, while
/// loading, and on error, so the Library never shows an empty section.
class ContinueListeningSection extends ConsumerWidget {
  const ContinueListeningSection({required this.onEpisodeTap, super.key});

  final void Function(EpisodeWithProgress episode) onEpisodeTap;

  static const double _cardWidth = 280;
  static const double _cardHeight = 80;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(continueListeningEpisodesProvider).value ?? [];
    if (episodes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppLocalizations.of(context).libraryContinueListening,
        ),
        const SizedBox(height: Spacing.xs),
        SizedBox(
          // Room for the cards' shadow below them.
          height: _cardHeight + Spacing.sm,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.screenHorizontal,
            ),
            itemCount: episodes.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm + 4),
            itemBuilder: (context, index) => Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _cardWidth,
                height: _cardHeight,
                child: _ContinueListeningCard(
                  episode: episodes[index],
                  onTap: () => onEpisodeTap(episodes[index]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
      ],
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard({required this.episode, required this.onTap});

  final EpisodeWithProgress episode;
  final VoidCallback onTap;

  static const double _artworkSize = 56;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
          child: BottomEdgeProgress(
            fraction: episode.progressPercent,
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.sm + Spacing.xxs),
                child: Row(
                  children: [
                    _artwork(colors),
                    const SizedBox(width: Spacing.sm + Spacing.xs),
                    Expanded(child: _labels(context, colors)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _artwork(AppColors colors) {
    final url = episode.episode.imageUrl;
    final placeholder = ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.podcasts, color: colors.inkQuaternary),
    );
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox.square(
        dimension: _artworkSize,
        child: url == null
            ? placeholder
            : ArtworkImage(
                url: url,
                width: _artworkSize,
                height: _artworkSize,
                loading: const SizedBox.shrink(),
                placeholder: placeholder,
              ),
      ),
    );
  }

  Widget _labels(BuildContext context, AppColors colors) {
    final l10n = AppLocalizations.of(context);
    final remaining = episode.remainingDuration;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          episode.episode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (remaining != null)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xxs),
            child: Text(
              l10n.episodePillRemaining(
                episodePillDurationLabel(remaining, l10n),
              ),
              style: AppTextStyles.tabular(
                AppTextStyles.caption.copyWith(color: colors.inkTertiary),
              ),
            ),
          ),
      ],
    );
  }
}
