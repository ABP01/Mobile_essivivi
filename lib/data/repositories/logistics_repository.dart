
import '../datasources/api_service.dart';
import '../models/logistics_models.dart';
import '../../utils/api_config.dart';

class LogisticsRepository {
  final ApiService _apiService = ApiService();

  // ========== Tricycle CRUD ==========

  /// Get all tricycles
  Future<List<Tricycle>> getTricycles() async {
    try {
      final response = await _apiService.client.get(ApiConfig.tricyclesEndpoint);
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return data.map((json) => Tricycle.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get tricycle by ID
  Future<Tricycle> getTricycleById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.tricyclesEndpoint}$id/');
      return Tricycle.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create new tricycle
  Future<Tricycle> createTricycle(Map<String, dynamic> tricycleData) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.tricyclesEndpoint,
        data: tricycleData,
      );
      return Tricycle.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update tricycle
  Future<Tricycle> updateTricycle(int id, Map<String, dynamic> tricycleData) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.tricyclesEndpoint}$id/',
        data: tricycleData,
      );
      return Tricycle.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete tricycle
  Future<void> deleteTricycle(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.tricyclesEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  // ========== Tournee CRUD ==========

  /// Get all tournees
  Future<List<Tournee>> getTournees() async {
    try {
      final response = await _apiService.client.get(ApiConfig.tourneesEndpoint);
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get tournee by ID
  Future<Tournee> getTourneeById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.tourneesEndpoint}$id/');
      return Tournee.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get tournees for a specific agent
  Future<List<Tournee>> getTourneesByAgent(int agentId) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.tourneesEndpoint,
        queryParameters: {'agent': agentId},
      );
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get active tournees
  Future<List<Tournee>> getActiveTournees() async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.tourneesEndpoint,
        queryParameters: {'active': true},
      );
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return data.map((json) => Tournee.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create new tournee
  Future<Tournee> createTournee(CreateTourneeRequest request) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.tourneesEndpoint,
        data: request.toJson(),
      );
      return Tournee.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update tournee
  Future<Tournee> updateTournee(int id, UpdateTourneeRequest request) async {
    try {
      final response = await _apiService.client.patch(
        '${ApiConfig.tourneesEndpoint}$id/',
        data: request.toJson(),
      );
      return Tournee.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete a tournee (set date_fin and stock_retour)
  Future<Tournee> completeTournee(int id, int stockRetour) async {
    try {
      final request = UpdateTourneeRequest(
        dateFin: DateTime.now().toIso8601String(),
        stockRetour: stockRetour,
      );
      return await updateTournee(id, request);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete tournee
  Future<void> deleteTournee(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.tourneesEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  // ========== Géolocalisation ==========

  /// Update agent location
  Future<void> updateAgentLocation(
    int agentId,
    double latitude,
    double longitude,
    double? accuracy,
    double? speed,
    double? heading,
  ) async {
    try {
      await _apiService.client.post(
        '/logistics/agents/$agentId/update_location/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          if (speed != null) 'speed': speed,
          if (heading != null) 'heading': heading,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get all agent locations
  Future<List<Map<String, dynamic>>> getAgentLocations() async {
    try {
      final response = await _apiService.client.get('/logistics/agents/locations/');
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Find nearest agents to a location
  Future<List<Map<String, dynamic>>> findNearestAgents(
    double latitude,
    double longitude, {
    int maxAgents = 5,
  }) async {
    try {
      final response = await _apiService.client.post(
        '/logistics/agents/nearest/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'max_agents': maxAgents,
        },
      );
      // Usually these custom endpoints return List directly, but checking for safety
      final dynamic rawData = response.data;
      final List<dynamic> data = (rawData is Map && rawData.containsKey('results')) 
          ? rawData['results'] 
          : rawData;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }
}

