import '../core/api_client.dart';
import '../core/errors.dart';

class AuthApi {
  AuthApi._();

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return _asMap(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // ------------------------------------------------------------
  // VERIFY ACTIVATION
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> verifyActivation({
    required String username,
    required String activationCode,
  }) async {
    try {
      final response = await ApiClient.post(
        '/auth/verify-activation',
        data: {
          'username': username,
          'activation_code': activationCode,
        },
      );

      return _asMap(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // ------------------------------------------------------------
  // SETUP PASSWORD
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> setupPassword({
    required String username,
    required String activationCode,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        '/auth/setup-password',
        data: {
          'username': username,
          'activation_code': activationCode,
          'password': password,
        },
      );

      return _asMap(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // ------------------------------------------------------------
  // CURRENT USER
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> me() async {
    try {
      final response = await ApiClient.get(
        '/auth/me',
      );

      return _asMap(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  static Future<Map<String, dynamic>> logout() async {
    try {
      final response = await ApiClient.post(
        '/auth/logout',
      );

      return _asMap(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Map<String, dynamic> _asMap(
      dynamic data,
      ) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw const ApiException(
      message:
      'Invalid response received from server.',
    );
  }
}