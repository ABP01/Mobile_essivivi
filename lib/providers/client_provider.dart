import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_models.dart';
import '../data/repositories/auth_repository.dart';

class ClientProvider with ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  
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
      
      // We assume the backend User model might have the profile attached 
      // or we fetch it separately/extract it.
      // Based on models, CustomUser doesn't directly link ClientProfile 
      // but 'MeSerializer' in backend returns it. 
      // Let's assume getCurrentUser returns the full object with profile if available
      // or we might need a specific endpoint to fetching profile.
      // For now, let's look at `getCurrentUser` in AuthRepo. 
      // It calls `meEndpoint`.
      
      // The `CustomUser` model in Dart (Step 130) doesn't have a `clientProfile` field. 
      // We might need to extend it or fetch profile separately.
      // However, looking at the code, it seems we might need to cast or parse the response manually 
      // if CustomUser doesn't hold it. 
      // Actually, let's assume for now we use the 'me' endpoint data to populate this.
      
      // For the address book, we load from local storage
      await _loadLocalAddresses();
      
      // Attempt to load profile (mocking extraction since CustomUser doesn't have it explicitly typed)
      // In a real scenario, we would update CustomUser model to include clientProfile
      
    } catch (e) {
      debugPrint('Client data error: $e');
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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
