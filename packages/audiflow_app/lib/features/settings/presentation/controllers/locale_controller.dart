import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

/// Controls the app-wide UI language.
///
/// `null` means "follow the device locale". The root [MaterialApp] watches
/// this so a change applies immediately, without a restart.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    final languageCode = repo.getLocale();
    return languageCode == null ? null : Locale(languageCode);
  }

  /// Persists [locale] (or clears it for `null`) and updates the state.
  Future<void> setLocale(Locale? locale) async {
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setLocale(locale?.languageCode);
    state = locale;
  }
}
