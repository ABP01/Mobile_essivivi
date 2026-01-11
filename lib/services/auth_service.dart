import 'package:essivi_mobile/services/websocket_service.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import '../data/models/user_models.dart';

enum UserRole { client, agent, admin, gestionnaire }

class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;


  final _authRepository = AuthRepository();

  AuthService._internal();

  /// Attempts to login with provided credentials
  /// Returns the UserRole if successful, throws exception on failure
  Future<UserRole?> login(String email, String password) async {
    try {
      // Call backend API
      final user = await _authRepository.login(email, password);
      
      // Initialize WebSocket connection
      WebSocketService().connect();
      
      // Convert role string to UserRole enum
      return _roleFromString(user.role);
    } catch (e) {
      // Return null on login failure
      return null;
    }
  }

  /// Signs up a new user
  Future<UserRole?> signup({
    required String username,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      final signupRequest = SignupRequest(
        username: username,
        email: email,
        password: password,
        role: role,
        phoneNumber: phoneNumber,
      );

      final user = await _authRepository.signup(signupRequest);
      
      // Initialize WebSocket connection
      WebSocketService().connect();
      
      return _roleFromString(user.role);
    } catch (e) {
      return null;
    }
  }

  /// Logs out the current user
  Future<void> logout() async {
    WebSocketService().disconnect();
    await _authRepository.logout();
  }

  /// Checks if a user is currently authenticated
  Future<bool> isAuthenticated() async {
    return await _authRepository.isAuthenticated();
  }

  /// Gets the current user's role
  Future<UserRole?> getCurrentUserRole() async {
    try {
      final roleString = await _authRepository.getUserRole();
      if (roleString == null) return null;
      return _roleFromString(roleString);
    } catch (e) {
      return null;
    }
  }

  /// Gets the current user's email
  Future<String?> getCurrentUserEmail() async {
    return await _authRepository.getUserEmail();
  }

  /// Gets the current user's full profile from the backend
  Future<CustomUser?> getCurrentUser() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// Helper method to convert role string to UserRole enum
  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'client':
        return UserRole.client;
      case 'agent':
        return UserRole.agent;
      case 'admin':
        return UserRole.admin;
      case 'gestionnaire':
        return UserRole.gestionnaire;
      default:
        return UserRole.client;
    }
  }

  /// Helper method to convert UserRole enum to string
  String roleToString(UserRole role) {
    return role.name;
  }
}

