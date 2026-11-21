import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_view_providers.g.dart';

/// [SyncController.status] as it changes.
@Riverpod(keepAlive: true)
class SyncStatusNotifier extends _$SyncStatusNotifier {
  @override
  SyncStatus build() {
    final controller = ref.watch(syncControllerProvider);
    // Subscribed before the current value is read, in the same
    // synchronous step, so no change falls in between.
    final subscription = controller.statusChanges.listen((s) => state = s);
    ref.onDispose(subscription.cancel);
    return controller.status;
  }
}

/// The account's devices as the relay last listed them.
@Riverpod(keepAlive: true)
class SyncDevicesNotifier extends _$SyncDevicesNotifier {
  @override
  List<SyncDevice> build() {
    final controller = ref.watch(syncControllerProvider);
    final subscription = controller.deviceChanges.listen((d) => state = d);
    ref.onDispose(subscription.cancel);
    return controller.devices;
  }
}
