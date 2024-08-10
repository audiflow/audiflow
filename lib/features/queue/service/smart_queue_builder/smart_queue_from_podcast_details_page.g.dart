// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_queue_from_podcast_details_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_InfoImpl _$$_InfoImplFromJson(Map<String, dynamic> json) => _$_InfoImpl(
      pid: (json['pid'] as num).toInt(),
      ordinal: (json['ordinal'] as num).toInt(),
      filterMode: $enumDecode(_$EpisodeFilterModeEnumMap, json['filterMode']),
    );

Map<String, dynamic> _$$_InfoImplToJson(_$_InfoImpl instance) =>
    <String, dynamic>{
      'pid': instance.pid,
      'ordinal': instance.ordinal,
      'filterMode': _$EpisodeFilterModeEnumMap[instance.filterMode]!,
    };

const _$EpisodeFilterModeEnumMap = {
  EpisodeFilterMode.all: 'all',
  EpisodeFilterMode.unplayed: 'unplayed',
  EpisodeFilterMode.completed: 'completed',
  EpisodeFilterMode.downloaded: 'downloaded',
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$smartQueueFromPodcastDetailsPageHash() =>
    r'8964013bf96ded67b04c2ce3deeacb5479c0fa05';

/// See also [SmartQueueFromPodcastDetailsPage].
@ProviderFor(SmartQueueFromPodcastDetailsPage)
final smartQueueFromPodcastDetailsPageProvider =
    NotifierProvider<SmartQueueFromPodcastDetailsPage, QueueItem?>.internal(
  SmartQueueFromPodcastDetailsPage.new,
  name: r'smartQueueFromPodcastDetailsPageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$smartQueueFromPodcastDetailsPageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SmartQueueFromPodcastDetailsPage = Notifier<QueueItem?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
