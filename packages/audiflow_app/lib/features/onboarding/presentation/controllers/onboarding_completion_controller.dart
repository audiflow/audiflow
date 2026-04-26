import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_completion_controller.g.dart';

const _kOnboardingCompletedKey = 'onboarding.carousel_completed_v1';

/// Persists whether the user has finished (or skipped) the
/// first-launch onboarding carousel.
///
/// Backed by [SharedPreferences] via [sharedPreferencesProvider].
/// The key is versioned so a future major change can re-run the
/// carousel for existing users without losing the original flag.
@Riverpod(keepAlive: true)
class OnboardingCompletionController extends _$OnboardingCompletionController {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_kOnboardingCompletedKey) ?? false;
  }

  /// Marks onboarding as complete and persists the flag.
  Future<void> markCompleted() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final ok = await prefs.setBool(_kOnboardingCompletedKey, true);
    if (!ok) return;
    state = true;
  }

  /// Resets onboarding so the carousel runs again on next entry.
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final ok = await prefs.setBool(_kOnboardingCompletedKey, false);
    if (!ok) return;
    state = false;
  }
}
