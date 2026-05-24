import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'privacy_consent_controller.g.dart';

/// Tracks whether the user has accepted the privacy policy.
///
/// Backed by [AppSettingsRepository]. Read by the router redirect gate so
/// pre-consent launches surface the consent screen before any other UI.
@Riverpod(keepAlive: true)
class PrivacyConsentController extends _$PrivacyConsentController {
  @override
  bool build() {
    return ref.watch(appSettingsRepositoryProvider).getPrivacyConsentAccepted();
  }

  /// Persists acceptance and flips local state.
  Future<void> markAccepted() async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setPrivacyConsentAccepted(true);
    state = true;
  }
}
