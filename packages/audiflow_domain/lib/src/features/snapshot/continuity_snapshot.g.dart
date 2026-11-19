// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuity_snapshot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The snapshot lives in Application Support: backed up on iOS, and the
/// `file` domain the Android backup rules keep on Android.

@ProviderFor(continuitySnapshotPath)
final continuitySnapshotPathProvider = ContinuitySnapshotPathProvider._();

/// The snapshot lives in Application Support: backed up on iOS, and the
/// `file` domain the Android backup rules keep on Android.

final class ContinuitySnapshotPathProvider
    extends
        $FunctionalProvider<
          ContinuitySnapshotPathResolver,
          ContinuitySnapshotPathResolver,
          ContinuitySnapshotPathResolver
        >
    with $Provider<ContinuitySnapshotPathResolver> {
  /// The snapshot lives in Application Support: backed up on iOS, and the
  /// `file` domain the Android backup rules keep on Android.
  ContinuitySnapshotPathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continuitySnapshotPathProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continuitySnapshotPathHash();

  @$internal
  @override
  $ProviderElement<ContinuitySnapshotPathResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContinuitySnapshotPathResolver create(Ref ref) {
    return continuitySnapshotPath(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContinuitySnapshotPathResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContinuitySnapshotPathResolver>(
        value,
      ),
    );
  }
}

String _$continuitySnapshotPathHash() =>
    r'1c590561a1ed099c846aba2087d602fd4d31bd5b';
