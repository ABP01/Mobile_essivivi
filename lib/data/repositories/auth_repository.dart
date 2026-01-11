import '../datasources/api_service.dart';
import '../models/user_models.dart';
import '../../utils/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  /// Login with username and password
  /// Returns CustomUser on success, throws DioException on failure
  Future<CustomUser> login(String username, String password) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.loginEndpoint,
        data: {'username': username, 'password': password},
      );

      // Extract tokens
      final loginResponse = LoginResponse.fromJson(response.data);

      // Store tokens
      await _storage.write(
        key: ApiConfig.accessTokenKey,
        value: loginResponse.access,
      );
      await _storage.write(
        key: ApiConfig.refreshTokenKey,
        value: loginResponse.refresh,
      );
      await _storage.write(
        key: ApiConfig.isAuthenticatedKey,
        value: 'true',
      );

      // Fetch user profile
      final user = await getCurrentUser();

      // Store user info
      await _storage.write(
        key: ApiConfig.userEmailKey,
        value: user.email,
      );
      await _storage.write(
        key: ApiConfig.userRoleKey,
        value: user.role,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Signup new user
  Future<CustomUser> signup(SignupRequest signupRequest) async {
    try {
      await _apiService.client.post(
        ApiConfig.signupEndpoint,
        data: signupRequest.toJson(),
      );

      // After signup, login automatically
      return await login(signupRequest.username, signupRequest.password);
    } catch (e) {
      rethrow;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: ApiConfig.refreshTokenKey);

      if (refreshToken != null) {
        await _apiService.client.post(
          ApiConfig.logoutEndpoint,
          data: {'refresh': refreshToken},
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear all stored data
      await _storage.delete(key: ApiConfig.accessTokenKey);
      await _storage.delete(key: ApiConfig.refreshTokenKey);
      await _storage.delete(key: ApiConfig.userEmailKey);
      await _storage.delete(key: ApiConfig.userRoleKey);
      await _storage.delete(key: ApiConfig.isAuthenticatedKey);
    }
  }

  /// Get current user profile
  Future<CustomUser> getCurrentUser() async {
    try {
      final response = await _apiService.client.get(ApiConfig.meEndpoint);
      return CustomUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final isAuth = await _storage.read(key: ApiConfig.isAuthenticatedKey);
    final accessToken = await _storage.read(key: ApiConfig.accessTokenKey);
    return isAuth == 'true' && accessToken != null;
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: ApiConfig.userRoleKey);
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: ApiConfig.userEmailKey);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: ApiConfig.accessTokenKey);
  }

  /// Refresh access token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: ApiConfig.refreshTokenKey);

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiService.client.post(
        ApiConfig.tokenRefreshEndpoint,
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await _storage.write(
        key: ApiConfig.accessTokenKey,
        value: newAccessToken,
      );
    } catch (e) {
      // If refresh fails, logout
      await logout();
      rethrow;
    }
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.client.post(
        ApiConfig.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      
      // Password changed successfully
    } catch (e) {
      rethrow;
    }
  }
}

