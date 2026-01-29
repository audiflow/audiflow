import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'smart_playlist_sort_controller.g.dart';

/// Sort configuration for smart playlists.
class SmartPlaylistSortConfig {
  const SmartPlaylistSortConfig({required this.field, required this.order});

  final SmartPlaylistSortField field;
  final SortOrder order;

  SmartPlaylistSortConfig copyWith({
    SmartPlaylistSortField? field,
    SortOrder? order,
  }) {
    return SmartPlaylistSortConfig(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }
}

/// Controller for smart playlist sort preferences.
@riverpod
class SmartPlaylistSortController extends _$SmartPlaylistSortController {
  @override
  SmartPlaylistSortConfig build(String podcastId) {
    return const SmartPlaylistSortConfig(
      field: SmartPlaylistSortField.playlistNumber,
      order: SortOrder.ascending,
    );
  }

  void setSort(SmartPlaylistSortField field, SortOrder order) {
    state = SmartPlaylistSortConfig(field: field, order: order);
  }

  void toggleOrder() {
    state = state.copyWith(
      order: state.order == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending,
    );
  }
}
