import 'package:dio/dio.dart';
import 'failures.dart';

/// Centralized error handler that converts exceptions to Failures
class ErrorHandler {
  /// Convert any exception to a typed Failure
  static Failure handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    } else if (error is Failure) {
      return error;
    } else {
      return UnknownFailure(
        error.toString(),
        stackTrace,
      );
    }
  }

  /// Handle Dio-specific errors
  static Failure _handleDioError(DioException error, [StackTrace? stackTrace]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
          'Connection timeout. Please check your internet connection.',
          stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error, stackTrace);

      case DioExceptionType.cancel:
        return UnknownFailure('Request was cancelled', stackTrace);

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'No internet connection. Please check your network.',
          stackTrace,
        );

      case DioExceptionType.badCertificate:
        return ServerFailure(
          'Certificate verification failed',
          stackTrace: stackTrace,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkFailure(
          'Network error: ${error.message ?? 'Unknown error'}',
          stackTrace,
        );
    }
  }

  /// Handle HTTP response errors (4xx, 5xx)
  static Failure _handleBadResponse(DioException error, [StackTrace? stackTrace]) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Try to extract error message from response
    String message = 'Server error occurred';
    Map<String, String>? fieldErrors;

    if (data is Map<String, dynamic>) {
      // Common error response patterns
      if (data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data.containsKey('error')) {
        message = data['error'].toString();
      }

      // Extract field-specific errors for validation
      if (data.containsKey('errors') && data['errors'] is Map) {
        fieldErrors = Map<String, String>.from(
          (data['errors'] as Map).map(
            (key, value) => MapEntry(
              key.toString(),
              value.toString(),
            ),
          ),
        );
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message.isEmpty ? 'Invalid request' : message,
          fieldErrors: fieldErrors,
          stackTrace: stackTrace,
        );

      case 401:
        // If we have a specific message from server (like "No active account found"), use it.
        // Otherwise use the generic session expired message.
        final displayMessage = (message.isNotEmpty && message != 'Server error occurred') 
            ? message 
            : 'Your session has expired. Please log in again.';
            
        return AuthFailure(
          displayMessage,
          stackTrace,
        );

      case 403:
        return AuthFailure(
          'You do not have permission to access this resource.',
          stackTrace,
        );

      case 404:
        return ServerFailure(
          'Resource not found',
          statusCode: statusCode,
          stackTrace: stackTrace,
        );

      case 422:
        return ValidationFailure(
          message.isEmpty ? 'Validation failed' : message,
          fieldErrors: fieldErrors,
          stackTrace: stackTrace,
        );

      case 500:
      case 502:
      case 503:
        return ServerFailure(
          'Server error. Please try again later.',
          statusCode: statusCode,
          stackTrace: stackTrace,
        );

      default:
        return ServerFailure(
          message,
          statusCode: statusCode,
          stackTrace: stackTrace,
        );
    }
  }
}
