import 'episode_filter_entry.dart';

/// Episode filters applied before resolver processing.
final class EpisodeFilters {
  const EpisodeFilters({this.require, this.exclude});

  factory EpisodeFilters.fromJson(Map<String, dynamic> json) {
    return EpisodeFilters(
      require: (json['require'] as List<dynamic>?)
          ?.map((e) => EpisodeFilterEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      exclude: (json['exclude'] as List<dynamic>?)
          ?.map((e) => EpisodeFilterEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Inclusion filters. Episode must match ALL entries.
  final List<EpisodeFilterEntry>? require;

  /// Exclusion filters. Episode matching ANY entry is excluded.
  final List<EpisodeFilterEntry>? exclude;

  /// Whether any filters are defined.
  bool get hasFilters =>
      (require != null && require!.isNotEmpty) ||
      (exclude != null && exclude!.isNotEmpty);

  Map<String, dynamic> toJson() {
    return {
      if (require != null) 'require': require!.map((e) => e.toJson()).toList(),
      if (exclude != null) 'exclude': exclude!.map((e) => e.toJson()).toList(),
    };
  }
}
