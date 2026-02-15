// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opml_import_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls OPML import: pick file, parse, and check
/// existing subscriptions.

@ProviderFor(OpmlImportController)
final opmlImportControllerProvider = OpmlImportControllerProvider._();

/// Controls OPML import: pick file, parse, and check
/// existing subscriptions.
final class OpmlImportControllerProvider
    extends $NotifierProvider<OpmlImportController, OpmlPickResult> {
  /// Controls OPML import: pick file, parse, and check
  /// existing subscriptions.
  OpmlImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'opmlImportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$opmlImportControllerHash();

  @$internal
  @override
  OpmlImportController create() => OpmlImportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OpmlPickResult value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OpmlPickResult>(value),
    );
  }
}

String _$opmlImportControllerHash() =>
    r'93e2e1ba738a1351dd5bfe6ab3cc3e4d2c4eae4b';

/// Controls OPML import: pick file, parse, and check
/// existing subscriptions.

abstract class _$OpmlImportController extends $Notifier<OpmlPickResult> {
  OpmlPickResult build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OpmlPickResult, OpmlPickResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OpmlPickResult, OpmlPickResult>,
              OpmlPickResult,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
