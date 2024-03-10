import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/services/connectivity/connectivity_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  void noticeError(NetworkError error) {
    state = AsyncData(error);
  }

  void noticeConnectivityError() {
    state = AsyncData(NoConnectivityError());
  }

  void noticeNetworkTimeoutError() {
    state = AsyncData(NetworkTimeoutError());
  }

  void noticeNetworkUnknownError() {
    state = AsyncData(NetworkUnknownError());
  }
}
