import 'dart:convert';

import 'package:color_os/app/core/helper/sharedpref_helper.dart';
import 'package:color_os/app/models/api_response.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  /// Prefer the real HTTP status. JSON bodies sometimes echo wrong
  /// `success` / `statusCode` fields (e.g. from serializers).
  static ApiResponse _withWireStatus(http.Response response, ApiResponse parsed) {
    final ok = ApiResponse.isSuccessfulHttpStatus(response.statusCode);
    return ApiResponse(
      success: ok,
      statusCode: response.statusCode,
      message: parsed.message.isNotEmpty
          ? parsed.message
          : (ok ? 'Request completed successfully' : 'Request failed'),
      data: parsed.data,
    );
  }

  // // Private constructor
  // ApiServices._privateConstructor();

  // // Singleton instance
  // static final ApiServices _instance = ApiServices._privateConstructor();

  // // Factory constructor to return the singleton instance
  // factory ApiServices() {
  //   return _instance;
  // }

  static Future<ApiResponse?> getData(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );
      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map<String, dynamic> &&
          !decodedResponse.containsKey('success')) {
        return ApiResponse(
          success: ApiResponse.isSuccessfulHttpStatus(response.statusCode),
          statusCode: response.statusCode,
          message: 'Request completed',
          data: decodedResponse,
        );
      }

      return ApiResponse.fromJson(
        decodedResponse,
        httpStatusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<ApiResponse?> postData(
    String url,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    try {
      debugPrint('Making POST request to: $url');
      debugPrint('Request body: ${jsonEncode(body)}');

      final headers = await _getHeaders(includeAuth: requireAuth);
      debugPrint('Request headers: $headers');

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout: Server took too long to respond',
              );
            },
          );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: "${response.body}"');
      debugPrint('Response headers: ${response.headers}');

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        debugPrint('Empty or whitespace-only response body received');
        final ok = ApiResponse.isSuccessfulHttpStatus(response.statusCode);
        return ApiResponse(
          success: ok,
          statusCode: response.statusCode,
          message: ok
              ? 'Request completed successfully'
              : 'Server error: ${response.statusCode}',
          data: null,
        );
      }

      try {
        final decodedResponse = jsonDecode(response.body);
        debugPrint('Decoded response: $decodedResponse');

        if (decodedResponse is Map<String, dynamic> &&
            !decodedResponse.containsKey('success')) {
          return ApiResponse(
            success: ApiResponse.isSuccessfulHttpStatus(response.statusCode),
            statusCode: response.statusCode,
            message: decodedResponse['message'] ?? 'Request completed',
            data: decodedResponse,
          );
        }

        return ApiResponse.fromJson(
          decodedResponse,
          httpStatusCode: response.statusCode,
        );
      } catch (jsonError) {
        debugPrint('JSON parsing error: $jsonError');
        debugPrint('Raw response that failed to parse: "${response.body}"');
        return ApiResponse(
          success: false,
          statusCode: response.statusCode,
          message: 'Invalid response format from server',
          data: {'raw_response': response.body},
        );
      }
    } catch (e, stackTrace) {
      debugPrint('API Error: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Error type: ${e.runtimeType}');

      // Create error response
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'Network error: ${e.toString()}',
        data: {'error_type': e.runtimeType.toString()},
      );
    }
  }

  static Future<ApiResponse?> updateData(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      final ApiResponse parsed;
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        parsed = ApiResponse(
          success: false,
          statusCode: response.statusCode,
          message: '',
          data: null,
        );
      } else {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          if (!map.containsKey('success')) {
            final httpOk =
                ApiResponse.isSuccessfulHttpStatus(response.statusCode);
            parsed = ApiResponse(
              success: false,
              statusCode: response.statusCode,
              message: map['message'] as String? ??
                  (httpOk ? 'Request completed' : 'Request failed'),
              data: map,
            );
          } else {
            parsed = ApiResponse.fromJson(
              map,
              httpStatusCode: response.statusCode,
            );
          }
        } else {
          final httpOk =
              ApiResponse.isSuccessfulHttpStatus(response.statusCode);
          parsed = ApiResponse(
            success: false,
            statusCode: response.statusCode,
            message: httpOk ? 'Request completed' : 'Request failed',
            data: decoded,
          );
        }
      }

      return _withWireStatus(response, parsed);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<ApiResponse?> deleteData(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 204) {
        return ApiResponse(
          success: true,
          statusCode: 204,
          message: 'Deleted successfully',
          data: null,
        );
      }

      if (response.body.isEmpty) {
        final ok = ApiResponse.isSuccessfulHttpStatus(response.statusCode);
        return ApiResponse(
          success: ok,
          statusCode: response.statusCode,
          message: ok ? 'Deleted successfully' : 'Failed',
          data: null,
        );
      }

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map<String, dynamic> &&
          !decodedResponse.containsKey('success')) {
        return ApiResponse(
          success: ApiResponse.isSuccessfulHttpStatus(response.statusCode),
          statusCode: response.statusCode,
          message: decodedResponse['message'] ?? 'Deleted successfully',
          data: decodedResponse,
        );
      }

      return ApiResponse.fromJson(
        decodedResponse,
        httpStatusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<ApiResponse?> postMultipartData(
    String url,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    bool requireAuth = true,
  }) async {
    try {
      debugPrint('Making POST Multipart request to: $url');
      debugPrint('Request fields: $fields');

      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      final headers = await _getHeaders(includeAuth: requireAuth);
      // Remove Content-Type as MultipartRequest sets it automatically
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (var file in files) {
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: "${response.body}"');

      if (response.body.isEmpty) {
        return ApiResponse(
          success: ApiResponse.isSuccessfulHttpStatus(response.statusCode),
          statusCode: response.statusCode,
          message: 'Request completed',
          data: null,
        );
      }

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is Map<String, dynamic> &&
          !decodedResponse.containsKey('success')) {
        return ApiResponse(
          success: ApiResponse.isSuccessfulHttpStatus(response.statusCode),
          statusCode: response.statusCode,
          message: decodedResponse['message'] ?? 'Request completed',
          data: decodedResponse,
        );
      }

      return ApiResponse.fromJson(
        decodedResponse,
        httpStatusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('API Error: ${e.toString()}');
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  static Future<ApiResponse?> patchMultipartData(
    String url,
    Map<String, String> fields,
    List<http.MultipartFile> files, {
    bool requireAuth = true,
    bool isPut = false,
  }) async {
    try {
      debugPrint(
        'Making ${isPut ? 'PUT' : 'PATCH'} Multipart request to: $url',
      );
      debugPrint('Request fields: $fields');

      final request = http.MultipartRequest(
        isPut ? 'PUT' : 'PATCH',
        Uri.parse(url),
      );

      // Add headers
      final headers = await _getHeaders(includeAuth: requireAuth);
      // Remove Content-Type as MultipartRequest sets it automatically
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (var file in files) {
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: "${response.body}"');

      final ApiResponse parsed;
      if (response.body.isEmpty) {
        parsed = ApiResponse(
          success: false,
          statusCode: response.statusCode,
          message: 'Request completed',
          data: null,
        );
      } else {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final map = Map<String, dynamic>.from(decoded);
          if (!map.containsKey('success')) {
            final httpOk =
                ApiResponse.isSuccessfulHttpStatus(response.statusCode);
            parsed = ApiResponse(
              success: false,
              statusCode: response.statusCode,
              message: map['message'] as String? ??
                  (httpOk ? 'Request completed' : 'Request failed'),
              data: map,
            );
          } else {
            parsed = ApiResponse.fromJson(
              map,
              httpStatusCode: response.statusCode,
            );
          }
        } else {
          final httpOk =
              ApiResponse.isSuccessfulHttpStatus(response.statusCode);
          parsed = ApiResponse(
            success: false,
            statusCode: response.statusCode,
            message: httpOk ? 'Request completed' : 'Request failed',
            data: decoded,
          );
        }
      }

      return _withWireStatus(response, parsed);
    } catch (e) {
      debugPrint('API Error: ${e.toString()}');
      return ApiResponse(
        success: false,
        statusCode: 500,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await SharedprefHelper.getString(SharedprefHelper().token);
      debugPrint('ApiServices: Retrieving token from storage: "${token}"');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        debugPrint('ApiServices: WARNING - Token is empty!');
      }
    }

    debugPrint('Request headers: $headers');
    return headers;
  }
}
