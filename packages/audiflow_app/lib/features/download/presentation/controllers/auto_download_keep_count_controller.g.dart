// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_download_keep_count_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.

@ProviderFor(AutoDownloadKeepCountController)
final autoDownloadKeepCountControllerProvider =
    AutoDownloadKeepCountControllerProvider._();

/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.
final class AutoDownloadKeepCountControllerProvider
    extends $AsyncNotifierProvider<AutoDownloadKeepCountController, void> {
  /// Changes how many unstarted auto-downloads are kept and applies the new
  /// limit right away instead of waiting for the next feed sync.
  AutoDownloadKeepCountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoDownloadKeepCountControllerProvider',
        isAutoDispose: true,
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
    r'0bc669a496d72e3d001a2faf54ea366a05d5ecf4';

/// Changes how many unstarted auto-downloads are kept and applies the new
/// limit right away instead of waiting for the next feed sync.

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
