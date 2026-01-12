import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/repositories/logistics_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_sales_repository.dart';
import '../../domain/repositories/i_logistics_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/deliveries/load_agent_deliveries_usecase.dart';
import '../../domain/usecases/deliveries/accept_order_usecase.dart';
import '../../domain/usecases/profile/load_client_profile_usecase.dart';

/// ========== DATA SOURCES ==========

/// TODO: We will create proper repository implementations later
/// For now, we keep existing repositories as implementations


/// ========== REPOSITORIES ==========

/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository();
});

/// Sales Repository Provider
final salesRepositoryProvider = Provider<ISalesRepository>((ref) {
  return SalesRepositoryImpl();
});

/// Logistics Repository Provider
final logisticsRepositoryProvider = Provider<ILogisticsRepository>((ref) {
  return LogisticsRepositoryImpl();
});

/// User Repository Provider
final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return UserRepositoryImpl();
});


/// ========== USE CASES ==========

/// Login Use Case Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

/// Logout Use Case Provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

/// Get Current User Use Case Provider
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

/// Load Agent Deliveries Use Case Provider
final loadAgentDeliveriesUseCaseProvider = Provider<LoadAgentDeliveriesUseCase>((ref) {
  return LoadAgentDeliveriesUseCase(
    salesRepository: ref.watch(salesRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// Accept Order Use Case Provider
final acceptOrderUseCaseProvider = Provider<AcceptOrderUseCase>((ref) {
  return AcceptOrderUseCase(
    salesRepository: ref.watch(salesRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

/// Load Client Profile Use Case Provider
final loadClientProfileUseCaseProvider = Provider<LoadClientProfileUseCase>((ref) {
  return LoadClientProfileUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    salesRepository: ref.watch(salesRepositoryProvider),
  );
});
