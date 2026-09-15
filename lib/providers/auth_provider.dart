import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'settings_provider.dart';

// --- Auth State ---

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? email;
  final String? displayName;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.email,
    this.displayName,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? email,
    String? displayName,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// --- Auth Notifier ---

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthNotifier(this._prefs)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )),
        super(const AuthState()) {
    _loadSavedAuth();
  }

  void _loadSavedAuth() {
    final token = _prefs.getString('auth_token');
    final email = _prefs.getString('user_email');
    final name = _prefs.getString('user_name');

    if (token != null && token.isNotEmpty) {
      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: email,
        displayName: name,
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : jsonDecode(response.data as String) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
            isLoading: false, errorMessage: 'Invalid server response');
        return false;
      }
      final user = Map<String, dynamic>.from(data['user'] as Map? ?? {});
      final displayName =
          user['display_name'] as String? ?? user['email'] as String? ?? email;
      final language = (user['preferred_language'] as String?)?.toLowerCase();

      if (rememberMe) {
        await _prefs.setString('auth_token', token);
        await _prefs.setString('user_email', email);
        await _prefs.setString('user_name', displayName);
        if (language != null && language.isNotEmpty) {
          await _prefs.setString('locale', language);
        }
      }

      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: email,
        displayName: displayName,
      );
      return true;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Unexpected error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String preferredLanguage,
    required String country,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
          'preferred_language': preferredLanguage.toLowerCase(),
          'country': country,
        },
      );

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : jsonDecode(response.data as String) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        state = state.copyWith(
            isLoading: false, errorMessage: 'Invalid server response');
        return false;
      }

      await _prefs.setString('auth_token', token);
      await _prefs.setString('user_email', email);
      await _prefs.setString('user_name', displayName);
      await _prefs.setString('locale', preferredLanguage.toLowerCase());

      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: email,
        displayName: displayName,
      );
      return true;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Unexpected error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_email');
    await _prefs.remove('user_name');
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _extractError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data is String) return data;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check your connection.';
    }
    return e.message ?? 'An unknown error occurred.';
  }
}

// --- Providers ---

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AuthNotifier(prefs);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
