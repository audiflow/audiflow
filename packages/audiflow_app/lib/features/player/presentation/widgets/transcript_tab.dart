import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'transcript_timeline_view.dart';

/// Tab content that lazily fetches and displays a transcript.
///
/// Triggers [TranscriptService.ensureContent] to download the transcript
/// on first display, then renders a [TranscriptTimelineView] once ready.
class TranscriptTab extends ConsumerStatefulWidget {
  const TranscriptTab({required this.episodeId, super.key});

  final int episodeId;

  @override
  ConsumerState<TranscriptTab> createState() => _TranscriptTabState();
}

class _TranscriptTabState extends ConsumerState<TranscriptTab> {
  late final Future<int?> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = ref
        .read(transcriptServiceProvider)
        .ensureContent(widget.episodeId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<int?>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.playerTranscriptLoading),
              ],
            ),
          );
        }

        final transcriptId = snapshot.data;
        if (transcriptId == null) {
          return Center(child: Text(l10n.playerTranscriptEmpty));
        }

        return TranscriptTimelineView(
          transcriptId: transcriptId,
          episodeId: widget.episodeId,
        );
      },
    );
  }
}
