// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download_keep_count_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.
///
/// Kept alive: callers fire these actions without listening, and an
/// auto-disposed controller would be torn down mid-await, making the
/// following `ref.read` throw.

@ProviderFor(AutoDownloadKeepCountController)
final autoDownloadKeepCountControllerProvider =
    AutoDownloadKeepCountControllerProvider._();

/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.
///
/// Kept alive: callers fire these actions without listening, and an
/// auto-disposed controller would be torn down mid-await, making the
/// following `ref.read` throw.
final class AutoDownloadKeepCountControllerProvider
    extends $AsyncNotifierProvider<AutoDownloadKeepCountController, void> {
  /// Changes how many unstarted auto-downloads are kept and applies the new
  /// limit right away instead of waiting for the next feed sync.
  ///
  /// Kept alive: callers fire these actions without listening, and an
  /// auto-disposed controller would be torn down mid-await, making the
  /// following `ref.read` throw.
  AutoDownloadKeepCountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoDownloadKeepCountControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoDownloadKeepCountControllerHash();

  @$internal
  @override
  AutoDownloadKeepCountController create() => AutoDownloadKeepCountController();
}

String _$autoDownloadKeepCountControllerHash() =>
    r'fff0b33e899ba7a1072838ee3e2c5326fc0eabb6';

/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.
///
/// Kept alive: callers fire these actions without listening, and an
/// auto-disposed controller would be torn down mid-await, making the
/// following `ref.read` throw.

abstract class _$AutoDownloadKeepCountController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
