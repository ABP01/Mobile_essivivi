import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/logistics_models.dart';

/// Logistics Repository Interface
/// Defines the contract for logistics operations
abstract class ILogisticsRepository {
  /// Get all tournees
  Future<Either<Failure, List<Tournee>>> getTournees();

  /// Get active tournees
  Future<Either<Failure, List<Tournee>>> getActiveTournees();

  /// Get tournee by ID
  Future<Either<Failure, Tournee>> getTournee(int id);

  /// Get tournees by agent ID
  Future<Either<Failure, List<Tournee>>> getTourneesByAgent(int agentId);

  /// Create new tournee
  Future<Either<Failure, Tournee>> createTournee({
    required CreateTourneeRequest request,
  });

  /// Update tournee
  Future<Either<Failure, Tournee>> updateTournee({
    required int id,
    required UpdateTourneeRequest request,
  });

  /// Get all agents
  Future<Either<Failure, List<dynamic>>> getAgents();

  /// Get agent by ID
  Future<Either<Failure, dynamic>> getAgent(int id);

  /// Update agent availability
  Future<Either<Failure, dynamic>> updateAgentAvailability({
    required int id,
    required bool isAvailable,
  });

  /// Track agent location
  Future<Either<Failure, Unit>> trackAgentLocation({
    required int agentId,
    required double latitude,
    required double longitude,
  });
}
