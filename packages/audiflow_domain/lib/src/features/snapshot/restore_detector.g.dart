// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_detector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [RestoreDetector] run once at launch.

@ProviderFor(restoreDetector)
final restoreDetectorProvider = RestoreDetectorProvider._();

/// Provides the [RestoreDetector] run once at launch.

final class RestoreDetectorProvider
    extends
        $FunctionalProvider<RestoreDetector, RestoreDetector, RestoreDetector>
    with $Provider<RestoreDetector> {
  /// Provides the [RestoreDetector] run once at launch.
  RestoreDetectorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreDetectorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreDetectorHash();

  @$internal
  @override
  $ProviderElement<RestoreDetector> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RestoreDetector create(Ref ref) {
    return restoreDetector(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreDetector value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreDetector>(value),
    );
  }
}

String _$restoreDetectorHash() => r'81e6c4418c2f9509d8afef5f9a4dab472a319743';

/// Provides the [ContinuityRestoreNotice] the launch restore raises.

@ProviderFor(continuityRestoreNotice)
final continuityRestoreNoticeProvider = ContinuityRestoreNoticeProvider._();

/// Provides the [ContinuityRestoreNotice] the launch restore raises.

final class ContinuityRestoreNoticeProvider
    extends
        $FunctionalProvider<
          ContinuityRestoreNotice,
          ContinuityRestoreNotice,
          ContinuityRestoreNotice
        >
    with $Provider<ContinuityRestoreNotice> {
  /// Provides the [ContinuityRestoreNotice] the launch restore raises.
  ContinuityRestoreNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continuityRestoreNoticeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continuityRestoreNoticeHash();

  @$internal
  @override
  $ProviderElement<ContinuityRestoreNotice> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContinuityRestoreNotice create(Ref ref) {
    return continuityRestoreNotice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContinuityRestoreNotice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContinuityRestoreNotice>(value),
    );
  }
}

String _$continuityRestoreNoticeHash() =>
    r'515cba1f26ce77f65fdda3ac4941865e49e046f3';
