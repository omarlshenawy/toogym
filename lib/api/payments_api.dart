import '../core/api_client.dart';
import '../core/errors.dart';

class PaymentsApi {
  PaymentsApi._();

  static Future<List<Map<String, dynamic>>>
  getPayments() async {
    try {
      final response =
      await ApiClient.get(
        '/payments',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>>
  getPayment(
      String id,
      ) async {
    try {
      final response =
      await ApiClient.get(
        '/payments/$id',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        message: e.toString(),
      );
    }
  }

  static Future<Map<String, dynamic>>
  createPayment(
      Map<String, dynamic> data,
      ) async {
    try {
      final response =
      await ApiClient.post(
        '/payments',
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
      message:
      'Invalid payment response.',
    );
  }

  static List<Map<String, dynamic>>
  _toList(
      dynamic data,
      ) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item,
        ),
      )
          .toList();
    }

    throw const ApiException(
      message:
      'Invalid payments response.',
    );
  }
}