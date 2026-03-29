import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_interceptor.dart';

/// Central Dio-based network caller.
///
/// Usage (from a Repository):
/// ```dart
/// final _api = ApiClient.instance;
///
/// final res = await _api.post(
///   ApiEndpoints.login,
///   body: {'email': 'a@b.com', 'password': '123'},
/// );
/// ```
///
/// Every method throws [NetworkException] on failure — never returns null.
class ApiClient {
  ApiClient._() : _dio = buildDio();

  // ── Singleton ──────────────────────────────────────────────────────────────
  static final ApiClient instance = ApiClient._();

  final Dio _dio;

  // ══════════════════════════════════════════════════════════════════════════
  // HTTP METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET request.
  ///
  /// [url]   – relative or absolute endpoint (e.g. `/user/profile`).
  /// [query] – optional query parameters appended to the URL.
  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// POST request.
  Future<Response<dynamic>> post(
    String url, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// PUT request.
  Future<Response<dynamic>> put(
    String url, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// PATCH request.
  Future<Response<dynamic>> patch(
    String url, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// DELETE request.
  Future<Response<dynamic>> delete(
    String url, {
    dynamic body,
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        url,
        data: body,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MULTIPART / FILE UPLOAD
  // ══════════════════════════════════════════════════════════════════════════

  /// POST with multipart form-data.
  ///
  /// [fields] – plain text fields (will be JSON-encoded).
  /// [files]  – map of field-name → [File] to attach.
  ///
  /// Example:
  /// ```dart
  /// await _api.postMultipart(
  ///   ApiEndpoints.uploadAvatar,
  ///   fields: {'userId': '123'},
  ///   files: {'avatar': File('/path/to/photo.jpg')},
  /// );
  /// ```
  Future<Response<dynamic>> postMultipart(
    String url, {
    Map<String, dynamic>? fields,
    Map<String, File>? files,
    Map<String, dynamic>? query,
  }) async {
    try {
      final formMap = <String, dynamic>{};

      if (fields != null) {
        formMap.addAll(fields);
      }

      if (files != null) {
        for (final entry in files.entries) {
          formMap[entry.key] = await MultipartFile.fromFile(
            entry.value.path,
            filename: entry.value.uri.pathSegments.last,
          );
        }
      }

      final formData = FormData.fromMap(formMap);

      return await _dio.post(
        url,
        data: formData,
        queryParameters: query,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// PATCH with multipart form-data (fields as top-level keys).
  Future<Response<dynamic>> patchMultipart(
    String url, {
    Map<String, dynamic>? fields,
    Map<String, File>? files,
    Map<String, dynamic>? query,
  }) async {
    try {
      final formMap = <String, dynamic>{};

      if (fields != null) {
        formMap.addAll(fields);
      }

      if (files != null) {
        for (final entry in files.entries) {
          formMap[entry.key] = await MultipartFile.fromFile(
            entry.value.path,
            filename: entry.value.uri.pathSegments.last,
          );
        }
      }

      final formData = FormData.fromMap(formMap);

      return await _dio.patch(
        url,
        data: formData,
        queryParameters: query,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Manually override the auth token (e.g. right after login).
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove the auth token (e.g. on logout).
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Add a custom base-level interceptor at runtime.
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
