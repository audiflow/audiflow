import 'package:audiflow_domain/src/features/parental_control/models/unlock_state.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnlockState', () {
    test('Locked is const', () {
      check(const Locked()).equals(const Locked());
    });

    test('Unlocked carries expiresAt', () {
      final t = DateTime.utc(2026, 5, 28, 12, 0);
      final s = Unlocked(expiresAt: t);
      check(s.expiresAt).equals(t);
    });

    test('LockedOut carries retryAt and attemptCount', () {
      final t = DateTime.utc(2026, 5, 28, 12, 5);
      final s = LockedOut(retryAt: t, attemptCount: 7);
      check(s.retryAt).equals(t);
      check(s.attemptCount).equals(7);
    });

    test('switch covers all cases (exhaustive)', () {
      const UnlockState s = Locked();
      final result = switch (s) {
        Locked() => 'locked',
        Unlocked() => 'unlocked',
        LockedOut() => 'lockedOut',
      };
      check(result).equals('locked');
    });
  });
}
