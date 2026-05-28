import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../models/unlock_state.dart';
import '../repositories/parental_control_repository.dart';
import '../repositories/parental_control_repository_impl.dart';
import '../services/biometric_authenticator.dart';
import '../services/parental_control_gate.dart';
import '../services/pin_hasher.dart';

part 'parental_control_providers.g.dart';

/// Sink for storage errors raised by the parental-control repository.
///
/// Signature matches [ForceUpdateWarningSink] for consistency. The default
/// no-op keeps [audiflow_domain] free of monitoring dependencies. Override at
/// the composition root (audiflow_app) with a sink that forwards to Sentry.
///
/// NEVER pass plaintext PIN, salt, or hash through this sink — only the
/// exception object and its stack trace.
typedef ParentalControlErrorSink =
    void Function(String message, {Object? error, StackTrace? stackTrace});

/// Provides the [ParentalControlErrorSink] used by the repository for
/// non-fatal storage failure reporting (e.g. Sentry in production).
///
/// Default is a no-op so tests and plain domain unit-tests need no override.
@Riverpod(keepAlive: true)
ParentalControlErrorSink parentalControlErrorSink(Ref ref) {
  return (String _, {Object? error, StackTrace? stackTrace}) {};
}

/// Provides the [PinHasher] singleton used for all PIN hash and verify calls.
@Riverpod(keepAlive: true)
PinHasher pinHasher(Ref ref) => PinHasher();

/// Provides the platform [BiometricAuthenticator] implementation.
///
/// Default throws so any caller in a pure-domain test must install an explicit
/// fake. The host app overrides this at the root `ProviderContainer` with a
/// `local_auth`-backed implementation; the same override is used in widget
/// tests via a fake.
@Riverpod(keepAlive: true)
BiometricAuthenticator biometricAuthenticator(Ref ref) {
  throw UnimplementedError(
    'biometricAuthenticatorProvider must be overridden at the composition root',
  );
}

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
    analytics: ref.watch(analyticsServiceProvider),
    onError: ref.watch(parentalControlErrorSinkProvider),
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
    error: (e, st) {
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .e(
            'parentalControlSettingsStream errored; failing closed',
            error: e,
            stackTrace: st,
          );
      return true;
    },
  );
}

/// Streams whether explicit episodes should be hidden for the given podcast.
@riverpod
Stream<bool> hideExplicitForPodcast(Ref ref, int itunesId) {
  return ref
      .watch(parentalControlRepositoryProvider)
      .watchHideExplicit(itunesId);
}

/// Returns `true` when the parental-control gate is in the [Unlocked] state.
///
/// Useful for conditionally enabling gated actions without pattern-matching on
/// the full [UnlockState] sealed type.
@riverpod
bool isUnlocked(Ref ref) {
  return ref.watch(parentalControlGateProvider) is Unlocked;
}
