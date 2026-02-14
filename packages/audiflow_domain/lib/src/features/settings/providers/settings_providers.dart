import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/app_settings_repository_impl.dart';

part 'settings_providers.g.dart';

/// Provides a singleton [AppSettingsRepository] backed by
/// SharedPreferences.
@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dataSource = SharedPreferencesDataSource(prefs);
  return AppSettingsRepositoryImpl(dataSource);
}
