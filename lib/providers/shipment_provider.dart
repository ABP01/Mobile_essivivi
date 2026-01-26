import 'package:flutter/foundation.dart';
import '../data/models/sales_models.dart';
import '../data/repositories/sales_repository.dart';

class ShipmentProvider with ChangeNotifier {
  final SalesRepository _salesRepository = SalesRepository();
  
  List<Commande> _shipments = [];
  bool _isLoading = false;
  String? _error;

  List<Commande> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadShipments({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (status != null && status != 'All') {
        _shipments = await _salesRepository.getCommandesByStatus(status.toLowerCase());
      } else {
        _shipments = await _salesRepository.getCommandes();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Commande? get currentShipment {
     // Logic to find current active shipment
     try {
       // Assuming 'validated' or 'en_route' is active. 
       // Backend status: pending, validated, delivered, cancelled.
       // We might need to check connected Livraison for 'en_route'.
       return _shipments.firstWhere((s) => s.statut == 'validated' || s.statut == 'pending'); 
     } catch (e) {
       return null;
     }
  }
}
