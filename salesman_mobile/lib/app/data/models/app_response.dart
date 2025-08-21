class PaginationMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;
  final String path;
  final String firstPageUrl;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
    required this.path,
    required this.firstPageUrl,
    required this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      to: json['to'] as int?,
      total: json['total'] as int? ?? 0,
      path: json['path'] as String? ?? '',
      firstPageUrl: json['first_page_url'] as String? ?? '',
      lastPageUrl: json['last_page_url'] as String? ?? '',
      nextPageUrl: json['next_page_url'] as String?,
      prevPageUrl: json['prev_page_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'from': from,
    'last_page': lastPage,
    'per_page': perPage,
    'to': to,
    'total': total,
    'path': path,
    'first_page_url': firstPageUrl,
    'last_page_url': lastPageUrl,
    'next_page_url': nextPageUrl,
    'prev_page_url': prevPageUrl,
  };
}

class AppResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;

  AppResponse({
    required this.success, 
    this.data, 
    this.message, 
    this.statusCode, 
    this.errors,
    this.meta,
  });

  factory AppResponse.fromJson(Map<String, dynamic> json, {T Function(dynamic json)? fromJsonT}) {
    return AppResponse<T>(
      success: json['success'] as bool? ?? false,
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['code'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data,
    'message': message,
    'code': statusCode,
    'errors': errors,
    'meta': meta?.toJson(),
  };
}
