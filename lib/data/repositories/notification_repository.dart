
import '../datasources/api_service.dart';
import '../models/notification_models.dart';
import '../../utils/api_config.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les notifications de l'utilisateur
  Future<List<Notification>> getNotifications() async {
    try {
      final response = await _apiService.client.get(ApiConfig.notificationsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => Notification.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Marquer une notification comme lue
  Future<Notification> markAsRead(int id) async {
    try {
      final endpoint = ApiConfig.markNotificationReadEndpoint.replaceAll('{id}', id.toString());
      final response = await _apiService.client.post(endpoint);
      return Notification.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _apiService.client.post(ApiConfig.markAllNotificationsReadEndpoint);
    } catch (e) {
      rethrow;
    }
  }
}
