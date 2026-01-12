import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/error_handler.dart';
import '../../domain/repositories/i_sales_repository.dart';
import '../models/sales_models.dart';
import './sales_repository.dart';

/// Sales Repository Implementation
/// Wraps existing SalesRepository to implement ISalesRepository interface
class SalesRepositoryImpl implements ISalesRepository {
  final SalesRepository _repository = SalesRepository();

  @override
  Future<Either<Failure, List<Commande>>> getCommandes() async {
    try {
      final result = await _repository.getCommandes();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Commande>>> getCommandesByClient(int clientId) async {
    try {
      final result = await _repository.getCommandesByClient(clientId);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Commande>>> getCommandesByAgent(int agentId) async {
    try {
      final result = await _repository.getCommandesByAgent(agentId);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Commande>>> getCommandesByStatus(String status) async {
    try {
      final result = await _repository.getCommandesByStatus(status);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Commande>> getCommande(int id) async {
    try {
      final result = await _repository.getCommande(id);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Commande>> createCommande({
    required CreateCommandeRequest request,
  }) async {
    try {
      final result = await _repository.createCommande(request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Commande>> updateCommande({
    required int id,
    required UpdateCommandeRequest request,
  }) async {
    try {
      final result = await _repository.updateCommande(id, request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<Livraison>>> getLivraisons() async {
    try {
      final result = await _repository.getLivraisons();
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Livraison>> getLivraison(int id) async {
    try {
      final result = await _repository.getLivraisonById(id);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Livraison>> createLivraison({
    required CreateLivraisonRequest request,
  }) async {
    try {
      final result = await _repository.createLivraison(request: request);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Livraison>> updateDeliveryStatus({
    required int id,
    required String status,
  }) async {
    try {
      final result = await _repository.updateDeliveryStatus(id, status);
      return Right(result);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitProof({
    required int id,
    String? photoSignature,
    String? notes,
  }) async {
    try {
      await _repository.submitProof(id: id);
      return Right(unit);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }
}
