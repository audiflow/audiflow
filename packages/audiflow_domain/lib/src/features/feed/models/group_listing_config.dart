import 'smart_playlist.dart';
import 'smart_playlist_sort.dart';

/// How the group list is arranged.
final class GroupListingConfig {
  const GroupListingConfig({this.yearBinding, this.sort, this.userSortable});

  factory GroupListingConfig.fromJson(Map<String, dynamic> json) {
    return GroupListingConfig(
      yearBinding: json['yearBinding'] != null
          ? YearBinding.fromString(json['yearBinding'] as String)
          : null,
      sort: json['sort'] != null
          ? SmartPlaylistSortRule.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      userSortable: json['userSortable'] as bool?,
    );
  }

  /// How groups relate to year sections.
  final YearBinding? yearBinding;

  /// Sort rule for ordering groups.
  final SmartPlaylistSortRule? sort;

  /// Allow users to flip sort order at runtime.
  final bool? userSortable;

  Map<String, dynamic> toJson() {
    return {
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
      if (sort != null) 'sort': sort!.toJson(),
      if (userSortable != null) 'userSortable': userSortable,
    };
  }
}
