class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.count,
    required this.items,
    required this.hasNext,
  });
  final int count;
  final List<T> items;
  final bool hasNext;
}
