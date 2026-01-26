import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';

import '../services/appwrite_service.dart';

/// 🔐 Provider pour gérer l'authentification avec Appwrite
/// Gère l'état de connexion, OTP, sessions, etc.
class AppwriteAuthProvider extends ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();

  // État de l'authentification
  bool _isAuthenticated = false;
  bool _isLoading = false;
  models.User? _currentUser;
  String? _errorMessage;
  String? _pendingUserId; // Pour stocker l'ID lors de l'OTP

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  models.User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Initialise le provider et vérifie si l'utilisateur est connecté
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _appwriteService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _appwriteService.getCurrentUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
      debugPrint('Utilisateur non connecté: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ===================================================================
  // 📱 AUTHENTIFICATION PAR TÉLÉPHONE (OTP/SMS)
  // ===================================================================

  /// Étape 1: Envoyer un code OTP par SMS
  Future<bool> sendPhoneOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Format: +228XXXXXXXX (avec indicatif pays)
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+228$phoneNumber'; // Togo par défaut
      }

      final token = await _appwriteService.createPhoneSession(
        phone: phoneNumber,
      );
      _pendingUserId = token.userId;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur envoi OTP: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Étape 2: Vérifier le code OTP et se connecter
  Future<bool> verifyPhoneOTP(String otp) async {
    if (_pendingUserId == null) {
      _setError('Aucune session OTP en attente');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final session = await _appwriteService.verifyPhoneOTP(
        userId: _pendingUserId!,
        otp: otp,
      );

      // Récupérer les infos utilisateur
      _currentUser = await _appwriteService.getCurrentUser();
      _isAuthenticated = true;
      _pendingUserId = null;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Code OTP invalide: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ===================================================================
  // 📧 AUTHENTIFICATION PAR EMAIL
  // ===================================================================

  /// Créer un nouveau compte avec email/mot de passe
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Créer le compte
      await _appwriteService.createAccount(
        email: email,
        password: password,
        name: name,
      );

      // Se connecter automatiquement
      return await loginWithEmail(email: email, password: password);
    } catch (e) {
      _setError('Erreur création compte: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Se connecter avec email/mot de passe
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _appwriteService.loginWithEmail(email: email, password: password);

      _currentUser = await _appwriteService.getCurrentUser();
      _isAuthenticated = true;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur connexion: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Envoyer un email de vérification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      await _appwriteService.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur envoi email: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Vérifier l'email avec le token reçu
  Future<bool> verifyEmail({
    required String userId,
    required String secret,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _appwriteService.verifyEmail(userId: userId, secret: secret);
      // Rafraîchir les infos utilisateur
      _currentUser = await _appwriteService.getCurrentUser();
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur vérification: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ===================================================================
  // 🔑 RÉINITIALISATION MOT DE PASSE
  // ===================================================================

  /// Demander une réinitialisation de mot de passe
  Future<bool> requestPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _appwriteService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur reset password: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Confirmer la réinitialisation avec le token
  Future<bool> confirmPasswordReset({
    required String userId,
    required String secret,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _appwriteService.confirmPasswordReset(
        userId: userId,
        secret: secret,
        password: newPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur confirmation: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ===================================================================
  // 🔔 NOTIFICATIONS PUSH
  // ===================================================================

  /// Abonner l'utilisateur aux notifications push
  Future<bool> subscribeToPush(String fcmToken) async {
    try {
      await _appwriteService.subscribeToPushNotifications(fcmToken);
      return true;
    } catch (e) {
      debugPrint('Erreur abonnement push: $e');
      return false;
    }
  }

  /// Désabonner des notifications push
  Future<bool> unsubscribeFromPush() async {
    try {
      await _appwriteService.unsubscribeFromPushNotifications();
      return true;
    } catch (e) {
      debugPrint('Erreur désabonnement: $e');
      return false;
    }
  }

  // ===================================================================
  // 🚪 DÉCONNEXION
  // ===================================================================

  /// Se déconnecter de la session courante
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _appwriteService.logout();
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _pendingUserId = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Se déconnecter de toutes les sessions
  Future<void> logoutAllDevices() async {
    _setLoading(true);
    try {
      await _appwriteService.logoutAllSessions();
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _pendingUserId = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  // ===================================================================
  // 🔧 MÉTHODES UTILITAIRES
  // ===================================================================

  /// Obtenir le JWT pour l'authentification backend
  Future<String?> getJWT() async {
    try {
      final jwt = await _appwriteService.createJWT();
      return jwt.jwt;
    } catch (e) {
      debugPrint('Erreur JWT: $e');
      return null;
    }
  }

  /// Rafraîchir les données utilisateur
  Future<void> refreshUser() async {
    if (!_isAuthenticated) return;

    try {
      _currentUser = await _appwriteService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur refresh user: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtenir les informations de l'utilisateur
  String? get userId => _currentUser?.$id;
  String? get userName => _currentUser?.name;
  String? get userEmail => _currentUser?.email;
  String? get userPhone => _currentUser?.phone;
  bool get isEmailVerified => _currentUser?.emailVerification ?? false;
  bool get isPhoneVerified => _currentUser?.phoneVerification ?? false;
}
