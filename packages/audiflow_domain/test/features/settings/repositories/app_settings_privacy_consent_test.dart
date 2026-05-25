import 'package:audiflow_domain/src/common/datasources/shared_preferences_datasource.dart';
import 'package:audiflow_domain/src/features/settings/repositories/app_settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDataSource dataSource;
  late AppSettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
    repository = AppSettingsRepositoryImpl(dataSource);
  });

  group('PrivacyConsentAccepted', () {
    test('returns false when no value stored (first launch)', () {
      expect(repository.getPrivacyConsentAccepted(), isFalse);
    });

    test('persists and reads accepted=true', () async {
      await repository.setPrivacyConsentAccepted(true);
      expect(repository.getPrivacyConsentAccepted(), isTrue);
    });

    test('survives repository re-creation backed by same prefs', () async {
      await repository.setPrivacyConsentAccepted(true);

      final prefs = await SharedPreferences.getInstance();
      final reloaded = AppSettingsRepositoryImpl(
        SharedPreferencesDataSource(prefs),
      );
      expect(reloaded.getPrivacyConsentAccepted(), isTrue);
    });

    test('clearAll resets consent to false', () async {
      await repository.setPrivacyConsentAccepted(true);
      expect(repository.getPrivacyConsentAccepted(), isTrue);

      await repository.clearAll();
      expect(repository.getPrivacyConsentAccepted(), isFalse);
    });

    test('explicit set to false persists false', () async {
      await repository.setPrivacyConsentAccepted(true);
      await repository.setPrivacyConsentAccepted(false);
      expect(repository.getPrivacyConsentAccepted(), isFalse);
    });
  });
}
