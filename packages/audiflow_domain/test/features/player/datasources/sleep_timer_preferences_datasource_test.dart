import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SleepTimerPreferencesDatasource', () {
    test('returns zero defaults when keys absent', () {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      expect(ds.getLastMinutes(), 0);
      expect(ds.getLastEpisodes(), 0);
    });

    test('persists and reads minutes', () async {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      await ds.setLastMinutes(45);
      expect(ds.getLastMinutes(), 45);
    });

    test('persists and reads episodes', () async {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      await ds.setLastEpisodes(5);
      expect(ds.getLastEpisodes(), 5);
    });

    test('clamps stored values to supported bounds on read', () async {
      await prefs.setInt('sleep_timer.last_minutes', 10000);
      await prefs.setInt('sleep_timer.last_episodes', 1000);
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      expect(ds.getLastMinutes(), 999);
      expect(ds.getLastEpisodes(), 99);
    });
  });
}
