/// Filters a list of items by a search query with two-tier prioritization.
///
/// Title matches appear first, followed by description-only matches.
/// Both tiers preserve the original order of items.
/// Returns all items unmodified when [query] is empty or shorter than
/// 2 characters.
List<T> filterBySearchQuery<T>({
  required List<T> items,
  required String query,
  required String Function(T) getTitle,
  String? Function(T)? getDescription,
}) {
  if (query.length < 2) return items;

  final lowerQuery = query.toLowerCase();
  final titleMatches = <T>[];
  final descriptionOnlyMatches = <T>[];

  for (final item in items) {
    final titleMatch = getTitle(item).toLowerCase().contains(lowerQuery);
    if (titleMatch) {
      titleMatches.add(item);
      continue;
    }

    if (getDescription != null) {
      final description = getDescription(item);
      if (description != null &&
          description.toLowerCase().contains(lowerQuery)) {
        descriptionOnlyMatches.add(item);
      }
    }
  }

  return [...titleMatches, ...descriptionOnlyMatches];
}
