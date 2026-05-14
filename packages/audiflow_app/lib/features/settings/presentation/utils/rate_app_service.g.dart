// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_app_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rateAppService)
final rateAppServiceProvider = RateAppServiceProvider._();

final class RateAppServiceProvider
    extends $FunctionalProvider<RateAppService, RateAppService, RateAppService>
    with $Provider<RateAppService> {
  RateAppServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rateAppServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rateAppServiceHash();

  @$internal
  @override
  $ProviderElement<RateAppService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RateAppService create(Ref ref) {
    return rateAppService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RateAppService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RateAppService>(value),
    );
  }
}

String _$rateAppServiceHash() => r'b4a6e192a8ac0fb455c641c5de9512914b412c31';
