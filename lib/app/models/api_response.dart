class ApiResponse {
  final bool success;
  final int statusCode;
  final String message;
  final dynamic data;

  /// HTTP 2xx (200–299) indicates a successful response (RFC 9110).
  static bool isSuccessfulHttpStatus(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.statusCode,
  });

  /// [httpStatusCode] is the real HTTP status. When the JSON body omits
  /// `success` (common for 201 Created) or sends null, we treat 2xx as success.
  ///
  /// If the HTTP status is 2xx, [success] is always true — some backends wrongly
  /// send `"success": false` with 200/201 on successful PATCH/POST.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    int? httpStatusCode,
  }) {
    final bool httpOk = httpStatusCode != null &&
        isSuccessfulHttpStatus(httpStatusCode);

    final bool bodySuccess;
    if (json.containsKey('success') && json['success'] != null) {
      final s = json['success'];
      if (s is bool) {
        bodySuccess = s;
      } else if (s is String) {
        bodySuccess = s.toLowerCase() == 'true';
      } else {
        bodySuccess = httpOk;
      }
    } else {
      bodySuccess = httpOk;
    }

    final bool success = httpOk ? true : bodySuccess;

    return ApiResponse(
      success: success,
      // Prefer real HTTP status when provided; JSON often echoes a wrong code.
      statusCode: httpStatusCode ?? (json['statusCode'] as int?) ?? 200,
      message: (json['message'] as String?) ?? '',
      data: json['data'],
    );
  }
}
