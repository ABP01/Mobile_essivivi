import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../data/models/user_models.dart';
import '../../repositories/i_auth_repository.dart';

/// Login Use Case
/// Handles user authentication business logic
class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, CustomUser>> call(LoginParams params) async {
    // Business logic can be added here (e.g., input validation)
    if (params.username.isEmpty || params.password.isEmpty) {
      return Left(ValidationFailure('Username and password cannot be empty'));
    }

    return await repository.login(
      username: params.username,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}
