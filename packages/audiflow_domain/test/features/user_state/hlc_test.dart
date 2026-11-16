import 'dart:math';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

/// Property tests run each rule over many seeded random cases, so a failure
/// is reproducible from the seed in its reason.
const _seeds = 200;
const _day = 24 * 60 * 60 * 1000;
const _base = 1763251200000; // 2025-11-16

void main() {
  group('packing', () {
    test('round-trips', () {
      for (var seed = 0; seed < _seeds; seed++) {
        final random = Random(seed);
        final a = Hlc(_base + random.nextInt(_day), random.nextInt(0x10000));
        final b = Hlc(_base + random.nextInt(_day), random.nextInt(0x10000));

        expect(Hlc.unpack(a.packed), a, reason: 'seed $seed');
        expect(Hlc.unpack(b.packed), b, reason: 'seed $seed');
      }
    });

    test('holds the full 48-bit range', () {
      const top = Hlc(Hlc.maxMillis, Hlc.maxCounter);
      const high = Hlc(0x800000000000, 1);

      expect(Hlc.unpack(top.packed), top);
      expect(Hlc.unpack(high.packed), high);
      expect(high.compareTo(top), -1);
    });
  });

  group('send', () {
    test('is strictly monotonic even when the wall clock jumps back', () {
      for (var seed = 0; seed < _seeds; seed++) {
        final random = Random(seed);
        var clock = Hlc.zero;
        var now = _base;
        for (var i = 0; i < 100; i++) {
          // Mostly forward, sometimes back by up to an hour.
          now += random.nextInt(2000) - (random.nextInt(10) == 0 ? 3600000 : 0);
          final next = clock.send(now);
          expect(clock.compareTo(next), -1, reason: 'seed $seed step $i');
          clock = next;
        }
      }
    });

    test('follows the wall clock when it is ahead', () {
      expect(const Hlc(_base, 7).send(_base + 5), const Hlc(_base + 5, 0));
    });

    test('borrows the next millisecond when the counter is full', () {
      const full = Hlc(_base, Hlc.maxCounter);

      expect(full.send(_base), const Hlc(_base + 1, 0));
    });
  });

  group('receive', () {
    test('sorts after both its own clock and the remote one', () {
      for (var seed = 0; seed < _seeds; seed++) {
        final random = Random(seed);
        final now = _base + random.nextInt(_day);
        final local = Hlc(now + random.nextInt(2000) - 1000, random.nextInt(9));
        final remote = Hlc(
          now + random.nextInt(2 * _day) - _day,
          random.nextInt(9),
        );

        final next = local.receive(remote, now);

        expect(local.compareTo(next), -1, reason: 'seed $seed');
        expect(remote.compareTo(next), -1, reason: 'seed $seed');
      }
    });

    test('keeps causal order between devices with skewed clocks', () {
      for (var seed = 0; seed < _seeds; seed++) {
        final random = Random(seed);
        // Each device's wall clock is off by up to an hour either way.
        final skews = List.generate(
          3,
          (_) => random.nextInt(7200000) - 3600000,
        );
        final clocks = List.filled(3, Hlc.zero);
        var trueTime = _base;
        Hlc? lastSent;
        for (var i = 0; i < 60; i++) {
          trueTime += random.nextInt(500);
          final device = random.nextInt(3);
          final now = trueTime + skews[device];
          // A device that saw the last change makes a new one after it.
          final seen = lastSent;
          final next = seen == null
              ? clocks[device].send(now)
              : clocks[device].receive(seen, now).send(now);
          if (seen != null) {
            expect(seen.compareTo(next), -1, reason: 'seed $seed step $i');
          }
          clocks[device] = next;
          lastSent = next;
        }
      }
    });

    test('clamps a remote timestamp more than a day ahead', () {
      const now = _base;
      const broken = Hlc(now + 400 * _day, 3);

      final next = Hlc.zero.receive(broken, now);

      expect(next.millis, now + _day);
      expect(next.compareTo(broken), -1);
    });

    test('accepts a remote timestamp less than a day ahead as is', () {
      const now = _base;
      const ahead = Hlc(now + _day - 1, 3);

      expect(Hlc.zero.receive(ahead, now), const Hlc(now + _day - 1, 4));
    });
  });

  group('compareVersions', () {
    test('later timestamps win regardless of device', () {
      expect(
        compareVersions(const Hlc(2, 0), 'a', const Hlc(1, 9), 'z'),
        isPositive,
      );
    });

    test('breaks ties by device and agrees from both sides', () {
      for (var seed = 0; seed < _seeds; seed++) {
        final random = Random(seed);
        final stamp = Hlc(_base + random.nextInt(_day), random.nextInt(9));
        final a = 'device-${random.nextInt(1000)}';
        final b = 'device-${1000 + random.nextInt(1000)}';

        final ab = compareVersions(stamp, a, stamp, b);
        final ba = compareVersions(stamp, b, stamp, a);

        expect(ab, isNot(0), reason: 'seed $seed');
        expect(ab.sign, -ba.sign, reason: 'seed $seed');
      }
    });
  });
}
