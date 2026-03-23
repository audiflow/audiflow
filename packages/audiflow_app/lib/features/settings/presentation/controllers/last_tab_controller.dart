import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_tab_controller.g.dart';

/// Controls the persisted last-selected tab index.
///
/// Only tabs 0-2 (search, library, queue) are persisted.
/// The settings tab (index 3) is not persisted.
@Riverpod(keepAlive: true)
class LastTabController extends _$LastTabController {
  @override
  int build() {
    final repo = ref.watch(appSettingsRepositoryProvider);
    return repo.getLastTabIndex();
  }

  /// Persists [index] if it is a persistable tab (0-2).
  /// Ignores settings tab (3) and out-of-range values.
  Future<void> setLastTab(int index) async {
    if (index < 0 || SettingsDefaults.maxPersistableTabIndex < index) return;
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.setLastTabIndex(index);
    state = index;
  }
}
