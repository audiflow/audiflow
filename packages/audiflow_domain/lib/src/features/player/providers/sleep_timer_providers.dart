import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../datasources/local/sleep_timer_preferences_datasource.dart';

part 'sleep_timer_providers.g.dart';

/// Backs [SleepTimerController]'s persistence of remembered
/// minutes/episodes values.
@Riverpod(keepAlive: true)
SleepTimerPreferencesDatasource sleepTimerPreferencesDatasource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SleepTimerPreferencesDatasource(SharedPreferencesDataSource(prefs));
}
