import '../core/api_client.dart';
import '../core/errors.dart';

class GymSubscriptionsApi {
  GymSubscriptionsApi._();

  static Future<List<Map<String, dynamic>>> getSubscriptions() async {
    try {
      final response = await ApiClient.get(
        '/saas/gym-subscriptions',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> createSubscription(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/saas/gym-subscriptions',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateSubscription(
      String subscriptionId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/saas/gym-subscriptions/$subscriptionId',
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
      message: 'Invalid gym subscription response.',
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
      message: 'Invalid gym subscriptions response.',
    );
  }
}