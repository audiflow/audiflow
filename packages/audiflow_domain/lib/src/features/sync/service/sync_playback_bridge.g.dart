// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_playback_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Moves a paused or unloaded player to a newer position another device
/// synced. Read once at startup; a build without a relay starts nothing.

@ProviderFor(syncPlaybackBridge)
final syncPlaybackBridgeProvider = SyncPlaybackBridgeProvider._();

/// Moves a paused or unloaded player to a newer position another device
/// synced. Read once at startup; a build without a relay starts nothing.

final class SyncPlaybackBridgeProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Moves a paused or unloaded player to a newer position another device
  /// synced. Read once at startup; a build without a relay starts nothing.
  SyncPlaybackBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncPlaybackBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncPlaybackBridgeHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return syncPlaybackBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$syncPlaybackBridgeHash() =>
    r'3c2cd4e1886f9c81165c92d56e9295b4d7b321c9';
