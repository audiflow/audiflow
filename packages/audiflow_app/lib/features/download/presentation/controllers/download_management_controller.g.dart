// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_management_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for download management actions.

@ProviderFor(DownloadManagementController)
final downloadManagementControllerProvider =
    DownloadManagementControllerProvider._();

/// Controller for download management actions.
final class DownloadManagementControllerProvider
    extends $AsyncNotifierProvider<DownloadManagementController, void> {
  /// Controller for download management actions.
  DownloadManagementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadManagementControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadManagementControllerHash();

  @$internal
  @override
  DownloadManagementController create() => DownloadManagementController();
}

String _$downloadManagementControllerHash() =>
    r'efea78cbd1211e69ee2a56000d0890ed1b6a849a';

/// Controller for download management actions.

abstract class _$DownloadManagementController extends $AsyncNotifier<void> {
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
