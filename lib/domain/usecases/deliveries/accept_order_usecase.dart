import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/sales_models.dart';
import '../../repositories/i_sales_repository.dart';
import '../../repositories/i_auth_repository.dart';

/// Accept Order Use Case
/// Business logic for agent accepting an available order
class AcceptOrderUseCase {
  final ISalesRepository salesRepository;
  final IAuthRepository authRepository;

  AcceptOrderUseCase({
    required this.salesRepository,
    required this.authRepository,
  });

  Future<Either<Failure, Unit>> call(AcceptOrderParams params) async {
    try {
      // Get current user
      final userResult = await authRepository.getCurrentUser();
      
      return await userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Update Commande with agent ID
          final updateResult = await salesRepository.updateCommande(
            id: params.orderId,
            request: UpdateCommandeRequest(
              agentId: user.id,
              statut: 'validated',
            ),
          );
          
          return await updateResult.fold(
            (failure) => Left(failure),
            (updatedOrder) async {
              // Create Livraison
              final livraisonResult = await salesRepository.createLivraison(
                request: CreateLivraisonRequest(
                  tourneeId: params.tourneeId,
                  clientId: updatedOrder.clientId,
                  commandeId: updatedOrder.id,
                ),
              );
              
              return livraisonResult.fold(
                (failure) => Left(failure),
                (_) => Right(unit),
              );
            },
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(UnknownFailure(e.toString(), stackTrace));
    }
  }
}

class AcceptOrderParams extends Equatable {
  final int orderId;
  final int tourneeId;

  const AcceptOrderParams({
    required this.orderId,
    required this.tourneeId,
  });

  @override
  List<Object> get props => [orderId, tourneeId];
}
