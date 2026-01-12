import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/sales_models.dart';
import '../../repositories/i_sales_repository.dart';
import '../../repositories/i_auth_repository.dart';

/// Load Agent Deliveries Use Case
/// Business logic for loading deliveries assigned to an agent
class LoadAgentDeliveriesUseCase {
  final ISalesRepository salesRepository;
  final IAuthRepository authRepository;

  LoadAgentDeliveriesUseCase({
    required this.salesRepository,
    required this.authRepository,
  });

  Future<Either<Failure, LoadAgentDeliveriesResult>> call() async {
    try {
      // Get current user
      final userResult = await authRepository.getCurrentUser();
      
      return await userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Load all deliveries
          final deliveriesResult = await salesRepository.getLivraisons();
          
          return await deliveriesResult.fold(
            (failure) => Left(failure),
            (allDeliveries) async {
              // Load agent's orders
              final ordersResult = await salesRepository.getCommandesByAgent(user.id);
              
              return await ordersResult.fold(
                (failure) => Left(failure),
                (agentOrders) async {
                  // Filter deliveries that belong to this agent
                  final agentOrderIds = agentOrders.map((o) => o.id).toSet();
                  final myDeliveries = allDeliveries
                      .where((d) => d.commandeId != null && agentOrderIds.contains(d.commandeId))
                      .toList();
                  
                  // Load available orders (not yet assigned)
                  final pendingOrdersResult = await salesRepository.getCommandesByStatus('pending');
                  
                  return await pendingOrdersResult.fold(
                    (failure) => Left(failure),
                    (pendingOrders) {
                      final availableOrders = pendingOrders
                          .where((o) => o.agentId == null)
                          .toList();
                      
                      return Right(LoadAgentDeliveriesResult(
                        myDeliveries: myDeliveries,
                        availableOrders: availableOrders,
                      ));
                    },
                  );
                },
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

class LoadAgentDeliveriesResult extends Equatable {
  final List<Livraison> myDeliveries;
  final List<Commande> availableOrders;

  const LoadAgentDeliveriesResult({
    required this.myDeliveries,
    required this.availableOrders,
  });

  @override
  List<Object> get props => [myDeliveries, availableOrders];
}
