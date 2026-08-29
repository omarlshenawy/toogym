import '../core/api_client.dart';
import '../core/errors.dart';

class SubscriptionsApi {
  SubscriptionsApi._();

  static Future<List<Map<String, dynamic>>>
  getSubscriptions() async {
    try {
      final response =
      await ApiClient.get(
        '/subscriptions',
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
  getSubscription(
      String id,
      ) async {
    try {
      final response =
      await ApiClient.get(
        '/subscriptions/$id',
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
  createSubscription(
      Map<String, dynamic> data,
      ) async {
    try {
      final response =
      await ApiClient.post(
        '/subscriptions',
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

  static Future<Map<String, dynamic>>
  updateSubscription(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      final response =
      await ApiClient.patch(
        '/subscriptions/$id',
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
      'Invalid subscription response.',
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
      'Invalid subscriptions response.',
    );
  }
}