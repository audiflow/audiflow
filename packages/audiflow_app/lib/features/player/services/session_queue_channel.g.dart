// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_queue_channel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionQueueChannel)
final sessionQueueChannelProvider = SessionQueueChannelProvider._();

final class SessionQueueChannelProvider
    extends
        $FunctionalProvider<
          SessionQueueChannel,
          SessionQueueChannel,
          SessionQueueChannel
        >
    with $Provider<SessionQueueChannel> {
  SessionQueueChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionQueueChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionQueueChannelHash();

  @$internal
  @override
  $ProviderElement<SessionQueueChannel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionQueueChannel create(Ref ref) {
    return sessionQueueChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionQueueChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionQueueChannel>(value),
    );
  }
}

String _$sessionQueueChannelHash() =>
    r'aaf4af3776e314fe201af948829b09b78a6377af';
