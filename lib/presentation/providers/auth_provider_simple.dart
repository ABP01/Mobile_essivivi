import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_models.dart';
import '../../core/errors/failures.dart';
import '../../core/di/providers.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';

/// Simple Auth State (without Freezed)
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final CustomUser? user;
  final Failure? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    CustomUser? user,
    Failure? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Authentication State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState());

  /// Check authentication status on init
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final result = await getCurrentUserUseCase.call();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: failure,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  /// Login
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await loginUseCase.call(
      LoginParams(username: username, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      ),
    );
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await logoutUseCase.call();

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (_) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      ),
    );
  }
}

/// Auth State Provider
final authProviderSimple = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});
