// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_opt_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnalyticsOptInController)
final analyticsOptInControllerProvider = AnalyticsOptInControllerProvider._();

final class AnalyticsOptInControllerProvider
    extends $NotifierProvider<AnalyticsOptInController, bool> {
  AnalyticsOptInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsOptInControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsOptInControllerHash();

  @$internal
  @override
  AnalyticsOptInController create() => AnalyticsOptInController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$analyticsOptInControllerHash() =>
    r'08fed5f57a888f55a685419e490d9edc3fa885eb';

abstract class _$AnalyticsOptInController extends $Notifier<bool> {
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
