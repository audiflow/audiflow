import '../../../common/database/app_database.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';

/// Interface for season resolvers that group episodes into seasons.
abstract class SeasonResolver {
  /// Unique identifier for this resolver type.
  String get type;

  /// Default sort specification for seasons produced by this resolver.
  SeasonSortSpec get defaultSort;

  /// Attempts to group episodes into seasons.
  ///
  /// Returns null if this resolver cannot handle the given episodes.
  /// The [pattern] provides resolver-specific configuration when available.
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern);
}
