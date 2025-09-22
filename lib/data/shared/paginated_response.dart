class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
}