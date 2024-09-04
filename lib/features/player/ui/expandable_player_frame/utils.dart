import 'dart:math' as math;

///Calculates the percentage of a value within a given range of values
double percentageFromValueInRange({
  required double min,
  required double max,
  required double value,
}) {
  return math.max(0, math.min(1, (value - min) / (max - min)));
}

double borderDouble(double value) => math.max(0, math.min(1, value));
