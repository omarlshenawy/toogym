import '../core/api_client.dart';
import '../core/errors.dart';

class GymSettingsApi {
  GymSettingsApi._();

  static Future<Map<String, dynamic>>
  getGym() async {
    try {
      final response =
      await ApiClient.get(
        '/gym',
      );

      return _toMap(
        response.data,
      );
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>>
  updateGym(
      Map<String, dynamic> data,
      ) async {
    try {
      final response =
      await ApiClient.patch(
        '/gym',
        data: data,
      );

      return _toMap(
        response.data,
      );
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<void> testConnection() async {
    try {
      await ApiClient.get('/health');
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
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
      message:
      'Invalid gym response.',
    );
  }
}