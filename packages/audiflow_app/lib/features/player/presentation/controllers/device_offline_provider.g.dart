// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_offline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the device has no network at all.
///
/// A failed load cannot say this itself: Android reports only "Source error",
/// whatever the cause. It tells the listener that retrying is pointless until
/// they reconnect, and updates once they do.

@ProviderFor(deviceOffline)
final deviceOfflineProvider = DeviceOfflineProvider._();

/// Whether the device has no network at all.
///
/// A failed load cannot say this itself: Android reports only "Source error",
/// whatever the cause. It tells the listener that retrying is pointless until
/// they reconnect, and updates once they do.

final class DeviceOfflineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the device has no network at all.
  ///
  /// A failed load cannot say this itself: Android reports only "Source error",
  /// whatever the cause. It tells the listener that retrying is pointless until
  /// they reconnect, and updates once they do.
  DeviceOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceOfflineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceOfflineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return deviceOffline(ref);
  }
}

String _$deviceOfflineHash() => r'7ca7f3b0bcdb4c97aa0cdd2f8e379e79fce359fe';
