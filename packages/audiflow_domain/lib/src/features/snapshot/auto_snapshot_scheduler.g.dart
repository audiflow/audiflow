// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_snapshot_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [AutoSnapshotScheduler] the app calls on moving to the
/// background.

@ProviderFor(autoSnapshotScheduler)
final autoSnapshotSchedulerProvider = AutoSnapshotSchedulerProvider._();

/// Provides the [AutoSnapshotScheduler] the app calls on moving to the
/// background.

final class AutoSnapshotSchedulerProvider
    extends
        $FunctionalProvider<
          AutoSnapshotScheduler,
          AutoSnapshotScheduler,
          AutoSnapshotScheduler
        >
    with $Provider<AutoSnapshotScheduler> {
  /// Provides the [AutoSnapshotScheduler] the app calls on moving to the
  /// background.
  AutoSnapshotSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSnapshotSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSnapshotSchedulerHash();

  @$internal
  @override
  $ProviderElement<AutoSnapshotScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AutoSnapshotScheduler create(Ref ref) {
    return autoSnapshotScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AutoSnapshotScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AutoSnapshotScheduler>(value),
    );
  }
}

String _$autoSnapshotSchedulerHash() =>
    r'0969a3fffae7871fe68f0d2046b450ea4ca9cc68';
