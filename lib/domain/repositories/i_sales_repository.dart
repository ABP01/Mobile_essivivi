import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../data/models/sales_models.dart';

/// Sales Repository Interface
/// Defines the contract for sales-related operations
abstract class ISalesRepository {
  /// Get all commandes
  Future<Either<Failure, List<Commande>>> getCommandes();

  /// Get commandes by client ID
  Future<Either<Failure, List<Commande>>> getCommandesByClient(int clientId);

  /// Get commandes by agent ID
  Future<Either<Failure, List<Commande>>> getCommandesByAgent(int agentId);

  /// Get commandes by status
  Future<Either<Failure, List<Commande>>> getCommandesByStatus(String status);

  /// Get single commande by ID
  Future<Either<Failure, Commande>> getCommande(int id);

  /// Create new commande
  Future<Either<Failure, Commande>> createCommande({
    required CreateCommandeRequest request,
  });

  /// Update commande
  Future<Either<Failure, Commande>> updateCommande({
    required int id,
    required UpdateCommandeRequest request,
  });

  /// Get all livraisons
  Future<Either<Failure, List<Livraison>>> getLivraisons();

  /// Get livraison by ID
  Future<Either<Failure, Livraison>> getLivraison(int id);

  /// Create new livraison
  Future<Either<Failure, Livraison>> createLivraison({
    required CreateLivraisonRequest request,
  });

  /// Update delivery status
  Future<Either<Failure, Livraison>> updateDeliveryStatus({
    required int id,
    required String status,
  });

  /// Submit delivery proof
  Future<Either<Failure, Unit>> submitProof({
    required int id,
    String? photoSignature,
    String? notes,
  });
}
