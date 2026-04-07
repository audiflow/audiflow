import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/platform_providers.dart';

part 'developer_settings_provider.g.dart';

/// SharedPreferences key for the developer info toggle.
const _key = 'dev_show_developer_info';

/// Controls visibility of developer info in episode detail screens.
///
/// Backed by SharedPreferences. Defaults to false.
@Riverpod(keepAlive: true)
class DevShowDeveloperInfo extends _$DevShowDeveloperInfo {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  /// Toggles the current value and persists it.
  ///
  /// Only updates in-memory state after the write succeeds,
  /// preventing divergence when the disk write fails.
  Future<void> toggle() async {
    final next = !state;
    final ok = await ref.read(sharedPreferencesProvider).setBool(_key, next);
    if (!ok) return;
    state = next;
  }
}
