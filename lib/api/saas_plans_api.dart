import '../core/api_client.dart';
import '../core/errors.dart';

class SaasPlansApi {
  SaasPlansApi._();

  static Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      final response = await ApiClient.get('/saas/plans');
      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> createPlan(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/saas/plans',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> updatePlan(
      String planId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/saas/plans/$planId',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const ApiException(
      message: 'Invalid SaaS plan response.',
    );
  }

  static List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    }

    throw const ApiException(
      message: 'Invalid SaaS plans response.',
    );
  }
}
