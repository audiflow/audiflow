import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame_state.dart';
import 'package:flutter/material.dart';

//ControllerData class. Used for the controller
class ExpandablePlayerFrameControllerData {
  const ExpandablePlayerFrameControllerData(this.height, this.duration);

  final int height;
  final Duration? duration;
}

//MiniPlayerController class
class ExpandablePlayerFrameController
    extends ValueNotifier<ExpandablePlayerFrameControllerData?> {
  ExpandablePlayerFrameController() : super(null);

  //Animates to a given height or state(expanded, dismissed, ...)
  void animateToHeight({
    double? height,
    ExpandablePlayerFrameState? state,
    Duration? duration,
  }) {
    if (height == null && state == null) {
      throw Exception(
        'MiniPlayer: One of the two parameters, height or status, is required.',
      );
    }

    if (height != null && state != null) {
      throw Exception(
        'MiniPlayer: Only one of the two parameters, height or'
        ' status, can be specified.',
      );
    }

    final valBefore = value;

    if (state != null) {
      value = ExpandablePlayerFrameControllerData(state.heightCode, duration);
    } else {
      if (height! < 0) {
        return;
      }

      value = ExpandablePlayerFrameControllerData(height.round(), duration);
    }

    if (valBefore == value) {
      notifyListeners();
    }
  }
}
