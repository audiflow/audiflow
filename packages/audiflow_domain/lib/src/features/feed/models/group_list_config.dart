import 'smart_playlist.dart';
import 'smart_playlist_sort.dart';

/// Settings for the group list view (only meaningful when
/// playlistStructure is 'grouped').
final class GroupListConfig {
  const GroupListConfig({
    this.yearBinding,
    this.userSortable,
    this.showDateRange,
    this.sort,
  });

  factory GroupListConfig.fromJson(Map<String, dynamic> json) {
    return GroupListConfig(
      yearBinding: json['yearBinding'] != null
          ? YearBinding.values.byName(json['yearBinding'] as String)
          : null,
      userSortable: json['userSortable'] as bool?,
      showDateRange: json['showDateRange'] as bool?,
      sort: json['sort'] != null
          ? SmartPlaylistSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
    );
  }

  /// How groups relate to year headers.
  final YearBinding? yearBinding;

  /// Allow users to change the sort order at runtime.
  final bool? userSortable;

  /// Show date range and duration metadata on group cards.
  final bool? showDateRange;

  /// Sort rule for ordering groups.
  final SmartPlaylistSortRule? sort;

  Map<String, dynamic> toJson() {
    return {
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
      if (userSortable != null) 'userSortable': userSortable,
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (sort != null) 'sort': sort!.toJson(),
    };
  }
}
