class Pagination {
  Pagination({required this.page, required this.hasMore, required this.total});

  final int page;
  final bool hasMore;
  final int total;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json['page'] as int? ?? 1,
    hasMore: json['has_more'] as bool? ?? false,
    total: json['total'] as int? ?? 0,
  );

  factory Pagination.empty() => Pagination(page: 1, hasMore: false, total: 0);
}

class Paged<T> {
  Paged(this.items, this.pagination);

  final List<T> items;
  final Pagination pagination;
}
