import '../core/api_client.dart';
import '../core/errors.dart';

class MeasurementsApi {
  MeasurementsApi._();

  static Future<List<Map<String, dynamic>>> getMeasurements(
      String memberId,
      ) async {
    try {
      final response = await ApiClient.get(
        '/members/$memberId/measurements',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>> createMeasurement(
      String memberId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/members/$memberId/measurements',
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

  static Future<Map<String, dynamic>> updateMeasurement(
      String memberId,
      String measurementId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/members/$memberId/measurements/$measurementId',
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

  static Map<String, dynamic> _toMap(
      dynamic data,
      ) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const ApiException(
      message: 'Invalid measurement response.',
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
      message: 'Invalid measurements response.',
    );
  }
}