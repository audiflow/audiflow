import 'dart:async';

import 'package:audiflow/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as conn;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

Future<bool> hasConnectivity() async {
  final connectivityResult = await conn.Connectivity().checkConnectivity();
  return connectivityResult.hasConnectivity;
}

Future<bool> isWifiEnabled() async {
  final connectivityResult = await conn.Connectivity().checkConnectivity();
  return connectivityResult.isWifiEnabled;
}

Future<bool> usesCellularConnection() async {
  final connectivityResult = await conn.Connectivity().checkConnectivity();
  return connectivityResult.usesCellularConnection;
}

mixin ConnectivityMixin<State> {
  AsyncNotifierProviderRef<State> get ref;

  FutureOr<void> waitForConnectivity() async {
    final completer = Completer<void>();
    ref
      ..listen(
        connectivityProvider,
        (_, state) {
          if (state.hasConnectivity && !completer.isCompleted) {
            completer.complete();
          }
        },
        fireImmediately: true,
      )
      ..onDispose(() {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    await completer.future;
  }
}

extension ConnectivityResultExt on List<conn.ConnectivityResult> {
  bool get hasConnectivity =>
      isNotEmpty && first != conn.ConnectivityResult.none;

  bool get isWifiEnabled => contains(conn.ConnectivityResult.wifi);

  bool get usesCellularConnection =>
      contains(conn.ConnectivityResult.mobile) &&
      !contains(conn.ConnectivityResult.wifi);

  bool equals(List<conn.ConnectivityResult> other) =>
      length == other.length && every(other.contains);
}

@Riverpod(keepAlive: true)
class Connectivity extends _$Connectivity {
  @override
  List<conn.ConnectivityResult> build() {
    _listen();
    final initial = ref.read(initialConnectivityProvider);
    logger.d('Connectivity: $initial');
    return initial;
  }

  void _listen() {
    final sub = conn.Connectivity().onConnectivityChanged.listen((result) {
      if (!state.equals(result)) {
        logger.d('Connectivity changed: $result');
        state = result;
      }
    });
    ref.onDispose(sub.cancel);
  }
}

@Riverpod(keepAlive: true)
List<conn.ConnectivityResult> initialConnectivity(InitialConnectivityRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
