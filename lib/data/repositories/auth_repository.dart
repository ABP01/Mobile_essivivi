import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/user_models.dart';

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
      await _storage.write(key: ApiConfig.isAuthenticatedKey, value: 'true');

      // Fetch user profile
      final user = await getCurrentUser();

      // Store user info
      await _storage.write(key: ApiConfig.userEmailKey, value: user.email);
      await _storage.write(key: ApiConfig.userRoleKey, value: user.role);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Exchange Appwrite JWT for Django tokens
  /// Returns CustomUser on success
  Future<CustomUser> appwriteLogin(String jwt) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.appwriteLoginEndpoint,
        data: {'jwt': jwt},
      );

      // Extract tokens
      final data = response.data;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];
      final userData =
          data['user']; // Assuming the endpoint returns user object too

      // Store tokens
      await _storage.write(key: ApiConfig.accessTokenKey, value: accessToken);
      await _storage.write(key: ApiConfig.refreshTokenKey, value: refreshToken);
      await _storage.write(key: ApiConfig.isAuthenticatedKey, value: 'true');

      // Return user
      return CustomUser.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  /// Signup new user
  Future<CustomUser> signup(SignupRequest signupRequest) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.signupEndpoint,
        data: signupRequest.toJson(),
      );

      // If the backend returns the tokens and user (as our Django RegisterView does),
      // store them and return the created user instead of calling login again.
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;
        final userData = data['user'];

        if (access != null &&
            refresh != null &&
            userData is Map<String, dynamic>) {
          await _storage.write(key: ApiConfig.accessTokenKey, value: access);
          await _storage.write(key: ApiConfig.refreshTokenKey, value: refresh);
          await _storage.write(
            key: ApiConfig.isAuthenticatedKey,
            value: 'true',
          );

          // Store user info if available
          final email = userData['email'] as String?;
          final role = userData['role'] as String?;
          if (email != null)
            await _storage.write(key: ApiConfig.userEmailKey, value: email);
          if (role != null)
            await _storage.write(key: ApiConfig.userRoleKey, value: role);

          return CustomUser.fromJson(userData as Map<String, dynamic>);
        }
      }

      // Fallback: call login to retrieve tokens/profile
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

  /// Reset password request
  /// Sends reset email to user
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiService.client.post(
        '${ApiConfig.baseUrl}/users/auth/password-reset/',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Confirm password reset with token
  /// Returns success message
  Future<String> confirmPasswordReset(String token, String newPassword) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.baseUrl}/users/auth/password-reset-confirm/',
        data: {'token': token, 'new_password': newPassword},
      );
      return response.data['message'] ?? 'Password reset successfully';
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
