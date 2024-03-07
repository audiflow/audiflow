// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_search_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastSearchStateImpl _$$PodcastSearchStateImplFromJson(
        Map<String, dynamic> json) =>
    _$PodcastSearchStateImpl(
      term: json['term'] as String?,
      country: json['country'] as String?,
      attribute: json['attribute'] as String?,
      limit: json['limit'] as int? ?? 20,
      language: json['language'] as String?,
      version: json['version'] as int? ?? 0,
      explicit: json['explicit'] as bool? ?? false,
      podcasts: (json['podcasts'] as List<dynamic>?)
              ?.map((e) => PodcastMetadata.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PodcastSearchStateImplToJson(
        _$PodcastSearchStateImpl instance) =>
    <String, dynamic>{
      'term': instance.term,
      'country': instance.country,
      'attribute': instance.attribute,
      'limit': instance.limit,
      'language': instance.language,
      'version': instance.version,
      'explicit': instance.explicit,
      'podcasts': instance.podcasts.map((e) => e.toJson()).toList(),
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$podcastSearchHash() => r'9e858f81898b9ac552b4f41c766a7186a17a25b1';

/// See also [PodcastSearch].
@ProviderFor(PodcastSearch)
final podcastSearchProvider =
    AsyncNotifierProvider<PodcastSearch, PodcastSearchState>.internal(
  PodcastSearch.new,
  name: r'podcastSearchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$podcastSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PodcastSearch = AsyncNotifier<PodcastSearchState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
