// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_tab_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the persisted last-selected tab index.
///
/// Only tabs 0-2 (search, library, queue) are persisted.
/// The settings tab (index 3) is not persisted.

@ProviderFor(LastTabController)
final lastTabControllerProvider = LastTabControllerProvider._();

/// Controls the persisted last-selected tab index.
///
/// Only tabs 0-2 (search, library, queue) are persisted.
/// The settings tab (index 3) is not persisted.
final class LastTabControllerProvider
    extends $NotifierProvider<LastTabController, int> {
  /// Controls the persisted last-selected tab index.
  ///
  /// Only tabs 0-2 (search, library, queue) are persisted.
  /// The settings tab (index 3) is not persisted.
  LastTabControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastTabControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastTabControllerHash();

  @$internal
  @override
  LastTabController create() => LastTabController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$lastTabControllerHash() => r'131104645790e9a3aff2b385af134e513a1cea8f';

/// Controls the persisted last-selected tab index.
///
/// Only tabs 0-2 (search, library, queue) are persisted.
/// The settings tab (index 3) is not persisted.

abstract class _$LastTabController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
