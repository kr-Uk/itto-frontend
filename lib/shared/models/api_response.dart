class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;
  final String? code;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.code,
  });

  bool get isSuccess => status >= 200 && status < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse(
      status: json['status'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
      code: json['code'] as String?,
    );
  }
}
