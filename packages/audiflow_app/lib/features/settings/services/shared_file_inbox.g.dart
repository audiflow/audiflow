// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_file_inbox.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedFileInbox)
final sharedFileInboxProvider = SharedFileInboxProvider._();

final class SharedFileInboxProvider
    extends
        $FunctionalProvider<SharedFileInbox, SharedFileInbox, SharedFileInbox>
    with $Provider<SharedFileInbox> {
  SharedFileInboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedFileInboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedFileInboxHash();

  @$internal
  @override
  $ProviderElement<SharedFileInbox> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedFileInbox create(Ref ref) {
    return sharedFileInbox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedFileInbox value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedFileInbox>(value),
    );
  }
}

String _$sharedFileInboxHash() => r'a65d02093872290177d7f9362b0a58c443966683';
