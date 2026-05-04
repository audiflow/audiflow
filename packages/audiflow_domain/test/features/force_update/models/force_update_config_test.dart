import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForceUpdateConfig.fromJson', () {
    test('parses minimal valid payload', () {
      final json = {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': false,
        'message_key': 'default',
      };

      final cfg = ForceUpdateConfig.fromJson(json);

      check(cfg.schemaVersion).equals(1);
      check(cfg.minVersion).equals('2.0.0');
      check(cfg.recommendedVersion).equals('2.1.0');
      check(cfg.maintenanceMode).equals(false);
      check(cfg.messageKey).equals('default');
      check(cfg.messageOverride).isNull();
      check(cfg.updateUrl).isNull();
    });

    test('parses full payload with override and url', () {
      final json = {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': true,
        'message_key': 'security_critical',
        'message_override': {'en': 'Update', 'ja': 'アップデート'},
        'update_url': 'https://example.com/update',
      };

      final cfg = ForceUpdateConfig.fromJson(json);

      check(cfg.maintenanceMode).equals(true);
      check(cfg.messageOverride!['en']).equals('Update');
      check(cfg.messageOverride!['ja']).equals('アップデート');
      check(cfg.updateUrl).equals('https://example.com/update');
    });

    test('round-trips via toJson', () {
      final original = ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      );

      final restored = ForceUpdateConfig.fromJson(original.toJson());

      check(restored).equals(original);
    });
  });
}
