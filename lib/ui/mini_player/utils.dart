import 'dart:math' as math;

import 'package:seasoning/ui/mini_player/mini_player.dart';

extension SelectedColorExtension on PanelState {
  int get heightCode {
    switch (this) {
      case PanelState.min:
        return -1;
      case PanelState.max:
        return -2;
      case PanelState.dismiss:
        return -3;
    }
  }
}

///Calculates the percentage of a value within a given range of values
double percentageFromValueInRange({
  required double min,
  required double max,
  required double value,
}) {
  return math.max(0, math.min(1, (value - min) / (max - min)));
}

double borderDouble(double value) => math.max(0, math.min(1, value));
