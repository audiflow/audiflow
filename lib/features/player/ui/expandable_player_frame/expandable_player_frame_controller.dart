import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame.dart';
import 'package:flutter/material.dart';

//ControllerData class. Used for the controller
class ControllerData {
  const ControllerData(this.height, this.duration);

  final int height;
  final Duration? duration;
}

//MiniPlayerController class
class MiniPlayerController extends ValueNotifier<ControllerData?> {
  MiniPlayerController() : super(null);

  //Animates to a given height or state(expanded, dismissed, ...)
  void animateToHeight({
    double? height,
    PanelState? state,
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
      value = ControllerData(state.heightCode, duration);
    } else {
      if (height! < 0) {
        return;
      }

      value = ControllerData(height.round(), duration);
    }

    if (valBefore == value) {
      notifyListeners();
    }
  }
}
