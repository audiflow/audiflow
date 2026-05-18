import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('InstallIdRepositoryImpl', () {
    test('getOrCreate generates and persists a UUID on first call', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      final id = await repo.getOrCreate();

      check(id).length.equals(36);
      check(prefs.getString('analytics.install_id')).equals(id);
    });

    test('returns the same UUID on subsequent calls', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      final first = await repo.getOrCreate();
      final second = await repo.getOrCreate();

      check(second).equals(first);
    });

    test('returns existing UUID if one is already persisted', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.install_id': 'existing-uuid',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      check(await repo.getOrCreate()).equals('existing-uuid');
    });
  });
}
