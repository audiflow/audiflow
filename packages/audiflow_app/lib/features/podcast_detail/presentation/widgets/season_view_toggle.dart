import 'package:flutter/material.dart';

import '../controllers/podcast_view_mode_controller.dart';

/// Segmented control for switching between Episodes and Seasons views.
class SeasonViewToggle extends StatelessWidget {
  const SeasonViewToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PodcastViewMode selected;
  final ValueChanged<PodcastViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PodcastViewMode>(
      segments: const [
        ButtonSegment(value: PodcastViewMode.episodes, label: Text('Episodes')),
        ButtonSegment(value: PodcastViewMode.seasons, label: Text('Seasons')),
      ],
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}
