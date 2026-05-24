// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_consent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether the user has accepted the privacy policy.
///
/// Backed by [AppSettingsRepository]. Read by the router redirect gate so
/// pre-consent launches surface the consent screen before any other UI.

@ProviderFor(PrivacyConsentController)
final privacyConsentControllerProvider = PrivacyConsentControllerProvider._();

/// Tracks whether the user has accepted the privacy policy.
///
/// Backed by [AppSettingsRepository]. Read by the router redirect gate so
/// pre-consent launches surface the consent screen before any other UI.
final class PrivacyConsentControllerProvider
    extends $NotifierProvider<PrivacyConsentController, bool> {
  /// Tracks whether the user has accepted the privacy policy.
  ///
  /// Backed by [AppSettingsRepository]. Read by the router redirect gate so
  /// pre-consent launches surface the consent screen before any other UI.
  PrivacyConsentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacyConsentControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacyConsentControllerHash();

  @$internal
  @override
  PrivacyConsentController create() => PrivacyConsentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$privacyConsentControllerHash() =>
    r'42a0ca296136f94027bce3d81bb87668834f7b4c';

/// Tracks whether the user has accepted the privacy policy.
///
/// Backed by [AppSettingsRepository]. Read by the router redirect gate so
/// pre-consent launches surface the consent screen before any other UI.

abstract class _$PrivacyConsentController extends $Notifier<bool> {
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
