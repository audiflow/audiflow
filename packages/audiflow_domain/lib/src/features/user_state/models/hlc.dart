/// A Hybrid Logical Clock timestamp: wall-clock milliseconds plus a logical
/// counter that orders events sharing a millisecond.
///
/// Per-field last-writer-wins needs an order that survives skewed clocks:
/// a change made after seeing another device's change must sort after it,
/// even when this device's wall clock is behind. Wall-clock time alone
/// cannot give that; the counter carries causality across devices.
///
/// The writer's `deviceId` is not part of the value. Local writes are all
/// made by this device, so it is attached where data leaves the device and
/// breaks ties between devices through [compareVersions].
final class Hlc implements Comparable<Hlc> {
  const Hlc(this.millis, this.counter)
    : assert(0 <= millis && millis <= maxMillis, 'millis out of range'),
      assert(0 <= counter && counter <= maxCounter, 'counter out of range');

  /// Restores a value written by [packed].
  factory Hlc.unpack(int packed) {
    final counter = packed & maxCounter;
    var millis = (packed - counter) ~/ _counterRange;
    // Millis from 2^47 up set the sign bit of the packed form.
    if (millis < 0) millis += _millisRange;
    return Hlc(millis, counter);
  }

  /// The clock before any event.
  static const zero = Hlc(0, 0);

  /// The largest 48-bit millisecond value, past the year 10000.
  static const maxMillis = 0xFFFFFFFFFFFF;

  /// The largest 16-bit counter value.
  static const maxCounter = 0xFFFF;

  /// How far ahead of this device's clock a remote timestamp may be.
  ///
  /// A device with a broken clock would otherwise win every merge forever.
  static const maxDrift = Duration(hours: 24);

  static const _counterRange = maxCounter + 1;
  static const _millisRange = maxMillis + 1;

  final int millis;
  final int counter;

  /// The timestamp as the 64 bits Isar stores: millis high, counter low.
  ///
  /// Millis from 2^47 up (the year 6429) wrap into the sign bit, so the
  /// packed form is for storage, not for ordering; use [compareTo].
  int get packed => millis * _counterRange + counter;

  /// Returns the timestamp for an event happening on this device now.
  ///
  /// Never moves backwards: a wall clock set back keeps the stored time and
  /// counts up instead.
  Hlc send(int nowMillis) {
    if (millis < nowMillis) return Hlc(nowMillis, 0);
    return _next(millis, counter);
  }

  /// Returns the timestamp for this device after it observes [remote].
  ///
  /// The result sorts after both this clock and [remote] (clamped, see
  /// [clampedTo]), so a change made after seeing a remote one wins over it.
  Hlc receive(Hlc remote, int nowMillis) {
    final other = remote.clampedTo(nowMillis);
    final wall = _max(_max(millis, other.millis), nowMillis);
    final ownWall = wall == millis;
    final otherWall = wall == other.millis;
    if (ownWall && otherWall) {
      return _next(wall, _max(counter, other.counter));
    }
    if (ownWall) return _next(wall, counter);
    if (otherWall) return _next(wall, other.counter);
    return Hlc(wall, 0);
  }

  /// Returns this timestamp limited to [maxDrift] past [nowMillis].
  Hlc clampedTo(int nowMillis) {
    final limit = nowMillis + maxDrift.inMilliseconds;
    if (millis <= limit) return this;
    return Hlc(limit, 0);
  }

  static Hlc _next(int millis, int counter) {
    if (counter < maxCounter) return Hlc(millis, counter + 1);
    // A full counter borrows the next millisecond rather than wrapping,
    // which would sort before the timestamp it follows.
    return Hlc(millis + 1, 0);
  }

  static int _max(int a, int b) => a < b ? b : a;

  @override
  int compareTo(Hlc other) {
    final byMillis = millis.compareTo(other.millis);
    if (byMillis != 0) return byMillis;
    return counter.compareTo(other.counter);
  }

  @override
  bool operator ==(Object other) =>
      other is Hlc && other.millis == millis && other.counter == counter;

  @override
  int get hashCode => packed.hashCode;

  @override
  String toString() => 'Hlc($millis, $counter)';
}

/// Orders two versions of a value written by possibly different devices.
///
/// Later [Hlc]s win; equal timestamps from different devices are broken by
/// `deviceId`, so every device picks the same winner.
int compareVersions(Hlc a, String deviceA, Hlc b, String deviceB) {
  final byTime = a.compareTo(b);
  if (byTime != 0) return byTime;
  return deviceA.compareTo(deviceB);
}
