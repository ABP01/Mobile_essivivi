/// Base class for all failures in the application
/// Follows the Clean Architecture principle of domain-driven design
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed', StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Server-related failures (4xx, 5xx errors)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed', StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed', StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Validation failures (e.g., form validation)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(
    String message, {
    this.fieldErrors,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

/// General/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred', StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Permission failures (e.g., location, camera permissions)
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied', StackTrace? stackTrace])
      : super(message, stackTrace);
}
