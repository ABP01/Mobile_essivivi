import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../models/user_models.dart';
import './user_repository.dart';

/// User Repository Implementation
class UserRepositoryImpl implements IUserRepository {
  final UserRepository _repository = UserRepository();

  @override
  Future<Either<Failure, ClientProfile>> getClientProfile(int clientId) async {
    try {
      final result = await _repository.getClientById(clientId);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<ClientProfile>>> getClients() async {
    try {
      final result = await _repository.getClients();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> getClient(int id) async {
    try {
      final result = await _repository.getClientById(id);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> getClientByUserId(int userId) async {
    // TODO: Implement when backend supports it
    return Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, ClientProfile>> updateClientProfile({
    required int clientId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await _repository.updateClient(clientId, data);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> updateClient({
    required int id,
    required Map<String, dynamic> request,
  }) async {
    try {
      final result = await _repository.updateClient(id, request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, CustomUser>> getUser(int id) async {
    try {
      final result = await _repository.getUserById(id);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<CustomUser>>> getUsers() async {
    try {
      final result = await _repository.getUsers();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, CustomUser>> updateUser({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final result = await _repository.updateUser(id, data);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }
}
