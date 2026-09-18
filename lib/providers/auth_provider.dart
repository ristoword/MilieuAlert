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
  final String? country;
  final String? preferredLanguage;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.email,
    this.displayName,
    this.country,
    this.preferredLanguage,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? email,
    String? displayName,
    String? country,
    String? preferredLanguage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      country: country ?? this.country,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
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
    _ensureTrialStart();
    _loadSavedAuth();
  }

  void _ensureTrialStart() {
    if (_prefs.getString('trial_started_at') != null) return;
    _prefs.setString(
      'trial_started_at',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  void _loadSavedAuth() {
    final token = _prefs.getString('auth_token');
    final email = _prefs.getString('user_email');
    final name = _prefs.getString('user_name');
    final country = _prefs.getString('user_country');
    final language = _prefs.getString('locale');

    if (token != null && token.isNotEmpty) {
      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: email,
        displayName: name,
        country: country,
        preferredLanguage: language,
      );
    }
  }

  Options _authOptions() {
    final token = state.token;
    return Options(
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        if (_prefs.getString('trial_started_at') != null)
          'X-Trial-Started-At': _prefs.getString('trial_started_at'),
      },
    );
  }

  Future<void> _persistSession({
    required String token,
    required String email,
    required String displayName,
    String? country,
    String? language,
  }) async {
    await _prefs.setString('auth_token', token);
    await _prefs.setString('user_email', email);
    await _prefs.setString('user_name', displayName);
    if (country != null && country.isNotEmpty) {
      await _prefs.setString('user_country', country);
    }
    if (language != null && language.isNotEmpty) {
      await _prefs.setString('locale', language.toLowerCase());
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
      final country = user['country'] as String?;

      if (rememberMe) {
        await _persistSession(
          token: token,
          email: user['email'] as String? ?? email,
          displayName: displayName,
          country: country,
          language: language,
        );
      }

      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: user['email'] as String? ?? email,
        displayName: displayName,
        country: country,
        preferredLanguage: language,
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
          if (_prefs.getString('trial_started_at') != null)
            'trial_started_at': _prefs.getString('trial_started_at'),
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

      await _persistSession(
        token: token,
        email: email,
        displayName: displayName,
        country: country,
        language: preferredLanguage,
      );

      state = AuthState(
        isAuthenticated: true,
        token: token,
        email: email,
        displayName: displayName,
        country: country,
        preferredLanguage: preferredLanguage.toLowerCase(),
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
    await _prefs.remove('user_country');
    state = const AuthState();
  }

  Future<bool> refreshProfile() async {
    if (state.token == null || state.token!.isEmpty) return false;
    try {
      final response = await _dio.get(
        '/api/users/me',
        options: _authOptions(),
      );
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : jsonDecode(response.data as String) as Map<String, dynamic>;
      _applyProfileMap(data, token: state.token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    required String email,
    required String country,
    required String preferredLanguage,
    String? password,
    Map<String, dynamic>? vehicle,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim().toLowerCase();
    final lang = preferredLanguage.toLowerCase();

    if (trimmedName.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Name is required',
      );
      return false;
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Enter a valid email',
      );
      return false;
    }
    if (password != null && password.isNotEmpty && password.length < 8) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Password must be at least 8 characters',
      );
      return false;
    }

    try {
      final payload = <String, dynamic>{
        'display_name': trimmedName,
        'email': trimmedEmail,
        'country': country,
        'preferred_language': lang,
        if (password != null && password.isNotEmpty) 'password': password,
        if (vehicle != null) 'vehicle': vehicle,
      };

      Response response;
      try {
        response = await _dio.patch(
          '/api/users/profile',
          data: payload,
          options: _authOptions(),
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.patch(
            '/api/auth/me',
            data: payload,
            options: _authOptions(),
          );
        } else {
          rethrow;
        }
      }

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : jsonDecode(response.data as String) as Map<String, dynamic>;
      final user = data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : data;
      _applyProfileMap(
        user,
        token: data['token'] as String? ?? state.token,
      );
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on DioException catch (e) {
      final msg = _extractError(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not save profile: $e',
      );
      return false;
    }
  }

  void _applyProfileMap(Map<String, dynamic> data, {String? token}) {
    final email = data['email'] as String? ?? state.email ?? '';
    final displayName =
        data['display_name'] as String? ?? data['email'] as String? ?? email;
    final country = data['country'] as String? ?? state.country;
    final language =
        (data['preferred_language'] as String?)?.toLowerCase() ??
            state.preferredLanguage;
    final nextToken = token ?? state.token ?? '';
    if (nextToken.isNotEmpty) {
      _persistSession(
        token: nextToken,
        email: email,
        displayName: displayName,
        country: country,
        language: language,
      );
    }
    state = state.copyWith(
      isAuthenticated: true,
      token: nextToken.isEmpty ? state.token : nextToken,
      email: email,
      displayName: displayName,
      country: country,
      preferredLanguage: language,
      isLoading: false,
      clearError: true,
    );
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
