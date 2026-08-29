import '../core/api_client.dart';
import '../core/errors.dart';

class GymsApi {
  GymsApi._();

  static Future<List<Map<String, dynamic>>> getGyms() async {
    try {
      final response = await ApiClient.get('/saas/gyms');

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> getGym(
      String gymId,
      ) async {
    try {
      final response = await ApiClient.get(
        '/saas/gyms/$gymId',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> createGym(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/saas/gyms',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> updateGym(
      String gymId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/saas/gyms/$gymId',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<void> disableGym(
      String gymId,
      ) async {
    try {
      await ApiClient.delete(
        '/saas/gyms/$gymId',
      );
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
      message: 'Invalid gym response.',
    );
  }

  static List<Map<String, dynamic>> _toList(
      dynamic data,
      ) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    }

    throw const ApiException(
      message: 'Invalid gyms response.',
    );
  }
}
