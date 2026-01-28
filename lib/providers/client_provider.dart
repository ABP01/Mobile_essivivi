import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_models.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

class ClientProvider with ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();
  
  bool _isLoading = false;
  String? _error;
  ClientProfile? _clientProfile;
  List<Map<String, String>> _savedAddresses = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  ClientProfile? get clientProfile => _clientProfile;
  List<Map<String, String>> get savedAddresses => _savedAddresses;

  // Init
  Future<void> loadClientData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepo.getCurrentUser();
      
      if (user != null) {
        // Fetch real client profile
        try {
          final clients = await _userRepo.getClients();
          if (clients.isNotEmpty) {
            _clientProfile = clients.first;
          }
        } catch (e) {
          debugPrint('Error fetching client profile: $e');
        }
      }
      
      // For the address book, we load from local storage
      await _loadLocalAddresses();
      
    } catch (e) {
      debugPrint('Client data error: $e');
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rechargeWallet(double amount) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _userRepo.rechargeWallet(amount);
      
      // Refresh profile to get new balance
      final clients = await _userRepo.getClients();
      if (clients.isNotEmpty) {
        _clientProfile = clients.first;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadLocalAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString('client_addresses');
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      _savedAddresses = decoded.map((e) => Map<String, String>.from(e)).toList();
    }
  }

  Future<void> addAddress(Map<String, String> address) async {
    _savedAddresses.add(address);
    notifyListeners();
    await _saveLocalAddresses();
  }
  
  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < _savedAddresses.length) {
      _savedAddresses.removeAt(index);
      notifyListeners();
      await _saveLocalAddresses();
    }
  }

  Future<void> _saveLocalAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_addresses', jsonEncode(_savedAddresses));
  }
}
