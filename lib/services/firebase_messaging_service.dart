import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'appwrite_service.dart';

/// 🔔 Service de gestion des notifications push Firebase Cloud Messaging
/// Gère les notifications en arrière-plan et au premier plan
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AppwriteService _appwriteService = AppwriteService();

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageReceived => _messageController.stream;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialise Firebase Messaging et les notifications locales
  Future<void> initialize() async {
    try {
      // Demander la permission pour les notifications
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permission notifications accordée');

        // Initialiser les notifications locales
        await _initializeLocalNotifications();

        // Récupérer le token FCM
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('🔑 FCM Token: $_fcmToken');

        // Sauvegarder le token dans Appwrite
        if (_fcmToken != null) {
          await _saveFCMTokenToAppwrite(_fcmToken!);
        }

        // Configurer les handlers de messages
        _setupMessageHandlers();

        // Écouter les changements de token
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveFCMTokenToAppwrite(newToken);
          debugPrint('🔄 FCM Token rafraîchi: $newToken');
        });
      } else {
        debugPrint('⚠️ Permission notifications refusée');
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation FCM: $e');
    }
  }

  /// Demande la permission pour les notifications
  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Initialise les notifications locales (pour afficher en premier plan)
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal de notification Android
    const androidChannel = AndroidNotificationChannel(
      'essivi_high_importance', // id
      'Notifications Essivi', // name
      description: 'Canal pour les notifications importantes',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Configure les handlers de messages
  void _setupMessageHandlers() {
    // Message reçu en premier plan (app ouverte)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📩 Message reçu en premier plan: ${message.notification?.title}',
      );
      _showLocalNotification(message);
      _messageController.add(message);
    });

    // Message cliqué (app en arrière-plan ou fermée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 Notification cliquée: ${message.notification?.title}');
      _handleNotificationTap(message);
      _messageController.add(message);
    });

    // Vérifier si l'app a été ouverte via une notification
    _checkInitialMessage();
  }

  /// Vérifie si l'app a été ouverte via une notification
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '🚀 App ouverte via notification: ${initialMessage.notification?.title}',
      );
      _handleNotificationTap(initialMessage);
    }
  }

  /// Affiche une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'essivi_high_importance',
            'Notifications Essivi',
            channelDescription: 'Canal pour les notifications importantes',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Gère le clic sur une notification locale
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification locale cliquée: ${response.payload}');
    // Naviguer vers la page appropriée selon le payload
    // TODO: Implémenter la navigation
  }

  /// Gère le clic sur une notification push
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📲 Gestion du clic: ${message.data}');

    // Extraire les données de la notification
    final data = message.data;
    final type = data['type'] ?? '';

    // Naviguer selon le type de notification
    switch (type) {
      case 'order':
        final orderId = data['order_id'];
        debugPrint('➡️ Navigation vers commande: $orderId');
        // TODO: Naviguer vers la page de commande
        break;

      case 'delivery':
        final deliveryId = data['delivery_id'];
        debugPrint('➡️ Navigation vers livraison: $deliveryId');
        // TODO: Naviguer vers la page de livraison
        break;

      case 'message':
        final chatId = data['chat_id'];
        debugPrint('➡️ Navigation vers chat: $chatId');
        // TODO: Naviguer vers le chat
        break;

      default:
        debugPrint('➡️ Navigation vers notifications');
      // TODO: Naviguer vers la liste des notifications
    }
  }

  /// Sauvegarde le token FCM dans Appwrite
  Future<void> _saveFCMTokenToAppwrite(String token) async {
    // Vérifier si l'utilisateur est connecté
    if (!(await _appwriteService.isLoggedIn())) {
      debugPrint('Utilisateur non connecté, sauvegarde du token FCM ignorée');
      return;
    }

    try {
      await _appwriteService.subscribeToPushNotifications(token);
      debugPrint('✅ Token FCM sauvegardé dans Appwrite');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde token: $e');
    }
  }

  /// Sauvegarde le token FCM si disponible et utilisateur connecté
  Future<void> saveFCMToken() async {
    if (_fcmToken != null) {
      await _saveFCMTokenToAppwrite(_fcmToken!);
    }
  }

  /// S'abonner à un topic (ex: pour les agents, clients, etc.)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ Abonné au topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur abonnement topic: $e');
    }
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Désabonné du topic: $topic');
    } catch (e) {
      debugPrint('❌ Erreur désabonnement topic: $e');
    }
  }

  /// Obtenir le badge count (iOS)
  Future<int> getBadgeCount() async {
    // iOS uniquement
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Implémenter la logique de récupération du badge
      return 0;
    }
    return 0;
  }

  /// Réinitialiser le badge count (iOS)
  Future<void> resetBadgeCount() async {
    // Note: setApplicationIconBadgeNumber is deprecated and removed in FCM v1
    // The badge count is now handled automatically by iOS
    // This method is kept for compatibility but does nothing
  }

  /// Se désabonner des notifications push
  Future<void> unsubscribe() async {
    try {
      await _appwriteService.unsubscribeFromPushNotifications();
      debugPrint('✅ Désabonné des notifications push');
    } catch (e) {
      debugPrint('❌ Erreur désabonnement: $e');
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    _messageController.close();
  }
}

/// 🚀 Handler pour les messages en arrière-plan
/// DOIT être une fonction top-level (pas dans une classe)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Message reçu en arrière-plan: ${message.notification?.title}');
  // Traiter le message en arrière-plan si nécessaire
}
