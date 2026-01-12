import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sales_models.dart';
import '../../core/errors/failures.dart';
import '../../core/di/providers.dart';
import '../../domain/usecases/deliveries/load_agent_deliveries_usecase.dart';
import '../../domain/usecases/deliveries/accept_order_usecase.dart';

/// Simple Deliveries State (without Freezed for now)
class DeliveriesState {
  final bool isLoading;
  final List<Livraison> myDeliveries;
  final List<Commande> availableOrders;
  final Failure? error;

  const DeliveriesState({
    this.isLoading = false,
    this.myDeliveries = const [],
    this.availableOrders = const [],
    this.error,
  });

  DeliveriesState copyWith({
    bool? isLoading,
    List<Livraison>? myDeliveries,
    List<Commande>? availableOrders,
    Failure? error,
  }) {
    return DeliveriesState(
      isLoading: isLoading ?? this.isLoading,
      myDeliveries: myDeliveries ?? this.myDeliveries,
      availableOrders: availableOrders ?? this.availableOrders,
      error: error,
    );
  }
}

/// Deliveries State Notifier
class DeliveriesNotifier extends StateNotifier<DeliveriesState> {
  final LoadAgentDeliveriesUseCase loadAgentDeliveriesUseCase;
  final AcceptOrderUseCase acceptOrderUseCase;

  DeliveriesNotifier({
    required this.loadAgentDeliveriesUseCase,
    required this.acceptOrderUseCase,
  }) : super(const DeliveriesState());

  /// Load agent deliveries
  Future<void> loadDeliveries() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await loadAgentDeliveriesUseCase.call();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (data) => state = state.copyWith(
        isLoading: false,
        myDeliveries: data.myDeliveries,
        availableOrders: data.availableOrders,
        error: null,
      ),
    );
  }

  /// Accept an order
  Future<bool> acceptOrder(int orderId, int tourneeId) async {
    final result = await acceptOrderUseCase.call(
      AcceptOrderParams(orderId: orderId, tourneeId: tourneeId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure);
        return false;
      },
      (_) {
        // Reload deliveries after accepting
        loadDeliveries();
        return true;
      },
    );
  }

  /// Get filtered deliveries
  List<Livraison> getFilteredDeliveries(String filter) {
    if (filter == 'all') return state.myDeliveries;
    if (filter == 'delivered') {
      return state.myDeliveries.where((d) => d.isDelivered).toList();
    }
    if (filter == 'pending') {
      return state.myDeliveries.where((d) => !d.isDelivered).toList();
    }
    return state.myDeliveries;
  }
}

/// Deliveries State Provider
final deliveriesProvider =
    StateNotifierProvider<DeliveriesNotifier, DeliveriesState>((ref) {
  return DeliveriesNotifier(
    loadAgentDeliveriesUseCase: ref.watch(loadAgentDeliveriesUseCaseProvider),
    acceptOrderUseCase: ref.watch(acceptOrderUseCaseProvider),
  );
});
