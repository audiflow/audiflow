import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateDecision', () {
    test('NoUpdate has no payload', () {
      const decision = NoUpdate();
      check(decision).isA<UpdateDecision>();
    });

    test('SoftUpdate carries messageKey, override, url', () {
      const decision = SoftUpdate(
        messageKey: 'security_critical',
        messageOverride: {'en': 'Hi'},
        updateUrl: 'https://x',
      );
      check(decision.messageKey).equals('security_critical');
      check(decision.messageOverride!['en']).equals('Hi');
      check(decision.updateUrl).equals('https://x');
    });

    test('HardUpdate has same payload shape as SoftUpdate', () {
      const decision = HardUpdate(messageKey: 'breaking_change');
      check(decision.messageKey).equals('breaking_change');
      check(decision.messageOverride).isNull();
      check(decision.updateUrl).isNull();
    });

    test('Maintenance has same payload shape', () {
      const decision = Maintenance(messageKey: 'maintenance');
      check(decision.messageKey).equals('maintenance');
    });

    test('decisions support equality', () {
      const a = NoUpdate();
      const b = NoUpdate();
      check(a).equals(b);
    });

    test('SoftUpdate equality compares fields', () {
      const a = SoftUpdate(
        messageKey: 'k',
        messageOverride: {'en': 'x'},
        updateUrl: 'https://u',
      );
      const b = SoftUpdate(
        messageKey: 'k',
        messageOverride: {'en': 'x'},
        updateUrl: 'https://u',
      );
      check(a).equals(b);
    });

    test('Different SoftUpdates are not equal', () {
      const a = SoftUpdate(messageKey: 'a');
      const b = SoftUpdate(messageKey: 'b');
      check(a == b).equals(false);
    });
  });
}
