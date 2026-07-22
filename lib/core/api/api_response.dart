class ApiResponse<T> {
  const ApiResponse({
    this.data,
    this.message,
    this.success,
    this.metadata,
    this.pagination,
  });

  factory ApiResponse.fromJson(
    Map<String, Object?> json, {
    T Function(Object? value)? dataParser,
  }) {
    return ApiResponse<T>(
      data: dataParser == null ? json['data'] as T? : dataParser(json['data']),
      message: json['message'] is String ? json['message']! as String : null,
      success: json['success'] is bool ? json['success']! as bool : null,
      metadata: _asMap(json['metadata'] ?? json['meta']),
      pagination: _asMap(json['pagination']),
    );
  }

  final T? data;
  final String? message;
  final bool? success;
  final Map<String, Object?>? metadata;
  final Map<String, Object?>? pagination;

  static Map<String, Object?>? _asMap(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
