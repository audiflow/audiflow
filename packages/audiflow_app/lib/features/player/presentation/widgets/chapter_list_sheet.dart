import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class ChapterListSheet extends ConsumerWidget {
  const ChapterListSheet({super.key, required this.onChapterSelected});

  final ValueChanged<Duration> onChapterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chapters = ref.watch(currentEpisodeChaptersProvider).value ?? [];
    final currentIndex = ref.watch(currentChapterProvider)?.index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.playerChaptersTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: chapters.length,
            itemBuilder: (context, index) => _ChapterTile(
              number: index + 1,
              chapter: chapters[index],
              isCurrent: index == currentIndex,
              onTap: () => onChapterSelected(
                Duration(milliseconds: chapters[index].startMs),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.number,
    required this.chapter,
    required this.isCurrent,
    required this.onTap,
  });

  final int number;
  final EpisodeChapter chapter;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final startTime = formatPlaybackTime(
      Duration(milliseconds: chapter.startMs),
    );

    return Semantics(
      label: l10n.playerChapterItemLabel(number, chapter.title, startTime),
      selected: isCurrent,
      button: true,
      excludeSemantics: true,
      child: ListTile(
        selected: isCurrent,
        onTap: onTap,
        leading: Text('$number', style: textTheme.bodyMedium),
        title: Text(
          chapter.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          startTime,
          style: textTheme.bodySmall?.copyWith(
            // Fixed-width digits keep the times aligned down the list.
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
