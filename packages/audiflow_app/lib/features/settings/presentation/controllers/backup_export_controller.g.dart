// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupSharer)
final backupSharerProvider = BackupSharerProvider._();

final class BackupSharerProvider
    extends $FunctionalProvider<BackupSharer, BackupSharer, BackupSharer>
    with $Provider<BackupSharer> {
  BackupSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSharerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSharerHash();

  @$internal
  @override
  $ProviderElement<BackupSharer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupSharer create(Ref ref) {
    return backupSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupSharer>(value),
    );
  }
}

String _$backupSharerHash() => r'8e1048460ccc12e5c14fb9e7f2e4a9b68afd6e6d';

/// Controls the manual backup: builds the file from user state and opens
/// the share sheet (Files, AirDrop, mail).

@ProviderFor(BackupExportController)
final backupExportControllerProvider = BackupExportControllerProvider._();

/// Controls the manual backup: builds the file from user state and opens
/// the share sheet (Files, AirDrop, mail).
final class BackupExportControllerProvider
    extends $NotifierProvider<BackupExportController, BackupExportState> {
  /// Controls the manual backup: builds the file from user state and opens
  /// the share sheet (Files, AirDrop, mail).
  BackupExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupExportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupExportControllerHash();

  @$internal
  @override
  BackupExportController create() => BackupExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupExportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupExportState>(value),
    );
  }
}

String _$backupExportControllerHash() =>
    r'f9fa859873cd92f792f0eacc76babebe90e395ec';

/// Controls the manual backup: builds the file from user state and opens
/// the share sheet (Files, AirDrop, mail).

abstract class _$BackupExportController extends $Notifier<BackupExportState> {
  BackupExportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackupExportState, BackupExportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupExportState, BackupExportState>,
              BackupExportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
