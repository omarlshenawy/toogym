import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return message;
  }
}

class ApiException extends AppException {
  const ApiException({
    required super.message,
    super.statusCode,
  });

  factory ApiException.fromDio(DioException error) {
    final response = error.response;

    if (response != null) {
      final statusCode = response.statusCode;

      final message = _extractMessage(response.data);

      return ApiException(
        message: message,
        statusCode: statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'The request timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Unable to connect to the server.',
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'The request was cancelled.',
        );

      default:
        return const ApiException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }

      final error = data['error'];

      if (error is String && error.isNotEmpty) {
        return error;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return 'An unexpected server error occurred.';
  }
}