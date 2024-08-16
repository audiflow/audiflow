import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/download/ui/download_button.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/player/ui/small_play_button.dart';
import 'package:audiflow/features/queue/ui/queue_button.dart';
import 'package:flutter/material.dart';

class EpisodeControlPanel extends StatelessWidget {
  const EpisodeControlPanel({
    required this.episode,
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SmallPlayButton(episode: episode),
        const Spacer(),
        DownloadButton(episode),
        gapW4,
        QueueButton(episode),
      ],
    );
  }
}
