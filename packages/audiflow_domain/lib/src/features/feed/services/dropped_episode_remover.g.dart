// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dropped_episode_remover.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(droppedEpisodeRemover)
final droppedEpisodeRemoverProvider = DroppedEpisodeRemoverProvider._();

final class DroppedEpisodeRemoverProvider
    extends
        $FunctionalProvider<
          DroppedEpisodeRemover,
          DroppedEpisodeRemover,
          DroppedEpisodeRemover
        >
    with $Provider<DroppedEpisodeRemover> {
  DroppedEpisodeRemoverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'droppedEpisodeRemoverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$droppedEpisodeRemoverHash();

  @$internal
  @override
  $ProviderElement<DroppedEpisodeRemover> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DroppedEpisodeRemover create(Ref ref) {
    return droppedEpisodeRemover(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DroppedEpisodeRemover value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DroppedEpisodeRemover>(value),
    );
  }
}

String _$droppedEpisodeRemoverHash() =>
    r'8a190f5d85c18db42ad55e55dbfd7d7f0af5b130';
