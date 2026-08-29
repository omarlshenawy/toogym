import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/auth_api.dart';
import 'constants.dart';
import 'errors.dart';
import 'storage.dart';

class AuthUser {
  final String id;
  final String username;
  final String role;
  final String status;
  final String? firstName;
  final String? lastName;
  final String? gymId;

  const AuthUser({
    required this.id,
    required this.username,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
    this.gymId,
  });

  factory AuthUser.fromJson(
      Map<String, dynamic> json,
      ) {
    return AuthUser(
      id: json['id']?.toString() ?? '',
      username:
      json['username']?.toString() ?? '',
      role:
      json['role']?.toString() ?? '',
      status:
      json['status']?.toString() ?? '',
      firstName:
      json['first_name']?.toString(),
      lastName:
      json['last_name']?.toString(),
      gymId:
      json['gym_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'status': status,
      'first_name': firstName,
      'last_name': lastName,
      'gym_id': gymId,
    };
  }

  String get displayName {
    final names = [
      firstName,
      lastName,
    ]
        .where(
          (value) =>
      value != null &&
          value.isNotEmpty,
    )
        .join(' ');

    return names.isNotEmpty
        ? names
        : username;
  }

  bool get isSaasAdmin =>
      role == 'saas_admin';

  bool get isGymAdmin =>
      role == 'gym_admin';

  bool get isStaff =>
      role == 'staff';

  bool get isActive =>
      status == 'active';
}

// ================================================================
// AUTH STATUS
// ================================================================

enum AuthStatus {
  unknown,
  loading,
  authenticated,
  unauthenticated,
}

// ================================================================
// AUTH STATE
// ================================================================

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.unknown()
      : status =
      AuthStatus.unknown,
        user = null,
        error = null;

  const AuthState.loading()
      : status =
      AuthStatus.loading,
        user = null,
        error = null;

  const AuthState.authenticated(
      AuthUser user,
      )   : status =
      AuthStatus.authenticated,
        user = user,
        error = null;

  const AuthState.unauthenticated({
    String? error,
  })  : status =
      AuthStatus.unauthenticated,
        user = null,
        error = error;

  bool get isAuthenticated =>
      status ==
          AuthStatus.authenticated &&
          user != null;
}

// ================================================================
// AUTH CONTROLLER
// ================================================================

class AuthController
    extends StateNotifier<AuthState> {
  AuthController()
      : super(
    const AuthState.unknown(),
  ) {
    restoreSession();
  }

  // ------------------------------------------------------------
  // RESTORE SESSION
  // ------------------------------------------------------------

  Future<void> restoreSession() async {
    final token =
    AppStorage.getString(
      AppConstants.accessTokenKey,
    );

    final storedUser =
    AppStorage.getJson(
      AppConstants.userKey,
    );

    if (token == null ||
        token.isEmpty ||
        storedUser == null) {
      state =
      const AuthState.unauthenticated();
      return;
    }

    try {
      // Restore immediately from local storage.
      final localUser =
      AuthUser.fromJson(
        storedUser,
      );

      state =
          AuthState.authenticated(
            localUser,
          );

      // Then verify the token remotely.
      try {
        final remoteData =
        await AuthApi.me();

        final remoteUser =
        AuthUser.fromJson(
          remoteData,
        );

        await _saveUser(
          remoteUser,
        );

        state =
            AuthState.authenticated(
              remoteUser,
            );
      } catch (_) {
        // Token is invalid/expired.
        await logout(
          localOnly: true,
        );
      }
    } catch (_) {
      await logout(
        localOnly: true,
      );
    }
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    state =
    const AuthState.loading();

    try {
      final response =
      await AuthApi.login(
        username:
        username.trim(),
        password: password,
      );

      final token =
      response[
      'access_token'];

      final userData =
      response['user'];

      if (token is! String ||
          token.isEmpty) {
        throw const ApiException(
          message:
          'The server did not return an access token.',
        );
      }

      if (userData
      is! Map<String, dynamic>) {
        throw const ApiException(
          message:
          'The server returned an invalid user.',
        );
      }

      final user =
      AuthUser.fromJson(
        userData,
      );

      if (user.id.isEmpty ||
          user.username.isEmpty ||
          user.role.isEmpty) {
        throw const ApiException(
          message:
          'The server returned incomplete user information.',
        );
      }

      // Save token FIRST.
      await AppStorage.setString(
        AppConstants.accessTokenKey,
        token,
      );

      // Save user.
      await _saveUser(user);

      // Update application state.
      state =
          AuthState.authenticated(
            user,
          );

      return user;
    } catch (e) {
      final message =
      _errorMessage(e);

      state =
          AuthState.unauthenticated(
            error: message,
          );

      throw ApiException(
        message: message,
      );
    }
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> logout({
    bool localOnly = false,
  }) async {
    if (!localOnly) {
      try {
        await AuthApi.logout();
      } catch (_) {
        // Local logout must still happen.
      }
    }

    await AppStorage.remove(
      AppConstants.accessTokenKey,
    );

    await AppStorage.remove(
      AppConstants.userKey,
    );

    state =
    const AuthState.unauthenticated();
  }

  // ------------------------------------------------------------
  // SAVE USER
  // ------------------------------------------------------------

  Future<void> _saveUser(
      AuthUser user,
      ) async {
    await AppStorage.setString(
      AppConstants.userKey,
      jsonEncode(
        user.toJson(),
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR
  // ------------------------------------------------------------

  String _errorMessage(
      Object error,
      ) {
    if (error
    is ApiException) {
      return error.message;
    }

    if (error
    is DioException) {
      if (error.error
      is ApiException) {
        return (error.error
        as ApiException)
            .message;
      }

      return error.message ??
          'Unable to connect to the server.';
    }

    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}

// ================================================================
// PROVIDER
// ================================================================

final authProvider =
StateNotifierProvider<
    AuthController,
    AuthState>(
      (ref) {
    return AuthController();
  },
);