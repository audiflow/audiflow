import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_view_providers.g.dart';

/// [SyncController.status], starting with the current value so a screen
/// opened mid-session does not wait for the next change.
@Riverpod(keepAlive: true)
Stream<SyncStatus> syncStatus(Ref ref) {
  final controller = ref.watch(syncControllerProvider);
  return _currentThenChanges(() => controller.status, controller.statusChanges);
}

/// The account's devices as the relay last listed them.
@Riverpod(keepAlive: true)
Stream<List<SyncDevice>> syncDevices(Ref ref) {
  final controller = ref.watch(syncControllerProvider);
  return _currentThenChanges(
    () => controller.devices,
    controller.deviceChanges,
  );
}

// Subscribes before reading the current value, so a change landing in
// between is delivered instead of lost.
Stream<T> _currentThenChanges<T>(T Function() current, Stream<T> changes) =>
    Stream.multi((sink) {
      final subscription = changes.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );
      sink
        ..add(current())
        ..onCancel = subscription.cancel;
    });
