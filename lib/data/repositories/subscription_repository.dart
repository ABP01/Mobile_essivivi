import 'package:dio/dio.dart';
import '../datasources/api_service.dart';
import '../models/subscription_models.dart';
import '../../utils/api_config.dart';

class SubscriptionRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer l'abonnement actuel de l'utilisateur
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final response = await _apiService.client.get('${ApiConfig.baseUrl}/sales/subscriptions/');
      final List<dynamic> data = response.data;
      if (data.isEmpty) return null;
      return Subscription.fromJson(data.first);
    } catch (e) {
      rethrow;
    }
  }

  /// Créer un nouvel abonnement
  Future<Subscription> createSubscription(Subscription subscription) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.baseUrl}/sales/subscriptions/',
        data: subscription.toJson(),
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour un abonnement
  Future<Subscription> updateSubscription(int id, Subscription subscription) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.baseUrl}/sales/subscriptions/$id/',
        data: subscription.toJson(),
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre en pause un abonnement
  Future<Subscription> pauseSubscription(int id) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.baseUrl}/sales/subscriptions/$id/pause/',
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Reprendre un abonnement
  Future<Subscription> resumeSubscription(int id) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.baseUrl}/sales/subscriptions/$id/resume/',
      );
      return Subscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
