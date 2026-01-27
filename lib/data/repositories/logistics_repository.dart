import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/logistics_models.dart';

class LogisticsRepository {
  final ApiService _apiService = ApiService();

  // ========== Tricycle CRUD ==========

  /// Get all tricycles
  Future<List<Tricycle>> getTricycles() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.tricyclesEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Tricycle.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Tricycle>[];

        rethrow;
      }
    }
  }

  /// Get tricycle by ID
  Future<Tricycle> getTricycleById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.tricyclesEndpoint}$id/',
      );
      return Tricycle.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Update tricycle
  Future<Tricycle> updateTricycle(
    int id,
    Map<String, dynamic> tricycleData,
  ) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.tricyclesEndpoint}$id/',
        data: tricycleData,
      );
      return Tricycle.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Delete tricycle
  Future<void> deleteTricycle(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.tricyclesEndpoint}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  // ========== Tournee CRUD ==========

  /// Get all tournees
  Future<List<Tournee>> getTournees() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.tourneesEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Tournee.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Tournee>[];

        rethrow;
      }
    }
  }

  /// Get tournee by ID
  Future<Tournee> getTourneeById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.tourneesEndpoint}$id/',
      );
      return Tournee.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Get tournees for a specific agent
  Future<List<Tournee>> getTourneesByAgent(int agentId) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.tourneesEndpoint,
          queryParameters: {'agent': agentId},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Tournee.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Tournee>[];

        rethrow;
      }
    }
  }

  /// Get active tournees
  Future<List<Tournee>> getActiveTournees() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.tourneesEndpoint,
          queryParameters: {'active': true},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Tournee.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Tournee>[];

        rethrow;
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Get all agent locations
  Future<List<Map<String, dynamic>>> getAgentLocations() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          '/logistics/agents/locations/',
        );
        return List<Map<String, dynamic>>.from(response.data);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Map<String, dynamic>>[];

        rethrow;
      }
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
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
