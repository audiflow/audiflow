import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/library_controller.dart';

/// Whether [newestPublishedAt] is newer than the listener's last visit to
/// the podcast, or than the subscription when it was never opened. The
/// back catalog published before subscribing never counts, and an episode
/// dated after [now] (listed ahead of time) counts only once that date
/// arrives, so a visit always clears the mark.
bool hasNewSinceVisit({
  required DateTime? newestPublishedAt,
  required DateTime? lastVisitedAt,
  required DateTime subscribedAt,
  required DateTime now,
}) {
  if (newestPublishedAt == null || now.isBefore(newestPublishedAt)) {
    return false;
  }
  return (lastVisitedAt ?? subscribedAt).isBefore(newestPublishedAt);
}

/// Row for a subscribed podcast inside the Library's grouped list:
/// artwork 52, title, the date of its newest episode, and an accent dot
/// while something arrived since the last visit (redesign 4.1).
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
          horizontal: Spacing.screenHorizontal,
          vertical: Spacing.sm + Spacing.xxs,
        ),
        child: Row(
          children: [
            _artwork(colors),
            const SizedBox(width: Spacing.sm + Spacing.xs),
            Expanded(child: _labels(context, colors, newest)),
            if (hasNewSinceVisit(
              newestPublishedAt: newest,
              lastVisitedAt: subscription.lastAccessedAt,
              subscribedAt: subscription.subscribedAt,
              now: DateTime.now(),
            ))
              _NewDot(color: colors.accent),
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

  // A bare weekday ("Mon") reads oddly without a list of dated rows around
  // it, so anything older than yesterday shows the calendar date.
  static String _formatUpdated(DateTime date, AppLocalizations l10n) {
    if (date.isToday) return l10n.dateToday;
    if (date.isYesterday) return l10n.dateYesterday;
    final pattern = date.year == DateTime.now().year
        ? DateFormat.MMMd(l10n.localeName)
        : DateFormat.yMMMd(l10n.localeName);
    return pattern.format(date);
  }

  Widget _labels(BuildContext context, AppColors colors, DateTime? newest) {
    final l10n = AppLocalizations.of(context);
    // Falls back to the artist until the newest episode date is known, so
    // the row never shows an empty second line.
    final meta = newest == null
        ? subscription.artistName
        : l10n.libraryUpdatedOn(_formatUpdated(newest.toLocal(), l10n));
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

/// Presence mark, not a count: "something new since you last looked".
class _NewDot extends StatelessWidget {
  const _NewDot({required this.color});

  final Color color;

  static const double _size = 10;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Spacing.sm),
      child: Semantics(
        label: AppLocalizations.of(context).libraryNewEpisodes,
        child: SizedBox.square(
          dimension: _size,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
