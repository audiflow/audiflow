import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

ForceUpdateConfig _cfg({
  int schemaVersion = 1,
  String minVersion = '2.0.0',
  String recommendedVersion = '2.1.0',
  bool maintenanceMode = false,
  String messageKey = 'default',
  Map<String, String>? messageOverride,
  String? updateUrl,
}) => ForceUpdateConfig(
  schemaVersion: schemaVersion,
  minVersion: minVersion,
  recommendedVersion: recommendedVersion,
  maintenanceMode: maintenanceMode,
  messageKey: messageKey,
  messageOverride: messageOverride,
  updateUrl: updateUrl,
);

void main() {
  group('evaluate', () {
    test('returns Maintenance regardless of version when flag set', () {
      final result = evaluate(
        config: _cfg(maintenanceMode: true, messageKey: 'maintenance'),
        currentVersion: Version.parse('999.0.0'),
      );
      check(result).isA<Maintenance>();
      check((result as Maintenance).messageKey).equals('maintenance');
    });

    test('returns HardUpdate when current < minVersion', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('1.9.9'),
      );
      check(result).isA<HardUpdate>();
    });

    test(
      'returns SoftUpdate when minVersion <= current < recommendedVersion',
      () {
        final result = evaluate(
          config: _cfg(),
          currentVersion: Version.parse('2.0.5'),
        );
        check(result).isA<SoftUpdate>();
      },
    );

    test('returns NoUpdate when current == recommendedVersion', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('2.1.0'),
      );
      check(result).isA<NoUpdate>();
    });

    test('returns NoUpdate when recommendedVersion < current', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('3.0.0'),
      );
      check(result).isA<NoUpdate>();
    });

    test('boundary: current == minVersion is SoftUpdate (not hard)', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('2.0.0'),
      );
      check(result).isA<SoftUpdate>();
    });

    test('Hard/Soft/Maintenance carry messageKey, override, updateUrl', () {
      final result = evaluate(
        config: _cfg(
          messageKey: 'security_critical',
          messageOverride: {'en': 'x'},
          updateUrl: 'https://y',
        ),
        currentVersion: Version.parse('1.0.0'),
      );
      check(result).isA<HardUpdate>();
      final hard = result as HardUpdate;
      check(hard.messageKey).equals('security_critical');
      check(hard.messageOverride!['en']).equals('x');
      check(hard.updateUrl).equals('https://y');
    });

    test('maintenance wins over hard-update when both apply', () {
      final result = evaluate(
        config: _cfg(maintenanceMode: true, messageKey: 'maintenance'),
        currentVersion: Version.parse('1.0.0'),
      );
      check(result).isA<Maintenance>();
    });

    test(
      'pre-release (e.g. 2.0.0-rc.1) compares below 2.0.0 -> HardUpdate',
      () {
        // Documents pub_semver pre-release ordering: 2.0.0-rc.1 < 2.0.0.
        // If product wants RCs to satisfy minVersion: 2.0.0, change config to
        // 2.0.0-0 or evaluator semantics - this test pins current behavior.
        final result = evaluate(
          config: _cfg(),
          currentVersion: Version.parse('2.0.0-rc.1'),
        );
        check(result).isA<HardUpdate>();
      },
    );
  });

  group('configValidationFailure', () {
    test('returns null when config is valid', () {
      check(configValidationFailure(_cfg())).isNull();
    });

    test('returns unsupportedSchemaVersion when schemaVersion is too high', () {
      check(
        configValidationFailure(_cfg(schemaVersion: 999)),
      ).equals(ForceUpdateConfigInvalidReason.unsupportedSchemaVersion);
    });

    test('returns unparseableMinVersion when min is garbage', () {
      check(
        configValidationFailure(_cfg(minVersion: 'not-semver')),
      ).equals(ForceUpdateConfigInvalidReason.unparseableMinVersion);
    });

    test(
      'returns unparseableRecommendedVersion when recommended is garbage',
      () {
        check(
          configValidationFailure(_cfg(recommendedVersion: 'xx')),
        ).equals(ForceUpdateConfigInvalidReason.unparseableRecommendedVersion);
      },
    );

    test('returns recommendedBelowMin when rec < min', () {
      check(
        configValidationFailure(
          _cfg(minVersion: '3.0.0', recommendedVersion: '2.0.0'),
        ),
      ).equals(ForceUpdateConfigInvalidReason.recommendedBelowMin);
    });

    test('configIsValid returns true for valid config', () {
      check(configIsValid(_cfg())).equals(true);
    });

    test('configIsValid returns false for invalid config', () {
      check(configIsValid(_cfg(schemaVersion: 999))).equals(false);
    });
  });
}
