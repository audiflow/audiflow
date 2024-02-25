import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_state.g.dart';

@Riverpod(keepAlive: true)
class ConnectivityState extends _$ConnectivityState {
  @override
  ConnectivityResult build() {
    _listen();
    final initialState = ref.watch(initialConnectivityStateProvider);
    return initialState.valueOrNull ?? ConnectivityResult.none;
  }

  void _listen() {
    Connectivity().onConnectivityChanged.listen((result) {
      state = result;
    });
  }
}

@Riverpod(keepAlive: true)
class InitialConnectivityState extends _$InitialConnectivityState {
  @override
  Future<ConnectivityResult> build() async {
    return Connectivity().checkConnectivity();
  }
}

extension ConnectivityResultExt on ConnectivityResult {
  bool get isConnected => this != ConnectivityResult.none;
}
