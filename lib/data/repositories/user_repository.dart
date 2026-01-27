import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/user_models.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  // ========== CustomUser CRUD ==========

  /// Get all users
  Future<List<CustomUser>> getUsers() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(ApiConfig.usersEndpoint);
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => CustomUser.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <CustomUser>[];

        rethrow;
      }
    }
  }

  /// Get user by ID
  Future<CustomUser> getUserById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.usersEndpoint}$id/',
      );
      return CustomUser.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Create new user
  Future<CustomUser> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.usersEndpoint,
        data: userData,
      );
      return CustomUser.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Update user
  Future<CustomUser> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.usersEndpoint}$id/',
        data: userData,
      );
      return CustomUser.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.usersEndpoint}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  // ========== AgentProfile CRUD ==========

  /// Get all agents
  Future<List<AgentProfile>> getAgents() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(ApiConfig.agentsEndpoint);
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => AgentProfile.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <AgentProfile>[];

        rethrow;
      }
    }
  }

  /// Get agent by ID
  Future<AgentProfile> getAgentById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.agentsEndpoint}$id/',
      );
      return AgentProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Create agent profile
  Future<AgentProfile> createAgent(Map<String, dynamic> agentData) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.agentsEndpoint,
        data: agentData,
      );
      return AgentProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Update agent profile
  Future<AgentProfile> updateAgent(
    int id,
    Map<String, dynamic> agentData,
  ) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.agentsEndpoint}$id/',
        data: agentData,
      );
      return AgentProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Delete agent profile
  Future<void> deleteAgent(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.agentsEndpoint}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  // ========== ClientProfile CRUD ==========

  /// Get all clients
  Future<List<ClientProfile>> getClients() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.clientsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => ClientProfile.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <ClientProfile>[];

        rethrow;
      }
    }
  }

  /// Get client by ID
  Future<ClientProfile> getClientById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.clientsEndpoint}$id/',
      );
      return ClientProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Create client profile
  Future<ClientProfile> createClient(Map<String, dynamic> clientData) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.clientsEndpoint,
        data: clientData,
      );
      return ClientProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Update client profile
  Future<ClientProfile> updateClient(
    int id,
    Map<String, dynamic> clientData,
  ) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.clientsEndpoint}$id/',
        data: clientData,
      );
      return ClientProfile.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Delete client profile
  Future<void> deleteClient(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.clientsEndpoint}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }
}
