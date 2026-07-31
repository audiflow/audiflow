import '../datasources/local/force_update_local_data_source.dart';
import '../datasources/remote/force_update_remote_data_source.dart';
import '../models/force_update_config.dart';
import '../services/force_update_evaluator.dart';
import 'force_update_repository.dart';

/// Default implementation that prefers a fresh remote config but falls
/// back to the local cache when the network or the payload is bad.
class ForceUpdateRepositoryImpl implements ForceUpdateRepository {
  ForceUpdateRepositoryImpl({
    required this._remote,
    required this._local,
    this._onWarning,
    this._now = _utcNow,
  });

  final ForceUpdateRemoteDataSource _remote;
  final ForceUpdateLocalDataSource _local;
  final ForceUpdateWarningSink? _onWarning;
  final DateTime Function() _now;

  @override
  Future<ForceUpdateConfig?> refresh() async {
    try {
      final fresh = await _remote.fetch();
      final failure = configValidationFailure(fresh);
      if (failure == null) {
        await _local.write(fresh, fetchedAt: _now());
        return fresh;
      }
      _onWarning?.call('Force-update config rejected: ${failure.name}');
    } catch (e, stack) {
      _onWarning?.call(
        'Force-update fetch failed',
        error: e,
        stackTrace: stack,
      );
    }
    return readCachedOnly();
  }

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async {
    final cached = await _local.read();
    if (cached == null) return null;
    if (!configIsValid(cached)) return null;
    return cached;
  }

  @override
  DateTime? lastFetchAt() => _local.lastFetchAt();
}

DateTime _utcNow() => DateTime.now().toUtc();
