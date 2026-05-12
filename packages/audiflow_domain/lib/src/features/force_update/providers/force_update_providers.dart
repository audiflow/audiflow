import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../datasources/local/force_update_local_data_source.dart';
import '../datasources/remote/force_update_remote_data_source.dart';
import '../repositories/force_update_repository.dart';
import '../repositories/force_update_repository_impl.dart';

part 'force_update_providers.g.dart';

/// Endpoint that serves the force-update JSON.
///
/// Override at the composition root with
/// `String.fromEnvironment('FORCE_UPDATE_CONFIG_URL')`. Throwing by
/// default surfaces missing overrides during boot instead of failing
/// silently later.
@Riverpod(keepAlive: true)
String forceUpdateConfigUrl(Ref ref) {
  throw UnimplementedError(
    'forceUpdateConfigUrlProvider must be overridden at startup',
  );
}

/// Sink for non-fatal warnings raised by the force-update repository
/// (failed fetch, invalid payload, etc).
///
/// The default is a no-op so the domain layer stays free of monitoring
/// dependencies. The composition root (audiflow_app) overrides this
/// provider with a sink that forwards to logger + Sentry.
@Riverpod(keepAlive: true)
ForceUpdateWarningSink forceUpdateWarningSink(Ref ref) {
  return (String _, {Object? error, StackTrace? stackTrace}) {};
}

/// Singleton [ForceUpdateRepository] wired to the shared Dio + prefs.
@Riverpod(keepAlive: true)
ForceUpdateRepository forceUpdateRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final url = ref.watch(forceUpdateConfigUrlProvider);
  final sink = ref.watch(forceUpdateWarningSinkProvider);
  return ForceUpdateRepositoryImpl(
    remote: ForceUpdateRemoteDataSource(dio: dio, configUrl: url),
    local: ForceUpdateLocalDataSource(prefs),
    onWarning: sink,
  );
}
