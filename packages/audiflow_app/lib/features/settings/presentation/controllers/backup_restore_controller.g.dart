// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_restore_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls "Restore from Backup": picks and validates a file, then merges
/// it once the user has confirmed.

@ProviderFor(BackupRestoreController)
final backupRestoreControllerProvider = BackupRestoreControllerProvider._();

/// Controls "Restore from Backup": picks and validates a file, then merges
/// it once the user has confirmed.
final class BackupRestoreControllerProvider
    extends $NotifierProvider<BackupRestoreController, BackupRestoreState> {
  /// Controls "Restore from Backup": picks and validates a file, then merges
  /// it once the user has confirmed.
  BackupRestoreControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRestoreControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRestoreControllerHash();

  @$internal
  @override
  BackupRestoreController create() => BackupRestoreController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRestoreState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRestoreState>(value),
    );
  }
}

String _$backupRestoreControllerHash() =>
    r'772b7edd94fa2745bf4823cda95e2ff6e81fd156';

/// Controls "Restore from Backup": picks and validates a file, then merges
/// it once the user has confirmed.

abstract class _$BackupRestoreController extends $Notifier<BackupRestoreState> {
  BackupRestoreState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupRestoreState, BackupRestoreState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupRestoreState, BackupRestoreState>,
              BackupRestoreState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
