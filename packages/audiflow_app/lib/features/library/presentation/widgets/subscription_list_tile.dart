import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/library_controller.dart';

/// Row for a subscribed podcast inside the Library's grouped list:
/// artwork 52, title, and the date of its newest episode (redesign 4.1).
class SubscriptionListTile extends ConsumerWidget {
  const SubscriptionListTile({
    required this.subscription,
    required this.onTap,
    super.key,
  });

  final Subscription subscription;
  final VoidCallback onTap;

  static const double _artworkSize = 52;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final newest = ref.watch(newestEpisodeDateProvider(subscription.id)).value;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.rowHorizontal - Spacing.xs,
          vertical: Spacing.sm + Spacing.xxs,
        ),
        child: Row(
          children: [
            _artwork(colors),
            const SizedBox(width: Spacing.sm + Spacing.xs),
            Expanded(child: _labels(context, colors, newest)),
          ],
        ),
      ),
    );
  }

  Widget _artwork(AppColors colors) {
    final url = subscription.artworkUrl;
    final placeholder = ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.podcasts, color: colors.inkQuaternary),
    );
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
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

  Widget _labels(BuildContext context, AppColors colors, DateTime? newest) {
    final l10n = AppLocalizations.of(context);
    // Falls back to the artist until the newest episode date is known, so
    // the row never shows an empty second line.
    final meta = newest == null
        ? subscription.artistName
        : newest.toLocal().formatEpisodeDate(
            todayLabel: l10n.dateToday,
            yesterdayLabel: l10n.dateYesterday,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subscription.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
        ),
      ],
    );
  }
}
