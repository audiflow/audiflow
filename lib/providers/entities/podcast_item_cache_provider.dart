import 'package:podcast_search/podcast_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_item_cache_provider.g.dart';

@riverpod
class PodcastItemCache extends _$PodcastItemCache {
  @override
  Map<String, Item> build() => {};

  Future<void> add(Item item) async {
    state = {...state, item.feedUrl!: item};
  }

  Future<void> remove(Item item) async {
    state = Map<String, Item>.fromEntries(
      state.entries.where((i) => i.key != item.feedUrl),
    );
  }
}
