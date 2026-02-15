// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opml_export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls OPML export: fetch subscriptions, generate XML,
/// share via system share sheet.

@ProviderFor(OpmlExportController)
final opmlExportControllerProvider = OpmlExportControllerProvider._();

/// Controls OPML export: fetch subscriptions, generate XML,
/// share via system share sheet.
final class OpmlExportControllerProvider
    extends $NotifierProvider<OpmlExportController, OpmlExportState> {
  /// Controls OPML export: fetch subscriptions, generate XML,
  /// share via system share sheet.
  OpmlExportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opmlExportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opmlExportControllerHash();

  @$internal
  @override
  OpmlExportController create() => OpmlExportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpmlExportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpmlExportState>(value),
    );
  }
}

String _$opmlExportControllerHash() =>
    r'2ec42d5b00157b8a06819b1d69d31b8d555bf3cb';

/// Controls OPML export: fetch subscriptions, generate XML,
/// share via system share sheet.

abstract class _$OpmlExportController extends $Notifier<OpmlExportState> {
  OpmlExportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OpmlExportState, OpmlExportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OpmlExportState, OpmlExportState>,
              OpmlExportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
