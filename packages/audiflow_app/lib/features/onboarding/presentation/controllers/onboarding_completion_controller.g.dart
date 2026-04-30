// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_completion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persists whether the user has finished (or skipped) the
/// first-launch onboarding carousel.
///
/// Backed by [SharedPreferences] via [sharedPreferencesProvider].
/// The key is versioned so a future major change can re-run the
/// carousel for existing users without losing the original flag.

@ProviderFor(OnboardingCompletionController)
final onboardingCompletionControllerProvider =
    OnboardingCompletionControllerProvider._();

/// Persists whether the user has finished (or skipped) the
/// first-launch onboarding carousel.
///
/// Backed by [SharedPreferences] via [sharedPreferencesProvider].
/// The key is versioned so a future major change can re-run the
/// carousel for existing users without losing the original flag.
final class OnboardingCompletionControllerProvider
    extends $NotifierProvider<OnboardingCompletionController, bool> {
  /// Persists whether the user has finished (or skipped) the
  /// first-launch onboarding carousel.
  ///
  /// Backed by [SharedPreferences] via [sharedPreferencesProvider].
  /// The key is versioned so a future major change can re-run the
  /// carousel for existing users without losing the original flag.
  OnboardingCompletionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompletionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompletionControllerHash();

  @$internal
  @override
  OnboardingCompletionController create() => OnboardingCompletionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingCompletionControllerHash() =>
    r'11ddf2fd9618dcabebd604fe4f50e7f681822591';

/// Persists whether the user has finished (or skipped) the
/// first-launch onboarding carousel.
///
/// Backed by [SharedPreferences] via [sharedPreferencesProvider].
/// The key is versioned so a future major change can re-run the
/// carousel for existing users without losing the original flag.

abstract class _$OnboardingCompletionController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
