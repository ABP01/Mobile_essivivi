import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les notifications de l'utilisateur
  Future<List<Notification>> getNotifications() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.notificationsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Notification.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        // Retry on transient 502 Bad Gateway
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        // For 502 after retries, return empty list as a safe fallback
        if (status == 502) return <Notification>[];

        rethrow;
      }
    }
  }

  /// Marquer une notification comme lue
  Future<Notification> markAsRead(int id) async {
    try {
      final endpoint = ApiConfig.markNotificationReadEndpoint.replaceAll(
        '{id}',
        id.toString(),
      );
      final response = await _apiService.client.post(endpoint);
      return Notification.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _apiService.client.post(ApiConfig.markAllNotificationsReadEndpoint);
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
