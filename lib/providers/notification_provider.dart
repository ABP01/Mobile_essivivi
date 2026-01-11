import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:essivi_mobile/services/websocket_service.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  NotificationProvider() {
    _loadNotificationsFromPrefs();
    _listenToWebSockets();
  }

  void _listenToWebSockets() {
    WebSocketService().notifications.listen((data) {
      addNotification(data);
    });
  }

  void addNotification(Map<String, dynamic> notification) {
    // Add to the beginning of the list
    final newNotification = {
      ...notification,
      'isRead': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _notifications.insert(0, newNotification);
    _saveNotificationsToPrefs();
    notifyListeners();
  }

  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index]['isRead'] = true;
      _saveNotificationsToPrefs();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    _saveNotificationsToPrefs();
    notifyListeners();
  }

  Future<void> _loadNotificationsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      _notifications = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveNotificationsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', jsonEncode(_notifications));
  }
}
