import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/user_models.dart';

/// User Repository Interface
/// Defines the contract for user management operations
abstract class IUserRepository {
  /// Get all clients
  Future<Either<Failure, List<ClientProfile>>> getClients();

  /// Get client by ID
  Future<Either<Failure, ClientProfile>> getClient(int id);

  /// Get client by user ID
  Future<Either<Failure, ClientProfile>> getClientByUserId(int userId);

  /// Update client profile
  Future<Either<Failure, ClientProfile>> updateClient({
    required int id,
    required Map<String, dynamic> request,
  });

  /// Get all users
  Future<Either<Failure, List<CustomUser>>> getUsers();

  /// Get user by ID
  Future<Either<Failure, CustomUser>> getUser(int id);

  /// Update user profile
  Future<Either<Failure, CustomUser>> updateUser({
    required int id,
    required Map<String, dynamic> data,
  });
}
