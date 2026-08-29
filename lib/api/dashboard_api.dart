import '../core/api_client.dart';
import '../core/errors.dart';

class DashboardApi {
  DashboardApi._();

  static Future<Map<String, dynamic>> getSaasDashboard() async {
    try {
      final response = await ApiClient.get(
        '/saas/dashboard',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> getGymDashboard() async {
    try {
      final response = await ApiClient.get(
        '/gym/dashboard',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> getStaffDashboard() async {
    try {
      final response = await ApiClient.get(
        '/staff/dashboard',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> getForRole(
      String role,
      ) async {
    switch (role) {
      case 'saas_admin':
        return getSaasDashboard();

      case 'staff':
        return getStaffDashboard();

      case 'gym_admin':
        return getGymDashboard();

      default:
        throw const ApiException(
          message: 'Unknown user role.',
        );
    }
  }

  static Map<String, dynamic> _toMap(
      dynamic data,
      ) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const ApiException(
      message: 'Invalid dashboard response.',
    );
  }
}