import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_models.dart';
import '../../repositories/i_auth_repository.dart';

/// Get Current User Use Case
/// Retrieves the currently authenticated user's information
class GetCurrentUserUseCase {
  final IAuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, CustomUser>> call() async {
    final isAuth = await repository.isAuthenticated();
    
    if (!isAuth) {
      return Left(AuthFailure('No authenticated user'));
    }

    return await repository.getCurrentUser();
  }
}
