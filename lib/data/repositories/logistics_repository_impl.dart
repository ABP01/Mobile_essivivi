import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/repositories/i_logistics_repository.dart';
import '../models/logistics_models.dart';
import './logistics_repository.dart';

/// Logistics Repository Implementation
class LogisticsRepositoryImpl implements ILogisticsRepository {
  final LogisticsRepository _repository = LogisticsRepository();

  @override
  Future<Either<Failure, List<Tournee>>> getTournees() async {
    try {
      final result = await _repository.getTournees();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Tournee>> getTournee(int id) async {
    try {
      final result = await _repository.getTourneeById(id);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Tournee>>> getActiveTournees() async {
    try {
      final result = await _repository.getActiveTournees();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Tournee>>> getTourneesByAgent(int agentId) async {
    try {
      final result = await _repository.getTourneesByAgent(agentId);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Tournee>> createTournee({
    required CreateTourneeRequest request,
  }) async {
    try {
      final result = await _repository.createTournee(request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Tournee>> updateTournee({
    required int id,
    required UpdateTourneeRequest request,
  }) async {
    try {
      final result = await _repository.updateTournee(id, request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAgents() async {
    return Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, dynamic>> getAgent(int id) async {
    return Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, dynamic>> updateAgentAvailability({
    required int id,
    required bool isAvailable,
  }) async {
    return Left(ServerFailure('Not implemented yet'));
  }

  @override
  Future<Either<Failure, Unit>> trackAgentLocation({
    required int agentId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _repository.updateAgentLocation(agentId, latitude, longitude, null, null, null);
      return Right(unit);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }
}
