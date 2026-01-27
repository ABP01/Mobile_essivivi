import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/presentation/screens/agent/agent_delivery_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake SalesRepository
class FakeSalesRepo {
  bool called = false;
  Future<Livraison> updateDeliveryStatus(
    int id,
    String status, {
    double? gpsLat,
    double? gpsLng,
  }) async {
    called = true;
    return Livraison(
      id: id,
      tourneeId: 1,
      commandeId: null,
      clientId: 1,
      statutLivraison: 'delivered',
      gpsLat: gpsLat,
      gpsLng: gpsLng,
      photoPreuve: null,
      signature: null,
      preuveValidee: false,
      timestamp: DateTime.now().toIso8601String(),
      clientPhone: null,
      agentPhone: null,
      agentAllocated: null,
    );
  }
}

// Fake Position-like object and LocationService
class FakePosition {
  final double latitude;
  final double longitude;
  FakePosition(this.latitude, this.longitude);
}

class FakeLocationService {
  Future<FakePosition?> getCurrentPosition() async {
    return FakePosition(6.1319, 1.2223);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Agent can mark delivery delivered and backend is called', (
    WidgetTester tester,
  ) async {
    final fakeRepo = FakeSalesRepo();
    final fakeLocation = FakeLocationService();

    final livraison = Livraison(
      id: 42,
      tourneeId: 1,
      commandeId: null,
      clientId: 2,
      statutLivraison: 'assigned',
      gpsLat: null,
      gpsLng: null,
      photoPreuve: null,
      signature: null,
      preuveValidee: false,
      timestamp: DateTime.now().toIso8601String(),
      clientPhone: '+22890000000',
      agentPhone: null,
      agentAllocated: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AgentDeliveryDetailsScreen(
          livraison: livraison,
          salesRepo: fakeRepo as dynamic,
          locationService: fakeLocation as dynamic,
        ),
      ),
    );

    // Verify button exists
    final buttonFinder = find.text('Marquer Livrée (sans preuve)');
    expect(buttonFinder, findsOneWidget);

    // Tap button
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Fake repo should have been called
    expect(fakeRepo.called, isTrue);

    // Expect a snackbar indicating success or status update
    final snackFinder = find.byType(SnackBar);
    expect(snackFinder, findsWidgets);
  });
}
