import 'package:riverpod/riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/app_settings_repository_impl.dart';

part 'settings_providers.g.dart';

/// The database holding the synced settings. The app overrides it with
/// the opened database; left null (as in tests that only stub
/// SharedPreferences), every setting stays in SharedPreferences.
final syncedSettingsIsarProvider = Provider<Isar?>((ref) => null);

/// Provides a singleton [AppSettingsRepository]: synced settings in Isar,
/// device-scoped ones in SharedPreferences.
@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dataSource = SharedPreferencesDataSource(prefs);
  return AppSettingsRepositoryImpl(
    dataSource,
    isar: ref.watch(syncedSettingsIsarProvider),
  );
}
