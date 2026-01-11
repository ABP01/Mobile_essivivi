
import '../datasources/api_service.dart';
import '../models/user_models.dart';
import '../../utils/api_config.dart';

class UserRepository {
  final ApiService _apiService = ApiService();

  // ========== CustomUser CRUD ==========

  /// Get all users
  Future<List<CustomUser>> getUsers() async {
    try {
      final response = await _apiService.client.get(ApiConfig.usersEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => CustomUser.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by ID
  Future<CustomUser> getUserById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.usersEndpoint}$id/');
      return CustomUser.fromJson(response.data);
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.usersEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  // ========== AgentProfile CRUD ==========

  /// Get all agents
  Future<List<AgentProfile>> getAgents() async {
    try {
      final response = await _apiService.client.get(ApiConfig.agentsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => AgentProfile.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get agent by ID
  Future<AgentProfile> getAgentById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.agentsEndpoint}$id/');
      return AgentProfile.fromJson(response.data);
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  /// Update agent profile
  Future<AgentProfile> updateAgent(int id, Map<String, dynamic> agentData) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.agentsEndpoint}$id/',
        data: agentData,
      );
      return AgentProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete agent profile
  Future<void> deleteAgent(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.agentsEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  // ========== ClientProfile CRUD ==========

  /// Get all clients
  Future<List<ClientProfile>> getClients() async {
    try {
      final response = await _apiService.client.get(ApiConfig.clientsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => ClientProfile.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get client by ID
  Future<ClientProfile> getClientById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.clientsEndpoint}$id/');
      return ClientProfile.fromJson(response.data);
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  /// Update client profile
  Future<ClientProfile> updateClient(int id, Map<String, dynamic> clientData) async {
    try {
      final response = await _apiService.client.put(
        '${ApiConfig.clientsEndpoint}$id/',
        data: clientData,
      );
      return ClientProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete client profile
  Future<void> deleteClient(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.clientsEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }
}
