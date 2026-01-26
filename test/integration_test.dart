import 'package:essivi_mobile/services/appwrite_service.dart';
import 'package:essivi_mobile/services/firebase_messaging_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Services Integration Test', () {
    late AppwriteService appwriteService;
    late FirebaseMessagingService messagingService;

    setUp(() {
      appwriteService = AppwriteService();
      messagingService = FirebaseMessagingService();
    });

    test('AppwriteService should initialize correctly', () {
      expect(appwriteService, isNotNull);
      expect(appwriteService.client, isNotNull);
      expect(appwriteService.account, isNotNull);
      expect(appwriteService.databases, isNotNull);
      expect(appwriteService.realtime, isNotNull);
    });

    test('FirebaseMessagingService should initialize correctly', () {
      expect(messagingService, isNotNull);
    });

    test('AppwriteService constants should be correct', () {
      expect(AppwriteService.endpoint, 'https://cloud.appwrite.io/v1');
      expect(AppwriteService.projectId, '697487ca003040b21700');
    });
  });
}