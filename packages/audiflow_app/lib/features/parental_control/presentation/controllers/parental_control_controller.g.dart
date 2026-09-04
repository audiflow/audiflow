// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parental_control_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stateless action holder for parental control write operations.
///
/// For reads, watch [parentalControlSettingsStreamProvider] directly.

@ProviderFor(ParentalControlController)
final parentalControlControllerProvider = ParentalControlControllerProvider._();

/// Stateless action holder for parental control write operations.
///
/// For reads, watch [parentalControlSettingsStreamProvider] directly.
final class ParentalControlControllerProvider
    extends $NotifierProvider<ParentalControlController, void> {
  /// Stateless action holder for parental control write operations.
  ///
  /// For reads, watch [parentalControlSettingsStreamProvider] directly.
  ParentalControlControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parentalControlControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parentalControlControllerHash();

  @$internal
  @override
  ParentalControlController create() => ParentalControlController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$parentalControlControllerHash() =>
    r'ac6c61d01eb13b6c046547e45d6b5dd136757889';

/// Stateless action holder for parental control write operations.
///
/// For reads, watch [parentalControlSettingsStreamProvider] directly.

abstract class _$ParentalControlController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
