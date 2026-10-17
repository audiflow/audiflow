import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../helpers/playback_time_format.dart';

/// Opens the chapter list for the now-playing episode.
///
/// Selecting a chapter closes the sheet and calls [onChapterSelected] with
/// the chapter's start position.
Future<void> showChapterListSheet({
  required BuildContext context,
  required ValueChanged<Duration> onChapterSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => ChapterListSheet(
      onChapterSelected: (position) {
        Navigator.of(sheetContext).pop();
        onChapterSelected(position);
      },
    ),
  );
}

/// Lists every chapter with its start time, highlighting the current one.
///
/// Opens scrolled so the current chapter is in view; the highlight then
/// follows playback without moving the list under the listener's finger.
class ChapterListSheet extends ConsumerStatefulWidget {
  const ChapterListSheet({super.key, required this.onChapterSelected});

  final ValueChanged<Duration> onChapterSelected;

  @override
  ConsumerState<ChapterListSheet> createState() => _ChapterListSheetState();
}

class _ChapterListSheetState extends ConsumerState<ChapterListSheet> {
  /// Places the current chapter about a third of the way down, so the
  /// chapters before it stay in sight for jumping back.
  static const double _revealAlignment = 0.3;

  final GlobalKey _currentTileKey = GlobalKey();
  bool _revealHandled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chapters =
        ref.watch(currentEpisodeChaptersProvider).unwrapPrevious().value ?? [];
    final currentIndex = ref.watch(currentChapterProvider)?.index;
    if (chapters.isNotEmpty) _scheduleRevealOnce();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Text(
            l10n.playerChaptersTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Flexible(child: _list(context, chapters, currentIndex)),
      ],
    );
  }

  // Built eagerly rather than lazily: chapter lists are short, and every
  // tile must be laid out for the current one to be scrolled into view.
  Widget _list(
    BuildContext context,
    List<EpisodeChapter> chapters,
    int? currentIndex,
  ) {
    return SingleChildScrollView(
      // The modal leaves the bottom inset to its content; keep the last
      // chapter clear of the home indicator.
      padding: EdgeInsets.fromLTRB(
        Spacing.sm,
        0,
        Spacing.sm,
        MediaQuery.paddingOf(context).bottom,
      ),
      // Tile tints paint on the nearest Material; one inside the scroll
      // view keeps them clipped to the list instead of the whole sheet.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (final (index, chapter) in chapters.indexed)
              _ChapterTile(
                key: index == currentIndex ? _currentTileKey : null,
                number: index + 1,
                chapter: chapter,
                isCurrent: index == currentIndex,
                onTap: () => widget.onChapterSelected(
                  Duration(milliseconds: chapter.startMs),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Decides the opening scroll once, on the first frame with chapters:
  /// brings the current chapter into view, or stays at the top when none is
  /// current yet. Later chapter changes only move the highlight, so the
  /// list never jumps under the listener's finger.
  void _scheduleRevealOnce() {
    if (_revealHandled) return;
    _revealHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tileContext = _currentTileKey.currentContext;
      if (!mounted || tileContext == null) return;
      Scrollable.ensureVisible(tileContext, alignment: _revealAlignment);
    });
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    super.key,
    required this.number,
    required this.chapter,
    required this.isCurrent,
    required this.onTap,
  });

  /// Matches the leading number column, so titles line up on every row.
  static const double _leadingWidth = 24;
  static const double _playingIconSize = 20;

  final int number;
  final EpisodeChapter chapter;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final startTime = formatPlaybackTime(
      Duration(milliseconds: chapter.startMs),
    );

    return Semantics(
      label: l10n.playerChapterItemLabel(number, chapter.title, startTime),
      selected: isCurrent,
      button: true,
      // The tile's own tap action is excluded with its text, so re-expose it.
      onTap: onTap,
      excludeSemantics: true,
      child: ListTile(
        selected: isCurrent,
        selectedColor: colors.accent,
        selectedTileColor: colors.accentTint,
        shape: const RoundedRectangleBorder(borderRadius: AppBorders.md),
        onTap: onTap,
        leading: _leading(colors),
        title: Text(
          chapter.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: isCurrent ? AppTextStyles.rowTitle : AppTextStyles.body,
        ),
        trailing: Text(startTime, style: _timeStyle(colors)),
      ),
    );
  }

  Widget _leading(AppColors colors) {
    // A minimum rather than a fixed width, so large accessibility text
    // widens the column instead of wrapping the digits.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: _leadingWidth),
      child: isCurrent
          ? Icon(
              Symbols.graphic_eq,
              size: _playingIconSize,
              color: colors.accent,
            )
          : Text(
              '$number',
              textAlign: TextAlign.center,
              style: AppTextStyles.tabular(
                AppTextStyles.meta,
              ).copyWith(color: colors.inkSecondary),
            ),
    );
  }

  // Fixed-width digits keep the times aligned down the list.
  TextStyle _timeStyle(AppColors colors) {
    return AppTextStyles.tabular(AppTextStyles.meta).copyWith(
      color: isCurrent ? colors.accent : colors.inkSecondary,
      fontWeight: isCurrent ? FontWeight.w600 : null,
    );
  }
}
