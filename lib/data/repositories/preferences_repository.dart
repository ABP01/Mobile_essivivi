import 'package:dio/dio.dart';
import '../datasources/api_service.dart';
import '../models/preferences_models.dart';
import '../../utils/api_config.dart';

class PreferencesRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer les préférences de l'utilisateur
  Future<UserPreferences> getPreferences() async {
    try {
      final response = await _apiService.client.get(ApiConfig.preferencesEndpoint);
      return UserPreferences.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour les préférences de l'utilisateur
  Future<UserPreferences> updatePreferences(UserPreferences preferences) async {
    try {
      final response = await _apiService.client.put(
        ApiConfig.preferencesEndpoint,
        data: preferences.toJson(),
      );
      return UserPreferences.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Mettre à jour partiellement les préférences
  Future<UserPreferences> updatePartialPreferences(Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.client.put(
        ApiConfig.preferencesEndpoint,
        data: updates,
      );
      return UserPreferences.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
