import 'package:dio/dio.dart';

import 'constants.dart';
import 'errors.dart';
import 'storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl:
      '${AppConstants.apiBaseUrl}${AppConstants.apiPrefix}',
      connectTimeout:
      const Duration(seconds: 15),
      receiveTimeout:
      const Duration(seconds: 30),
      sendTimeout:
      const Duration(seconds: 30),
      headers: {
        'Content-Type':
        'application/json',
        'Accept':
        'application/json',
      },
    ),
  )
    ..interceptors.add(
      _AuthInterceptor(),
    )
    ..interceptors.add(
      _ErrorInterceptor(),
    );

  // ------------------------------------------------------------
  // GET
  // ------------------------------------------------------------

  static Future<Response<dynamic>> get(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.get(
      path,
      queryParameters:
      queryParameters,
    );
  }

  // ------------------------------------------------------------
  // POST
  // ------------------------------------------------------------

  static Future<Response<dynamic>> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.post(
      path,
      data: data,
      queryParameters:
      queryParameters,
    );
  }

  // ------------------------------------------------------------
  // PATCH
  // ------------------------------------------------------------

  static Future<Response<dynamic>> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.patch(
      path,
      data: data,
      queryParameters:
      queryParameters,
    );
  }

  // ------------------------------------------------------------
  // PUT
  // ------------------------------------------------------------

  static Future<Response<dynamic>> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.put(
      path,
      data: data,
      queryParameters:
      queryParameters,
    );
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  static Future<Response<dynamic>> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) {
    return dio.delete(
      path,
      data: data,
      queryParameters:
      queryParameters,
    );
  }
}

// ================================================================
// AUTH INTERCEPTOR
// ================================================================

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    final token =
    AppStorage.getString(
      AppConstants.accessTokenKey,
    );

    if (token != null &&
        token.isNotEmpty) {
      options.headers[
      'Authorization'] =
      'Bearer $token';
    }

    handler.next(options);
  }
}

// ================================================================
// ERROR INTERCEPTOR
// ================================================================

class _ErrorInterceptor
    extends Interceptor {
  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    final apiException =
    ApiException.fromDio(err);

    handler.reject(
      DioException(
        requestOptions:
        err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message:
        apiException.message,
      ),
    );
  }
}