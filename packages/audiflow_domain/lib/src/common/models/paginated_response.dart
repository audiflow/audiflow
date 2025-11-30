/// Generic paginated response
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> data;
  final int total;
  final int page;
  final int pageSize;

  /// Calculate if there are more pages
  bool get hasMore => page * pageSize < total;

  /// Calculate total pages
  int get totalPages => (total / pageSize).ceil();
}
