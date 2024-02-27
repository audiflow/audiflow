// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episodes_group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$episodesGroupHash() => r'94db7c50a13afa3c487e888d5b571057d3dd4a68';

/// See also [EpisodesGroup].
@ProviderFor(EpisodesGroup)
final episodesGroupProvider = AutoDisposeAsyncNotifierProvider<EpisodesGroup,
    EpisodesGroupState>.internal(
  EpisodesGroup.new,
  name: r'episodesGroupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$episodesGroupHash,
  dependencies: <ProviderOrFamily>[podcastServiceProvider, repositoryProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    podcastServiceProvider,
    ...?podcastServiceProvider.allTransitiveDependencies,
    repositoryProvider,
    ...?repositoryProvider.allTransitiveDependencies
  },
);

typedef _$EpisodesGroup = AutoDisposeAsyncNotifier<EpisodesGroupState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
