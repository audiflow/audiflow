import 'smart_playlist.dart';

/// Per-group display overrides for the group card.
final class GroupDisplayConfig {
  const GroupDisplayConfig({this.showDateRange, this.yearBinding});

  factory GroupDisplayConfig.fromJson(Map<String, dynamic> json) {
    return GroupDisplayConfig(
      showDateRange: json['showDateRange'] as bool?,
      yearBinding: json['yearBinding'] != null
          ? YearBinding.fromString(json['yearBinding'] as String)
          : null,
    );
  }

  /// Override whether date range is shown on this group's card.
  final bool? showDateRange;

  /// Override the year binding mode for this group.
  final YearBinding? yearBinding;

  Map<String, dynamic> toJson() {
    return {
      if (showDateRange != null) 'showDateRange': showDateRange,
      if (yearBinding != null) 'yearBinding': yearBinding!.name,
    };
  }
}
