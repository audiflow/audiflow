// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for queue screen state and actions.

@ProviderFor(QueueController)
final queueControllerProvider = QueueControllerProvider._();

/// Controller for queue screen state and actions.
final class QueueControllerProvider
    extends $StreamNotifierProvider<QueueController, PlaybackQueue> {
  /// Controller for queue screen state and actions.
  QueueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueControllerHash();

  @$internal
  @override
  QueueController create() => QueueController();
}

String _$queueControllerHash() => r'cc298ddccde9c105bd774ead9810e8aabec2250c';

/// Controller for queue screen state and actions.

abstract class _$QueueController extends $StreamNotifier<PlaybackQueue> {
  Stream<PlaybackQueue> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PlaybackQueue>, PlaybackQueue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlaybackQueue>, PlaybackQueue>,
              AsyncValue<PlaybackQueue>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
