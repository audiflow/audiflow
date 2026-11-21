import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

/// Where sync stands on this device.
enum SyncPhase {
  /// This build has no relay to sync with.
  unavailable,

  /// Sync is off on this device.
  off,

  /// Sync is on but no connection is wanted (the app is in the background
  /// and not playing, plan P10).
  idle,

  /// Opening the connection and catching up.
  connecting,

  /// Caught up; changes flow both ways.
  connected,

  /// The connection failed and is retried after a pause.
  retrying,

  /// The relay refused this device; retried only when the app next comes
  /// to the foreground. [SyncStatus.failure] says why.
  failed,
}

@freezed
sealed class SyncStatus with _$SyncStatus {
  const factory SyncStatus(
    SyncPhase phase, {

    /// The `SyncRelayFailure.code` behind [SyncPhase.retrying] or
    /// [SyncPhase.failed].
    String? failure,
  }) = _SyncStatus;
}
