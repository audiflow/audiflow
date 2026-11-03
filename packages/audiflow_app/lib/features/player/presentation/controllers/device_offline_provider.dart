import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_offline_provider.g.dart';

/// Whether the device has no network at all.
///
/// A failed load cannot say this itself: Android reports only "Source error",
/// whatever the cause. It tells the listener that retrying is pointless until
/// they reconnect, and updates once they do.
@riverpod
Stream<bool> deviceOffline(Ref ref) async* {
  final connectivity = Connectivity();
  yield _hasNoNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasNoNetwork);
}

bool _hasNoNetwork(List<ConnectivityResult> results) =>
    results.every((result) => result == ConnectivityResult.none);
