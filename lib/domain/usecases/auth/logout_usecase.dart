import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

/// Logout Use Case
/// Handles user logout business logic
class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.logout();
  }
}
