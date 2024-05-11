// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'episodes_list_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodesListEventStreamHash() =>
    r'f01e9d1a74af995e8b4b10ec787cbd8d6f3da68b';

/// See also [EpisodesListEventStream].
@ProviderFor(EpisodesListEventStream)
final episodesListEventStreamProvider = AutoDisposeStreamNotifierProvider<
    EpisodesListEventStream, EpisodesListEvent>.internal(
  EpisodesListEventStream.new,
  name: r'episodesListEventStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$episodesListEventStreamHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef _$EpisodesListEventStream
    = AutoDisposeStreamNotifier<EpisodesListEvent>;
String _$episodesListActionStreamHash() =>
    r'5670b6cae48cbbaf61247c6a7113187de6f4db20';

/// See also [EpisodesListActionStream].
@ProviderFor(EpisodesListActionStream)
final episodesListActionStreamProvider = AutoDisposeStreamNotifierProvider<
    EpisodesListActionStream, EpisodesListAction>.internal(
  EpisodesListActionStream.new,
  name: r'episodesListActionStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$episodesListActionStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EpisodesListActionStream
    = AutoDisposeStreamNotifier<EpisodesListAction>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
