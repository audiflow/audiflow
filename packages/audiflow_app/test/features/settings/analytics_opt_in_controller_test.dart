import 'package:audiflow_app/features/settings/presentation/controllers/analytics_opt_in_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<ProviderContainer> container(FakeAnalyticsService fake) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsServiceProvider.overrideWithValue(fake),
      ],
    );
  }

  group('analyticsOptInController', () {
    test('defaults to true when nothing is persisted', () async {
      final fake = FakeAnalyticsService();
      final c = await container(fake);
      addTearDown(c.dispose);

      check(c.read(analyticsOptInControllerProvider)).isTrue();
    });

    test('reads persisted false', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.opt_in': false,
      });
      final fake = FakeAnalyticsService();
      final c = await container(fake);
      addTearDown(c.dispose);

      check(c.read(analyticsOptInControllerProvider)).isFalse();
    });

    test(
      'setOptIn(false) persists and forwards to analytics service',
      () async {
        final fake = FakeAnalyticsService();
        final c = await container(fake);
        addTearDown(c.dispose);

        await c.read(analyticsOptInControllerProvider.notifier).setOptIn(false);

        final prefs = await SharedPreferences.getInstance();
        check(prefs.getBool('analytics.opt_in')).equals(false);
        check(fake.optIn).isFalse();
        check(c.read(analyticsOptInControllerProvider)).isFalse();
      },
    );
  });
}
