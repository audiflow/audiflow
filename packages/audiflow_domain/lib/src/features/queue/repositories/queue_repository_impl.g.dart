// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [QueueRepository] instance.

@ProviderFor(queueRepository)
final queueRepositoryProvider = QueueRepositoryProvider._();

/// Provides a singleton [QueueRepository] instance.

final class QueueRepositoryProvider
    extends
        $FunctionalProvider<QueueRepository, QueueRepository, QueueRepository>
    with $Provider<QueueRepository> {
  /// Provides a singleton [QueueRepository] instance.
  QueueRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueRepositoryHash();

  @$internal
  @override
  $ProviderElement<QueueRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QueueRepository create(Ref ref) {
    return queueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueueRepository>(value),
    );
  }
}

String _$queueRepositoryHash() => r'10cc38260869ea27cddf84f387041b058757d96f';
