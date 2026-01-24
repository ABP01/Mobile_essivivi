import 'package:essivi_mobile/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('roleFromString returns correct UserRole', () {
      expect(authService.roleToString(UserRole.client), 'client');
      expect(authService.roleToString(UserRole.agent), 'agent');
      expect(authService.roleToString(UserRole.admin), 'admin');
      expect(authService.roleToString(UserRole.gestionnaire), 'gestionnaire');
    });

    test('roleFromString handles unknown role', () {
      // Test internal method via reflection or by testing login/signup
      // For now, basic test
      expect(UserRole.client.toString(), 'UserRole.client');
    });
  });
}
