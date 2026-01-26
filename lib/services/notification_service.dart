import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../data/models/notification_models.dart' as model;
import '../data/repositories/notification_repository.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  final WebSocketService _wsService = WebSocketService();
  
  List<model.Notification> _notifications = [];
  List<model.Notification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  NotificationService() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _wsService.connect();
    _wsService.notifications.listen((data) {
      if (data['type'] == 'notification') {
        final notif = model.Notification.fromJson(data['notification']);
        _notifications.insert(0, notif);
        notifyListeners();
      }
    });
  }

  Future<void> fetchNotifications() async {
    try {
      final list = await _repository.getNotifications();
      _notifications = list;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
         // Create a new updated item since fields are final
         final old = _notifications[index];
         _notifications[index] = model.Notification(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            read: true,
            createdAt: old.createdAt,
         );
         notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }
}
