// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [QueueService] instance.
///
/// The service provides high-level queue operations with proper logging
/// and coordination between the queue and episode repositories.

@ProviderFor(queueService)
final queueServiceProvider = QueueServiceProvider._();

/// Provides a singleton [QueueService] instance.
///
/// The service provides high-level queue operations with proper logging
/// and coordination between the queue and episode repositories.

final class QueueServiceProvider
    extends $FunctionalProvider<QueueService, QueueService, QueueService>
    with $Provider<QueueService> {
  /// Provides a singleton [QueueService] instance.
  ///
  /// The service provides high-level queue operations with proper logging
  /// and coordination between the queue and episode repositories.
  QueueServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueServiceHash();

  @$internal
  @override
  $ProviderElement<QueueService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueueService create(Ref ref) {
    return queueService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueService>(value),
    );
  }
}

String _$queueServiceHash() => r'72cc7c5cb9f45f15868c9dd346e4c9984873c2eb';
