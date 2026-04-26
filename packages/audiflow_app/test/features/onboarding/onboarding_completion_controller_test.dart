import 'package:audiflow_app/features/onboarding/presentation/controllers/onboarding_completion_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingCompletionController', () {
    Future<ProviderContainer> makeContainer({bool? initialValue}) async {
      SharedPreferences.setMockInitialValues(
        initialValue == null
            ? <String, Object>{}
            : <String, Object>{
                'onboarding.carousel_completed_v1': initialValue,
              },
      );
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('defaults to false when no value persisted', () async {
      final container = await makeContainer();
      expect(container.read(onboardingCompletionControllerProvider), isFalse);
    });

    test('reads persisted true value', () async {
      final container = await makeContainer(initialValue: true);
      expect(container.read(onboardingCompletionControllerProvider), isTrue);
    });

    test('markCompleted persists and emits true', () async {
      final container = await makeContainer();
      await container
          .read(onboardingCompletionControllerProvider.notifier)
          .markCompleted();
      expect(container.read(onboardingCompletionControllerProvider), isTrue);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getBool('onboarding.carousel_completed_v1'), isTrue);
    });

    test('reset persists and emits false', () async {
      final container = await makeContainer(initialValue: true);
      await container
          .read(onboardingCompletionControllerProvider.notifier)
          .reset();
      expect(container.read(onboardingCompletionControllerProvider), isFalse);

      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getBool('onboarding.carousel_completed_v1'), isFalse);
    });
  });
}
