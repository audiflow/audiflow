Duration minDuration(Duration a, Duration b) {
  return a < b ? a : b;
}

Duration maxDuration(Duration a, Duration b) {
  return b < a ? a : b;
}

Duration? normalizedDuration({
  Duration? position,
  Duration? duration,
}) {
  return position == null || duration == null
      ? Duration.zero
      : maxDuration(Duration.zero, minDuration(position, duration));
}
