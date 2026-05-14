// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_dismissal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session-scoped flag indicating the user dismissed the soft-update banner.
///
/// Intentionally not persisted: the banner reappears on the next cold start
/// so we keep nudging without becoming intrusive within a single session.

@ProviderFor(SoftUpdateBannerDismissed)
final softUpdateBannerDismissedProvider = SoftUpdateBannerDismissedProvider._();

/// Session-scoped flag indicating the user dismissed the soft-update banner.
///
/// Intentionally not persisted: the banner reappears on the next cold start
/// so we keep nudging without becoming intrusive within a single session.
final class SoftUpdateBannerDismissedProvider
    extends $NotifierProvider<SoftUpdateBannerDismissed, bool> {
  /// Session-scoped flag indicating the user dismissed the soft-update banner.
  ///
  /// Intentionally not persisted: the banner reappears on the next cold start
  /// so we keep nudging without becoming intrusive within a single session.
  SoftUpdateBannerDismissedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'softUpdateBannerDismissedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$softUpdateBannerDismissedHash();

  @$internal
  @override
  SoftUpdateBannerDismissed create() => SoftUpdateBannerDismissed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$softUpdateBannerDismissedHash() =>
    r'2060b9ad817b9fe689703b1be23e6e282f082a43';

/// Session-scoped flag indicating the user dismissed the soft-update banner.
///
/// Intentionally not persisted: the banner reappears on the next cold start
/// so we keep nudging without becoming intrusive within a single session.

abstract class _$SoftUpdateBannerDismissed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
