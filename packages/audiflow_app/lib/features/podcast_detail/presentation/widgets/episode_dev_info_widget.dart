import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/utils/open_preset_url.dart';

/// Developer-oriented grouped section at the bottom of the episode
/// detail screen (redesign 4.9).
///
/// Only rendered when [devShowDeveloperInfoProvider] is true. Shows the
/// podcast RSS feed URL (tap to copy) and a link to the matching smart
/// playlist pattern in the GitHub repo.
class EpisodeDevInfoWidget extends ConsumerWidget {
  const EpisodeDevInfoWidget({super.key, required this.feedUrl});

  final String feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(devShowDeveloperInfoProvider);
    if (!enabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final match = ref
        .watch(presetConfigRepositoryProvider)
        .findMatchingPreset(null, feedUrl);

    return GroupedSection(
      header: l10n.developerSectionLabel,
      separatorIndent: SettingsRow.separatorIndentWithIcon,
      children: [
        SettingsRow(
          icon: Symbols.content_copy,
          title: l10n.developerRssFeedUrl,
          subtitle: feedUrl,
          onTap: () => _copyFeedUrl(context),
        ),
        SettingsRow(
          icon: Symbols.playlist_play,
          title: l10n.developerPatternLabel,
          subtitle: match?.displayName ?? l10n.developerPatternNotDefined,
          trailing: const SettingsTrailing.chevron(),
          onTap: () => openPresetUrl(
            ref,
            match != null ? PresetUrls.presetDir(match.id) : PresetUrls.repo,
          ),
        ),
      ],
    );
  }

  Future<void> _copyFeedUrl(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).commonCopiedToClipboard;
    await Clipboard.setData(ClipboardData(text: feedUrl));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
