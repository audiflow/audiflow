import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import 'chapter_list_sheet.dart';

/// "n. Title" row for the chapter at the playback position; tapping it opens
/// the chapter list.
///
/// Watches only chapter-level providers, so it rebuilds when playback
/// crosses a chapter boundary rather than on every progress tick. Renders
/// nothing for episodes without chapters.
class CurrentChapterRow extends ConsumerWidget {
  const CurrentChapterRow({super.key, required this.onChapterSelected});

  /// Called with a chapter's start position when it is picked from the list.
  final ValueChanged<Duration> onChapterSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChapters = ref.watch(
      currentEpisodeChaptersProvider.select(
        (chapters) => chapters.value?.isNotEmpty ?? false,
      ),
    );
    if (!hasChapters) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final current = ref.watch(currentChapterProvider);
    // Before the first chapter starts (an untitled lead-in) there is no
    // current chapter; the row still offers the list.
    final text = current == null
        ? l10n.playerChaptersTitle
        : '${current.number}. ${current.chapter.title}';
    final semanticsLabel = current == null
        ? l10n.playerChaptersTitle
        : l10n.playerCurrentChapterLabel(current.number, current.chapter.title);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Semantics(
        button: true,
        label: semanticsLabel,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showChapterListSheet(
            context: context,
            onChapterSelected: onChapterSelected,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: _RowContent(text: text),
          ),
        ),
      ),
    );
  }
}

class _RowContent extends StatelessWidget {
  const _RowContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Symbols.chevron_right, size: 20, color: color),
      ],
    );
  }
}
