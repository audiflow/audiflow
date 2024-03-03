import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/services/connectivity/connectivity_state.dart';

part 'error_manager.g.dart';

@Riverpod(keepAlive: true)
class ErrorManager extends _$ErrorManager {
  final Map<String, VoidCallback> _retries = {};

  @override
  Stream<NetworkError> build() async* {
    ref.listen(
        connectivityStateProvider
            .select((state) => state != ConnectivityResult.none), (_, active) {
      if (active) {
        _runRetries();
      }
    });
  }

  void _runRetries() {
    final retries = _retries.values;
    _retries.clear();
    for (final retry in retries) {
      try {
        retry();
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
    }
  }

  void retryOnReconnect({
    required String key,
    required VoidCallback retry,
  }) {
    _retries[key] = retry;
  }

  void unregisterRetry(String key) {
    _retries.remove(key);
  }

  void clear() {
    _retries.clear();
  }

  void noticeConnectivityError() {
    state = const AsyncData(NetworkError.connectivity());
  }

  void noticeNetworkTimeoutError() {
    state = const AsyncData(NetworkError.timeout());
  }

  void noticeNetworkUnknownError() {
    state = const AsyncData(NetworkError.unknown());
  }
}
