import '../core/api_client.dart';
import '../core/errors.dart';

class StaffApi {
  StaffApi._();

  static Future<List<Map<String, dynamic>>> getStaff() async {
    try {
      final response = await ApiClient.get('/staff');
      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> createStaff(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/staff',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateStaff(
      String staffId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/staff/$staffId',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  static Future<void> disableStaff(
      String staffId,
      ) async {
    try {
      await ApiClient.delete(
        '/staff/$staffId',
      );
    } on Exception catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  static Map<String, dynamic> _toMap(
      dynamic data,
      ) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const ApiException(
      message: 'Invalid server response.',
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
      message: 'Invalid staff response.',
    );
  }
}