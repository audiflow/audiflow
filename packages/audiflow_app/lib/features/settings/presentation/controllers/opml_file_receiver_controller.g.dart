// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opml_file_receiver_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listens for incoming .opml file URIs from external apps
/// via the system share sheet or "Open With" handler.

@ProviderFor(OpmlFileReceiverController)
final opmlFileReceiverControllerProvider =
    OpmlFileReceiverControllerProvider._();

/// Listens for incoming .opml file URIs from external apps
/// via the system share sheet or "Open With" handler.
final class OpmlFileReceiverControllerProvider
    extends
        $NotifierProvider<OpmlFileReceiverController, OpmlFileReceiverState> {
  /// Listens for incoming .opml file URIs from external apps
  /// via the system share sheet or "Open With" handler.
  OpmlFileReceiverControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opmlFileReceiverControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opmlFileReceiverControllerHash();

  @$internal
  @override
  OpmlFileReceiverController create() => OpmlFileReceiverController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpmlFileReceiverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpmlFileReceiverState>(value),
    );
  }
}

String _$opmlFileReceiverControllerHash() =>
    r'e2b6f04808ebf09763d8aac6069a851ae5e4e0ce';

/// Listens for incoming .opml file URIs from external apps
/// via the system share sheet or "Open With" handler.

abstract class _$OpmlFileReceiverController
    extends $Notifier<OpmlFileReceiverState> {
  OpmlFileReceiverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OpmlFileReceiverState, OpmlFileReceiverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OpmlFileReceiverState, OpmlFileReceiverState>,
              OpmlFileReceiverState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
