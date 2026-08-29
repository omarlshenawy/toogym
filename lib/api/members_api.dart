import '../core/api_client.dart';
import '../core/errors.dart';

class MembersApi {
  MembersApi._();

  // ============================================================
  // Members
  // ============================================================

  static Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final response = await ApiClient.get('/members');

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> getMember(
      String memberId,
      ) async {
    try {
      final response = await ApiClient.get(
        '/members/$memberId',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> createMember(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/members',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> updateMember(
      String memberId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.patch(
        '/members/$memberId',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<void> deleteMember(
      String memberId,
      ) async {
    try {
      await ApiClient.delete(
        '/members/$memberId',
      );
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  // ============================================================
  // Subscriptions
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getSubscriptions() async {
    try {
      final response = await ApiClient.get(
        '/subscriptions',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>>
  createSubscription(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/subscriptions',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  // ============================================================
  // Payments
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getPayments() async {
    try {
      final response = await ApiClient.get(
        '/payments',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await ApiClient.post(
        '/payments',
        data: data,
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  // ============================================================
  // Attendance
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getAttendance() async {
    try {
      final response = await ApiClient.get(
        '/attendance',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> checkIn(
      String memberId,
      ) async {
    try {
      final response = await ApiClient.post(
        '/attendance/check-in',
        data: {
          'member_id': memberId,
        },
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>> checkOut(
      String attendanceId,
      ) async {
    try {
      final response = await ApiClient.post(
        '/attendance/$attendanceId/check-out',
      );

      return _toMap(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  // ============================================================
  // Measurements
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getMeasurements(
      String memberId,
      ) async {
    try {
      final response = await ApiClient.get(
        '/members/$memberId/measurements',
      );

      return _toList(response.data);
    } on Exception catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>>
  createMeasurement(
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

      throw ApiException(message: e.toString());
    }
  }

  static Future<Map<String, dynamic>>
  updateMeasurement(
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

      throw ApiException(message: e.toString());
    }
  }

  // ============================================================
  // Helpers
  // ============================================================

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
      message: 'Invalid list response from server.',
    );
  }
}