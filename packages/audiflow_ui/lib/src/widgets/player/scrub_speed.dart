/// How fast a seek bar drag moves the position relative to the finger.
///
/// The speed is chosen by how far the finger has moved vertically away from
/// the track: the further away, the finer the adjustment.
enum ScrubSpeed {
  full(1.0),
  half(0.5),
  quarter(0.25),
  fine(0.125);

  const ScrubSpeed(this.factor);

  /// Multiplier applied to horizontal finger travel.
  final double factor;

  /// Vertical span, in logical pixels, covered by each speed band.
  static const double bandHeight = 50.0;
}

/// Returns the scrub speed for a finger [dy] logical pixels above (negative)
/// or below (positive) the track. Moving up or down behaves the same.
ScrubSpeed scrubSpeedForDistance(double dy) {
  final distance = dy.abs();
  if (distance < ScrubSpeed.bandHeight) return ScrubSpeed.full;
  if (distance < ScrubSpeed.bandHeight * 2) return ScrubSpeed.half;
  if (distance < ScrubSpeed.bandHeight * 3) return ScrubSpeed.quarter;
  return ScrubSpeed.fine;
}

/// Multiplier applied to horizontal drag travel when the finger is [dy]
/// logical pixels away from the track; see [scrubSpeedForDistance].
double scrubFactorForDistance(double dy) => scrubSpeedForDistance(dy).factor;
