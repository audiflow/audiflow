import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/exceptions/app_exception.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_manager.g.dart';

@Riverpod(keepAlive: true)
class ErrorManager extends _$ErrorManager {
  final Map<String, VoidCallback> _retries = {};

  @override
  Stream<AppException> build() async* {
    ref.listen(
        connectivityProvider.select(
          (state) =>
              state.where((c) => c != ConnectivityResult.none).isNotEmpty,
        ), (_, active) {
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

  void noticeError(NetworkException error) {
    state = AsyncData(error);
  }

  void noticeConnectivityError() {
    state = const AsyncData(NoConnectivityException());
  }

  void noticeNetworkTimeoutError() {
    state = const AsyncData(NetworkTimeoutException());
  }

  void noticeNetworkUnknownError() {
    state = const AsyncData(UnknownException());
  }
}
