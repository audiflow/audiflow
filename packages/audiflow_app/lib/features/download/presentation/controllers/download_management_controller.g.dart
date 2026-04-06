// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_management_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Looks up an episode by ID for download tile display.

@ProviderFor(episodeByIdForDownload)
final episodeByIdForDownloadProvider = EpisodeByIdForDownloadFamily._();

/// Looks up an episode by ID for download tile display.

final class EpisodeByIdForDownloadProvider
    extends
        $FunctionalProvider<AsyncValue<Episode?>, Episode?, FutureOr<Episode?>>
    with $FutureModifier<Episode?>, $FutureProvider<Episode?> {
  /// Looks up an episode by ID for download tile display.
  EpisodeByIdForDownloadProvider._({
    required EpisodeByIdForDownloadFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'episodeByIdForDownloadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeByIdForDownloadHash();

  @override
  String toString() {
    return r'episodeByIdForDownloadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Episode?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Episode?> create(Ref ref) {
    final argument = this.argument as int;
    return episodeByIdForDownload(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeByIdForDownloadProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeByIdForDownloadHash() =>
    r'dc8da52e6ba9c04c0a43940acf693fcbcee7f9e1';

/// Looks up an episode by ID for download tile display.

final class EpisodeByIdForDownloadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Episode?>, int> {
  EpisodeByIdForDownloadFamily._()
    : super(
        retry: null,
        name: r'episodeByIdForDownloadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Looks up an episode by ID for download tile display.

  EpisodeByIdForDownloadProvider call(int episodeId) =>
      EpisodeByIdForDownloadProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'episodeByIdForDownloadProvider';
}

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
