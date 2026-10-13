import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:senda/core/app_strings.dart';
import 'package:senda/core/clients/auth_client.dart';
import 'package:senda/core/constants.dart';
import 'package:senda/core/models/auth/login_request.dart';
import 'package:senda/core/models/auth/register_request.dart';
import 'package:senda/core/models/auth/user.dart';
import 'package:senda/core/models/storage_keys.dart';
import 'package:senda/core/providers/app_storage_provider.dart';
import 'package:senda/core/util/error_util.dart';
import 'package:senda/core/util/log_util.dart';

final class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final User? user;

  AuthState({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  AuthState copyWith({String? accessToken, String? refreshToken, User? user}) {
    return AuthState(
      accessToken: accessToken == kNullObject
          ? null
          : accessToken ?? this.accessToken,
      refreshToken: refreshToken == kNullObject
          ? null
          : refreshToken ?? this.refreshToken,
      user: user == kNullObject ? null : user ?? this.user,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return _load();
  }

  void _save(AuthState value) {
    final appStorage = ref.read(appStorageProvider);
    if (value.accessToken != null) {
      appStorage.put(AppStorageKey.authToken, value.accessToken!);
    } else {
      appStorage.delete(AppStorageKey.authToken);
    }

    if (value.refreshToken != null) {
      appStorage.put(AppStorageKey.refreshToken, value.refreshToken!);
    } else {
      appStorage.delete(AppStorageKey.refreshToken);
    }

    if (value.user != null) {
      appStorage.put(AppStorageKey.currentUser, value.user!.toJson());
    } else {
      appStorage.delete(AppStorageKey.currentUser);
    }
  }

  AuthState _load() {
    try {
      final appStorage = ref.read(appStorageProvider);
      final accessToken = appStorage.get(AppStorageKey.authToken) as String?;
      final refreshToken =
          appStorage.get(AppStorageKey.refreshToken) as String?;
      final userJsonStr = appStorage.get(AppStorageKey.currentUser) as String?;

      final user = userJsonStr != null
          ? User.fromJson(jsonDecode(userJsonStr) as Map<String, dynamic>)
          : null;

      return AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (e, st) {
      e.debugLog();
      st.debugLog();
      rethrow;
    }
  }

  void _clearStorage() {
    final appStorage = ref.read(appStorageProvider);
    appStorage.delete(AppStorageKey.authToken);
    appStorage.delete(AppStorageKey.refreshToken);
    appStorage.delete(AppStorageKey.currentUser);
  }

  /// Updates state and saves it to storage
  void updateAuthState({
    User? user,
    String? accessToken,
    String? refreshToken,
  }) {
    final previousState =
        state.value ??
        AuthState(accessToken: null, refreshToken: null, user: null);
    var newState = previousState.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
    state = AsyncValue.data(newState);
    _save(newState);
  }

  void clearAuthState() {
    state = AsyncValue.data(
      AuthState(accessToken: null, refreshToken: null, user: null),
    );
    _clearStorage();
  }

  void register({
    required String email,
    required String password,
    required String fullname,
    void Function()? onSuccess,
    void Function(Object error)? onError,
  }) async {
    try {
      final authClient = ref.read(authClientProvider);
      final response = await authClient.register(
        RegisterRequest(email: email, password: password, name: fullname),
      );

      if (response.accessToken != null &&
          response.refreshToken != null &&
          response.user != null) {
        updateAuthState(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: response.user,
        );
        onSuccess?.call();
      } else {
        throw response.detail ??
            response.message ??
            AppStrings.registrationFailed;
      }
    } catch (e) {
      onError?.call(e.toFriendlyMessage());
    }
  }

  void login({
    required String email,
    required String password,
    void Function()? onSuccess,
    void Function(Object)? onError,
  }) async {
    try {
      final authClient = ref.read(authClientProvider);
      final response = await authClient.login(
        LoginRequest(email: email, password: password),
      );
      if (response.accessToken != null &&
          response.refreshToken != null &&
          response.user != null) {
        updateAuthState(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: response.user,
        );
        onSuccess?.call();
      } else {
        throw response.detail ?? response.message ?? AppStrings.loginFailed;
      }
    } catch (e) {
      onError?.call(e.toFriendlyMessage());
    }
  }

  void logout({
    void Function()? onSuccess,
    void Function(Object error)? onError,
  }) {
    try {
      clearAuthState();
      onSuccess?.call();
    } catch (e) {
      onError?.call(e.toFriendlyMessage());
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
