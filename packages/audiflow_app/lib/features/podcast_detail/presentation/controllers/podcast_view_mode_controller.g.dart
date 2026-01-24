// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for the podcast detail screen view mode toggle.

@ProviderFor(PodcastViewModeController)
final podcastViewModeControllerProvider = PodcastViewModeControllerFamily._();

/// Controller for the podcast detail screen view mode toggle.
final class PodcastViewModeControllerProvider
    extends $NotifierProvider<PodcastViewModeController, PodcastViewMode> {
  /// Controller for the podcast detail screen view mode toggle.
  PodcastViewModeControllerProvider._({
    required PodcastViewModeControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastViewModeControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastViewModeControllerHash();

  @override
  String toString() {
    return r'podcastViewModeControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastViewModeController create() => PodcastViewModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PodcastViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PodcastViewMode>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewModeControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastViewModeControllerHash() =>
    r'8f4f115f54c6af5d8187fd7982e30eb771beac7f';

/// Controller for the podcast detail screen view mode toggle.

final class PodcastViewModeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastViewModeController,
          PodcastViewMode,
          PodcastViewMode,
          PodcastViewMode,
          int
        > {
  PodcastViewModeControllerFamily._()
    : super(
        retry: null,
        name: r'podcastViewModeControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for the podcast detail screen view mode toggle.

  PodcastViewModeControllerProvider call(int podcastId) =>
      PodcastViewModeControllerProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'podcastViewModeControllerProvider';
}

/// Controller for the podcast detail screen view mode toggle.

abstract class _$PodcastViewModeController extends $Notifier<PodcastViewMode> {
  late final _$args = ref.$arg as int;
  int get podcastId => _$args;

  PodcastViewMode build(int podcastId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PodcastViewMode, PodcastViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PodcastViewMode, PodcastViewMode>,
              PodcastViewMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
