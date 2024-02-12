import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/repository_provider.dart';

part 'podcast_subscriptions_provider.g.dart';

@riverpod
class PodcastSubscriptions extends _$PodcastSubscriptions {
  @override
  Future<List<Podcast>> build() async {
    return ref.read(repositoryProvider).subscriptions();
  }

  Future<void> subscribe(Podcast podcast) async {
    final newPodcast = await ref.read(repositoryProvider).savePodcast(podcast);
    if (state.valueOrNull?.any((p) => p.guid == podcast.guid) == false) {
      state = AsyncValue.data([newPodcast, ...state.value!]);
    }
  }

  Future<void> unsubscribe(Podcast podcast) async {
    await ref.read(repositoryProvider).deletePodcast(podcast);
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.guid != podcast.guid).toList(),
      );
    }
  }
}
