import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_models.dart';
import '../../../data/models/sales_models.dart';
import '../../repositories/i_auth_repository.dart';
import '../../repositories/i_user_repository.dart';
import '../../repositories/i_sales_repository.dart';

/// Load Client Profile Use Case
/// Business logic for loading client profile with statistics
class LoadClientProfileUseCase {
  final IAuthRepository authRepository;
  final IUserRepository userRepository;
  final ISalesRepository salesRepository;

  LoadClientProfileUseCase({
    required this.authRepository,
    required this.userRepository,
    required this.salesRepository,
  });

  Future<Either<Failure, LoadClientProfileResult>> call() async {
    try {
      // Get current user
      final userResult = await authRepository.getCurrentUser();
      
      return await userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Load client profile
          final clientResult = await userRepository.getClientByUserId(user.id);
          
          return await clientResult.fold(
            (failure) => Left(failure),
            (clientProfile) async {
              // Load orders for statistics
              final ordersResult = await salesRepository.getCommandesByClient(user.id);
              
              return await ordersResult.fold(
                (failure) => Left(failure),
                (orders) {
                  // Calculate statistics
                  final stats = _calculateStats(orders);
                  
                  return Right(LoadClientProfileResult(
                    user: user,
                    clientProfile: clientProfile,
                    totalDeliveries: orders.length,
                    activeOrders: stats.activeOrders,
                    completedOrders: stats.completedOrders,
                  ));
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

  _ProfileStats _calculateStats(List<Commande> orders) {
    int activeOrders = 0;
    int completedOrders = 0;

    for (var order in orders) {
      if (order.isDelivered) {
        completedOrders++;
      } else if (order.statut != 'annulee') {
        activeOrders++;
      }
    }

    return _ProfileStats(
      activeOrders: activeOrders,
      completedOrders: completedOrders,
    );
  }
}

class _ProfileStats {
  final int activeOrders;
  final int completedOrders;

  _ProfileStats({
    required this.activeOrders,
    required this.completedOrders,
  });
}

class LoadClientProfileResult extends Equatable {
  final CustomUser user;
  final ClientProfile clientProfile;
  final int totalDeliveries;
  final int activeOrders;
  final int completedOrders;

  const LoadClientProfileResult({
    required this.user,
    required this.clientProfile,
    required this.totalDeliveries,
    required this.activeOrders,
    required this.completedOrders,
  });

  @override
  List<Object> get props => [
        user,
        clientProfile,
        totalDeliveries,
        activeOrders,
        completedOrders,
      ];
}
