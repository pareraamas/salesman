class ResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;

  ResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
    };
  }
}
