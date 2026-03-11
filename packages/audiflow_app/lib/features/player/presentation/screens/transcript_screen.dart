import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/transcript_timeline_view.dart';

/// Standalone screen for viewing an episode transcript.
class TranscriptScreen extends ConsumerWidget {
  const TranscriptScreen({
    super.key,
    required this.transcriptId,
    required this.episodeId,
    required this.episodeTitle,
  });

  final int transcriptId;
  final int episodeId;
  final String episodeTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(episodeTitle)),
      body: TranscriptTimelineView(
        transcriptId: transcriptId,
        episodeId: episodeId,
      ),
    );
  }
}
