import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_state.g.dart';

@Riverpod(keepAlive: true)
class ConnectivityState extends _$ConnectivityState {
  final _log = Logger('ConnectivityState');

  @override
  List<ConnectivityResult> build() {
    _listen();
    final initialState = ref.watch(initialConnectivityStateProvider);
    return initialState.valueOrNull ?? [];
  }

  void _listen() {
    final sub = Connectivity().onConnectivityChanged.listen((result) {
      if (state != result) {
        _log.fine('Connectivity changed: $result');
        state = result;
      }
    });
    ref.onDispose(sub.cancel);
  }
}

@Riverpod(keepAlive: true)
class InitialConnectivityState extends _$InitialConnectivityState {
  @override
  Future<List<ConnectivityResult>> build() async {
    return Connectivity().checkConnectivity();
  }
}

extension ConnectivityResultExt on List<ConnectivityResult> {
  bool get isConnected => isNotEmpty && first != ConnectivityResult.none;
}
