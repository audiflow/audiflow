import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_sort_controller.g.dart';

/// Sort configuration for seasons.
class SeasonSortConfig {
  const SeasonSortConfig({required this.field, required this.order});

  final SeasonSortField field;
  final SortOrder order;

  SeasonSortConfig copyWith({SeasonSortField? field, SortOrder? order}) {
    return SeasonSortConfig(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }
}

/// Controller for season sort preferences.
@riverpod
class SeasonSortController extends _$SeasonSortController {
  @override
  SeasonSortConfig build(int podcastId) {
    return const SeasonSortConfig(
      field: SeasonSortField.seasonNumber,
      order: SortOrder.ascending,
    );
  }

  void setSort(SeasonSortField field, SortOrder order) {
    state = SeasonSortConfig(field: field, order: order);
  }

  void toggleOrder() {
    state = state.copyWith(
      order: state.order == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending,
    );
  }
}
