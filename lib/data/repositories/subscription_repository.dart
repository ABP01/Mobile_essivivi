import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/subscription_models.dart';

class SubscriptionRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer l'abonnement actuel de l'utilisateur
  Future<Subscription?> getCurrentSubscription() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.subscriptionsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        if (data.isEmpty) return null;
        return Subscription.fromJson(data.first);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return null;

        rethrow;
      }
    }
  }

  /// Créer un nouvel abonnement
  Future<Subscription> createSubscription(Subscription subscription) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.subscriptionsEndpoint,
        data: subscription.toJson(),
      );
      return Subscription.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Mettre à jour un abonnement
  Future<Subscription> updateSubscription(
    int id,
    Subscription subscription,
  ) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.subscriptionsEndpoint}$id/',
        data: subscription.toJson(),
      );
      return Subscription.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Mettre en pause un abonnement
  Future<Subscription> pauseSubscription(int id) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.subscriptionsEndpoint}$id/pause/',
      );
      return Subscription.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Reprendre un abonnement
  Future<Subscription> resumeSubscription(int id) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.subscriptionsEndpoint}$id/resume/',
      );
      return Subscription.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }
}
