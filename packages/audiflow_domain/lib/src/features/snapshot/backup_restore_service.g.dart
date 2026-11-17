// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_restore_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [BackupRestoreService] behind "Restore from Backup".

@ProviderFor(backupRestoreService)
final backupRestoreServiceProvider = BackupRestoreServiceProvider._();

/// Provides the [BackupRestoreService] behind "Restore from Backup".

final class BackupRestoreServiceProvider
    extends
        $FunctionalProvider<
          BackupRestoreService,
          BackupRestoreService,
          BackupRestoreService
        >
    with $Provider<BackupRestoreService> {
  /// Provides the [BackupRestoreService] behind "Restore from Backup".
  BackupRestoreServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRestoreServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRestoreServiceHash();

  @$internal
  @override
  $ProviderElement<BackupRestoreService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackupRestoreService create(Ref ref) {
    return backupRestoreService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRestoreService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRestoreService>(value),
    );
  }
}

String _$backupRestoreServiceHash() =>
    r'2c4053b8f082e8edf5518e2391068c44790603ca';
