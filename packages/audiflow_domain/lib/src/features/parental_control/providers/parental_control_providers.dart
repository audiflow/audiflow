import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../repositories/parental_control_repository.dart';
import '../repositories/parental_control_repository_impl.dart';
import '../services/pin_hasher.dart';

part 'parental_control_providers.g.dart';

/// Provides the [PinHasher] singleton used for all PIN hash and verify calls.
@Riverpod(keepAlive: true)
PinHasher pinHasher(Ref ref) => PinHasher();

/// Provides the local data source backed by Isar for parental-control storage.
@Riverpod(keepAlive: true)
ParentalControlLocalDataSource parentalControlLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider);
  return ParentalControlLocalDataSource(isar: isar);
}

/// Provides the [ParentalControlRepository] implementation.
@Riverpod(keepAlive: true)
ParentalControlRepository parentalControlRepository(Ref ref) {
  return ParentalControlRepositoryImpl(
    datasource: ref.watch(parentalControlLocalDataSourceProvider),
    hasher: ref.watch(pinHasherProvider),
    logger: ref.watch(namedLoggerProvider('ParentalControl')),
  );
}

/// Streams the full [ParentalControlSettings] singleton from Isar.
@Riverpod(keepAlive: true)
Stream<ParentalControlSettings> parentalControlSettingsStream(Ref ref) {
  return ref.watch(parentalControlRepositoryProvider).watchSettings();
}

/// Returns whether Restricted Mode is currently active.
///
/// Fails closed (returns `true`) during initial stream loading and on storage
/// errors so that content is never accidentally exposed while state is unknown.
@riverpod
bool isRestrictedModeOn(Ref ref) {
  final s = ref.watch(parentalControlSettingsStreamProvider);
  return s.when(
    data: (v) => v.restrictedModeEnabled,
    loading: () => true, // fail-closed during initial load
    error: (_, _) => true, // fail-closed on storage error
  );
}

/// Streams whether explicit episodes should be hidden for the given podcast.
@riverpod
Stream<bool> hideExplicitForPodcast(Ref ref, int itunesId) {
  return ref
      .watch(parentalControlRepositoryProvider)
      .watchHideExplicit(itunesId);
}
