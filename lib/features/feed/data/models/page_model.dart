/// Generic wrapper for Spring Boot's paginated `Page<T>` JSON response.
class PageModel<T> {
  const PageModel({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.number,
  });

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int number; // zero-based current page index

  factory PageModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PageModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
      number: json['number'] as int? ?? 0,
    );
  }
}
