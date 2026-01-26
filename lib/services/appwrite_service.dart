import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppwriteService {
  // 🔥 PRODUCTION CREDENTIALS - Appwrite Cloud
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '697487ca003040b21700';

  late final Client client;
  late final Account account;
  late final Databases databases;
  late final Realtime realtime;
  late final Messaging messaging;

  final _storage = const FlutterSecureStorage();

  AppwriteService() {
    client = Client().setEndpoint(endpoint).setProject(projectId);

    account = Account(client);
    databases = Databases(client);
    realtime = Realtime(client);
    messaging = Messaging(client);
  }

  // ===================================================================
  // 🔐 AUTHENTICATION METHODS
  // ===================================================================

  /// Create a phone session (send SMS OTP)
  /// Returns a Token with userId and secret to verify
  Future<models.Token> createPhoneSession({required String phone}) async {
    try {
      // Generate a unique user ID (or use existing)
      final userId = 'unique()'; // Appwrite auto-generates

      return await account.createPhoneToken(
        userId: userId,
        phone: phone, // Format: +22890123456 (include country code)
      );
    } catch (e) {
      throw Exception('Erreur envoi OTP: ${e.toString()}');
    }
  }

  /// Verify phone OTP and create session
  Future<models.Session> verifyPhoneOTP({
    required String userId,
    required String otp,
  }) async {
    try {
      final session = await account.updatePhoneSession(
        userId: userId,
        secret: otp,
      );

      // Save session info
      await _saveSession(session);

      return session;
    } catch (e) {
      throw Exception('Code OTP invalide: ${e.toString()}');
    }
  }

  /// Create email session with password
  Future<models.Session> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      await _saveSession(session);
      return session;
    } catch (e) {
      throw Exception('Erreur connexion: ${e.toString()}');
    }
  }

  /// Create new user account with email/password
  Future<models.User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await account.create(
        userId: 'unique()',
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      throw Exception('Erreur création compte: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<models.Token> sendEmailVerification() async {
    try {
      return await account.createVerification(
        url: 'https://app.essivivi.com/verify-email', // Your app deep link
      );
    } catch (e) {
      throw Exception('Erreur envoi email: ${e.toString()}');
    }
  }

  /// Verify email with secret token
  Future<models.Token> verifyEmail({
    required String userId,
    required String secret,
  }) async {
    try {
      return await account.updateVerification(userId: userId, secret: secret);
    } catch (e) {
      throw Exception('Erreur vérification: ${e.toString()}');
    }
  }

  /// Request password recovery
  Future<models.Token> resetPassword(String email) async {
    try {
      return await account.createRecovery(
        email: email,
        url: 'https://app.essivivi.com/reset-password',
      );
    } catch (e) {
      throw Exception('Erreur reset password: ${e.toString()}');
    }
  }

  /// Confirm password recovery with secret
  Future<models.Token> confirmPasswordReset({
    required String userId,
    required String secret,
    required String password,
  }) async {
    try {
      return await account.updateRecovery(
        userId: userId,
        secret: secret,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur confirmation: ${e.toString()}');
    }
  }

  /// Get the current authenticated user
  Future<models.User> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      throw Exception('Utilisateur non connecté: ${e.toString()}');
    }
  }

  /// Create a JWT for backend authentication
  Future<models.Jwt> createJWT() async {
    try {
      return await account.createJWT();
    } catch (e) {
      throw Exception('Erreur JWT: ${e.toString()}');
    }
  }

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logout current session
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      await _clearSession();
    } catch (e) {
      // Ignore if already logged out
      await _clearSession();
    }
  }

  /// Logout from all devices
  Future<void> logoutAllSessions() async {
    try {
      await account.deleteSessions();
      await _clearSession();
    } catch (e) {
      await _clearSession();
    }
  }

  // ===================================================================
  // 🔔 PUSH NOTIFICATIONS METHODS
  // ===================================================================

  /// Subscribe to push notifications
  /// Save FCM token to Appwrite user preferences
  Future<void> subscribeToPushNotifications(String fcmToken) async {
    try {
      // Update user preferences with FCM token
      await account.updatePrefs(
        prefs: {
          'fcm_token': fcmToken,
          'push_enabled': true,
          'notification_settings': {
            'orders': true,
            'promotions': true,
            'updates': true,
          },
        },
      );
    } catch (e) {
      throw Exception('Erreur abonnement push: ${e.toString()}');
    }
  }

  /// Unsubscribe from push notifications
  Future<void> unsubscribeFromPushNotifications() async {
    try {
      final prefs = await account.getPrefs();
      prefs.data['push_enabled'] = false;
      await account.updatePrefs(prefs: prefs.data);
    } catch (e) {
      throw Exception('Erreur désabonnement: ${e.toString()}');
    }
  }

  /// Get user notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final prefs = await account.getPrefs();
      return prefs.data['notification_settings'] ?? {};
    } catch (e) {
      return {};
    }
  }

  // ===================================================================
  // 📨 REALTIME NOTIFICATIONS
  // ===================================================================

  /// Subscribe to realtime notifications
  Stream<RealtimeMessage> subscribeToUserNotifications(String userId) {
    final subscription = realtime.subscribe([
      'databases.essivi_main.collections.notifications.documents',
      'account.$userId',
    ]);
    return subscription.stream;
  }

  /// Subscribe to order updates
  Stream<RealtimeMessage> subscribeToOrderUpdates(String orderId) {
    final subscription = realtime.subscribe([
      'databases.essivi_main.collections.orders.documents.$orderId',
    ]);
    return subscription.stream;
  }

  // ===================================================================
  // 💾 DATABASE METHODS (Optional - for custom data)
  // ===================================================================

  /// Create a document in a collection
  Future<models.Document> createDocument({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: 'unique()',
        data: data,
      );
    } catch (e) {
      throw Exception('Erreur création document: ${e.toString()}');
    }
  }

  /// Get a document by ID
  Future<models.Document> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    try {
      return await databases.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Document non trouvé: ${e.toString()}');
    }
  }

  /// List documents with filters
  Future<models.DocumentList> listDocuments({
    required String databaseId,
    required String collectionId,
    List<String>? queries,
  }) async {
    try {
      return await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );
    } catch (e) {
      throw Exception('Erreur liste documents: ${e.toString()}');
    }
  }

  // ===================================================================
  // 🔧 PRIVATE HELPER METHODS
  // ===================================================================

  Future<void> _saveSession(models.Session session) async {
    await _storage.write(key: 'appwrite_session_id', value: session.$id);
    await _storage.write(key: 'appwrite_user_id', value: session.userId);
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: 'appwrite_session_id');
    await _storage.delete(key: 'appwrite_user_id');
    await _storage.delete(key: 'fcm_token');
  }

  Future<String?> getSavedUserId() async {
    return await _storage.read(key: 'appwrite_user_id');
  }
}
