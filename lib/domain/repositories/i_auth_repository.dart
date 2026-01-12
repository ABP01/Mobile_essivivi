import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_models.dart';

/// Authentication Repository Interface
/// Defines the contract for authentication operations
abstract class IAuthRepository {
  /// Login with username and password
  /// Returns [CustomUser] on success, [Failure] on error
  Future<Either<Failure, CustomUser>> login({
    required String username,
    required String password,
  });

  /// Sign up new user
  /// Returns [CustomUser] on success, [Failure] on error
  Future<Either<Failure, CustomUser>> signup({
    required SignupRequest request,
  });

  /// Logout current user
  Future<Either<Failure, Unit>> logout();

  /// Get current authenticated user
  Future<Either<Failure, CustomUser>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored user role
  Future<String?> getUserRole();

  /// Change user password
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// Refresh access token
  Future<Either<Failure, Unit>> refreshToken();
}
