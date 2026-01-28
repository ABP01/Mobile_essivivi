import 'package:flutter/foundation.dart';

import '../data/models/logistics_models.dart';
import '../data/models/sales_models.dart';
import '../data/models/user_models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/logistics_repository.dart';
import '../data/repositories/sales_repository.dart';
import '../data/repositories/user_repository.dart';
import '../services/location_service.dart';

class AgentProvider with ChangeNotifier {
  final LogisticsRepository _logisticsRepo = LogisticsRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();
  final LocationService _locationService = LocationService();

  // State
  bool _isLoading = false;
  String? _error;
  bool _isAvailable = false; 
  CustomUser? _currentUser;
  AgentProfile? _agentProfile;
  
  Tournee? _activeTournee;
  List<Livraison> _activeDeliveries = [];
  List<Livraison> _completedDeliveries = [];
  
  // Computed Stats
  int get completedTodayCount => _completedDeliveries.where((d) {
    if (d.createdAt.isEmpty) return false;
    final date = DateTime.tryParse(d.createdAt);
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }).length;

  static const double _commissionPerDelivery = 500.0;

  double get earnedToday => completedTodayCount * _commissionPerDelivery;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAvailable => _isAvailable;
  CustomUser? get currentUser => _currentUser;
  AgentProfile? get agentProfile => _agentProfile;
  Tournee? get activeTournee => _activeTournee;
  List<Livraison> get activeDeliveries => _activeDeliveries;
  List<Livraison> get completedDeliveries => _completedDeliveries;

  // Init
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authRepo.getCurrentUser();
      if (_currentUser != null) {
        // Load Profile
        try {
          final agents = await _userRepo.getAgents();
          // Filter safety check
          _agentProfile = agents.firstWhere((a) => a.userId == _currentUser!.id, orElse: () => throw Exception('Agent profile not found'));
          
          // Initial availability state from profile (mocked logic as availability might be local or server side)
           _isAvailable = _locationService.isTracking;
           
           // AUTO-ACTIVATE: Mettre l'agent en ligne automatiquement
           if (!_isAvailable) {
             toggleAvailability(true);
           }
        } catch (e) {
          debugPrint('Agent profile warning: $e');
          _error = 'Erreur lors du chargement du profil agent: $e';
        }

        // Load Active Tournee
        try {
          final tournees = await _logisticsRepo.getActiveTournees(); // This should be filtered by agent ideally
          // Client side filtering for safety
          if (tournees.isNotEmpty) {
               // Assuming the backend returns tournees relevant to the user or we filter here
               _activeTournee = tournees.first;
          }
        } catch (e) {
          debugPrint('Tournee loading error: $e');
          _error = 'Erreur lors du chargement des tournées: $e';
        }

        // Load Deliveries
        try {
          final allDeliveries = await _salesRepo.getLivraisons();
          _activeDeliveries = allDeliveries.where((d) => !d.isDelivered && !d.isCancelled).toList();
          _completedDeliveries = allDeliveries.where((d) => d.isDelivered).toList();
        } catch (e) {
          debugPrint('Deliveries loading error: $e');
          _error = 'Erreur lors du chargement des livraisons: $e';
        }
      }
    } catch (e) {
      debugPrint('Dashboard loading error: $e');
      _error = 'Erreur lors du chargement des données: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(bool value) async {
    if (_currentUser == null) return;
    
    _isAvailable = value;
    notifyListeners();

    try {
      if (_isAvailable) {
        if (_agentProfile != null) {
          await _locationService.startTracking(_agentProfile!.id);
        } else {
          debugPrint('Cannot start tracking: Agent profile not found');
          // Try fetching profile first?
        }
      } else {
        await _locationService.stopTracking();
      }
    } catch (e) {
      debugPrint('Error toggling availability: $e');
      // Revert if failed
      _isAvailable = !value; 
      notifyListeners();
    }
  }

  // Actions
  Future<void> refreshDeliveries() async {
    if (_currentUser == null) return;
    try {
       final allDeliveries = await _salesRepo.getLivraisons();
       _activeDeliveries = allDeliveries.where((d) => !d.isDelivered && !d.isCancelled).toList();
       _completedDeliveries = allDeliveries.where((d) => d.isDelivered).toList();
       notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing deliveries: $e");
    }
  }
}
