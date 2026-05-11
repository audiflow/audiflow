import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/podcast_detail_controller.dart';

Future<void> showPodcastDescriptionSheet({
  required BuildContext context,
  required Podcast podcast,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (sheetContext) => _PodcastDescriptionSheet(podcast: podcast),
  );
}

class _PodcastDescriptionSheet extends ConsumerWidget {
  const _PodcastDescriptionSheet({required this.podcast});

  final Podcast podcast;

  String _resolveDescription(WidgetRef ref) {
    final feedUrl = podcast.feedUrl;
    final feed = feedUrl == null
        ? null
        : ref.watch(podcastDetailProvider(feedUrl)).value?.podcast;

    for (final candidate in [
      feed?.description,
      feed?.summary,
      feed?.subtitle,
      podcast.description,
    ]) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final description = _resolveDescription(ref);

    return FractionallySizedBox(
      heightFactor: 1,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            podcast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          top: false,
          child: description.isEmpty
              ? Center(
                  child: Text(
                    l10n.podcastDetailNoDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: SelectionArea(
                    child: Html(
                      data: description.plainTextToHtml.linkifyUrls,
                      onLinkTap: (url, attributes, element) async {
                        if (url == null || url.isEmpty) return;
                        final uri = Uri.tryParse(url);
                        if (uri == null) return;
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.inAppBrowserView,
                        );
                        if (!launched) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
