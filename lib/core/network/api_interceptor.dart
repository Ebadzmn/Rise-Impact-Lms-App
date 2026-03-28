import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../services/storage_service.dart';
import 'api_endpoints.dart';
import '../../routes/app_router.dart';
import '../../routes/app_routes.dart';

/// A Dio [InterceptorsWrapper] that:
///   • Injects the Bearer token from [StorageService].
///   • Logs every request / response / error (debug-mode only).
///   • Handles 401 – clears local storage and redirects to login.
class ApiInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ── Inject token ────────────────────────────────────────────────────────
    try {
      final storage = Get.find<StorageService>();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // StorageService not yet registered – skip token injection
    }

    // ── Request log ─────────────────────────────────────────────────────────
    if (kDebugMode) {
      debugPrint('╔══════════ API REQUEST ══════════╗');
      debugPrint('║ URL    : ${options.uri}');
      debugPrint('║ METHOD : ${options.method}');
      debugPrint('║ HEADERS: ${options.headers}');
      debugPrint('║ QUERY  : ${options.queryParameters}');
      debugPrint('║ BODY   : ${options.data}');
      debugPrint('╚═════════════════════════════════╝');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ── Response log ────────────────────────────────────────────────────────
    if (kDebugMode) {
      debugPrint('╔══════════ API RESPONSE ══════════╗');
      debugPrint('║ STATUS : ${response.statusCode}');
      debugPrint('║ DATA   : ${response.data}');
      debugPrint('╚══════════════════════════════════╝');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ── Error log ───────────────────────────────────────────────────────────
    if (kDebugMode) {
      debugPrint('╔══════════ API ERROR ══════════╗');
      debugPrint('║ URL    : ${err.requestOptions.uri}');
      debugPrint('║ METHOD : ${err.requestOptions.method}');
      debugPrint('║ STATUS : ${err.response?.statusCode}');
      debugPrint('║ MESSAGE: ${err.message}');
      debugPrint('╚═══════════════════════════════╝');
    }

    // ── 401 – unauthorised ──────────────────────────────────────────────────
    if (err.response?.statusCode == 401) {
      try {
        final storage = Get.find<StorageService>();
        final refreshToken = storage.getRefreshToken();

        if (refreshToken != null && refreshToken.isNotEmpty) {
          final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
          try {
            final response = await dio.post(
              ApiEndpoints.refreshToken,
              options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
            );

            final data = response.data['data'];
            if (data != null && data['accessToken'] != null && data['refreshToken'] != null) {
              final newAccessToken = data['accessToken'];
              final newRefreshToken = data['refreshToken'];

              storage.saveTokens(newAccessToken, newRefreshToken);

              // Retry original request
              err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final retryResponse = await dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            }
          } catch (e) {
            storage.clearAll();
            AppRouter.router.go(AppRoutes.login);
            return handler.next(err);
          }
        }
        
        storage.clearAll();
        AppRouter.router.go(AppRoutes.login);
        return handler.next(err);
        
      } catch (_) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}

/// Thin wrapper around [DioException] so callers get a strongly-typed error.
class NetworkException implements Exception {
  const NetworkException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  // Convenience factory from a raw [DioException].
  factory NetworkException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Request timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection.',
        );
      default:
        return NetworkException(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Something went wrong.',
          statusCode: e.response?.statusCode,
        );
    }
  }

  @override
  String toString() =>
      'NetworkException(statusCode: $statusCode, message: $message)';
}

/// Builds and returns a fully configured [Dio] instance.
Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(ApiInterceptor());

  return dio;
}
