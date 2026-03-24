import 'package:audiflow_app/features/settings/presentation/controllers/last_tab_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('LastTabController', () {
    test('defaults to 0 (search)', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(lastTabControllerProvider), 0);
    });

    test('setLastTab updates state to library (1)', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(lastTabControllerProvider.notifier).setLastTab(1);

      expect(container.read(lastTabControllerProvider), 1);
    });

    test('setLastTab updates state to queue (2)', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(lastTabControllerProvider.notifier).setLastTab(2);

      expect(container.read(lastTabControllerProvider), 2);
    });

    test('setLastTab ignores settings tab (3)', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(lastTabControllerProvider.notifier).setLastTab(1);

      // Attempt to persist settings tab — should be ignored
      await container.read(lastTabControllerProvider.notifier).setLastTab(3);

      expect(container.read(lastTabControllerProvider), 1);
    });

    test('persists to SharedPreferences across containers', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(lastTabControllerProvider.notifier).setLastTab(2);

      // Fresh container should restore persisted value
      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(lastTabControllerProvider), 2);
    });

    test('reads persisted value on build', () async {
      final container1 = createContainer();
      addTearDown(container1.dispose);

      await container1.read(lastTabControllerProvider.notifier).setLastTab(1);

      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(lastTabControllerProvider), 1);
    });
  });
}
