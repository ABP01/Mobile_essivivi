import '../datasources/api_service.dart';
import '../models/bottle_return_models.dart';
import '../../utils/api_config.dart';

class BottleReturnRepository {
  final ApiService _apiService = ApiService();

  /// Soumettre une demande de retour de bouteilles
  Future<BottleReturn> submitReturn(int bottleCount, {String? notes}) async {
    try {
      final data = {
        'bottle_count': bottleCount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      
      final response = await _apiService.client.post(
        ApiConfig.bottleReturnsEndpoint,
        data: data,
      );
      
      return BottleReturn.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer l'historique des retours de bouteilles
  Future<List<BottleReturn>> getReturnHistory() async {
    try {
      final response = await _apiService.client.get(ApiConfig.bottleReturnsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => BottleReturn.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer un retour spécifique par ID
  Future<BottleReturn> getReturnById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.bottleReturnsEndpoint}$id/');
      return BottleReturn.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
