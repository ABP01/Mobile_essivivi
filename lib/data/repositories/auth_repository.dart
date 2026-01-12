import 'package:dartz/dartz.dart';
import '../datasources/api_service.dart';
import '../models/user_models.dart';
import '../../core/config/api_config.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository implements IAuthRepository {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  /// Login with username and password
  /// Returns Either<Failure, CustomUser>
  @override
  Future<Either<Failure, CustomUser>> login({
    required String username,
    required String password,
  }) async {
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
      final userResult = await getCurrentUser();
      
      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Store user info
          await _storage.write(
            key: ApiConfig.userEmailKey,
            value: user.email,
          );
          await _storage.write(
            key: ApiConfig.userRoleKey,
            value: user.role,
          );
          return Right(user);
        },
      );
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  /// Signup new user
  @override
  Future<Either<Failure, CustomUser>> signup({
    required SignupRequest request,
  }) async {
    try {
      await _apiService.client.post(
        ApiConfig.signupEndpoint,
        data: request.toJson(),
      );

      // After signup, login automatically
      return await login(username: request.username, password: request.password);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  /// Logout current user
  @override
  Future<Either<Failure, Unit>> logout() async {
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
    return Right(unit);
  }

  /// Get current user profile
  @override
  Future<Either<Failure, CustomUser>> getCurrentUser() async {
    try {
      final response = await _apiService.client.get(ApiConfig.meEndpoint);
      return Right(CustomUser.fromJson(response.data));
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  /// Legacy helper for backward compatibility with old screens
  /// Returns CustomUser directly or throws exception
  /// @deprecated Use getCurrentUser() with Either instead
  Future<CustomUser> getCurrentUserLegacy() async {
    final result = await getCurrentUser();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (user) => user,
    );
  }

  /// Check if user is authenticated
  @override
  Future<bool> isAuthenticated() async {
    final isAuth = await _storage.read(key: ApiConfig.isAuthenticatedKey);
    final accessToken = await _storage.read(key: ApiConfig.accessTokenKey);
    return isAuth == 'true' && accessToken != null;
  }

  /// Get stored user role
  @override
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
  @override
  Future<Either<Failure, Unit>> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: ApiConfig.refreshTokenKey);

      if (refreshToken == null) {
        return Left(AuthFailure('No refresh token available'));
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
      return Right(unit);
    } catch (e, stackTrace) {
      // If refresh fails, logout
      await logout();
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  /// Change user password
  @override
  Future<Either<Failure, Unit>> changePassword({
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
      return Right(unit);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }
}

