import 'package:essivi_mobile/utils/api_config.dart';
import '../datasources/api_service.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  /// Get dashboard statistics
  /// Returns a Map containing various statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.client.get(ApiConfig.dashboardStatsEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific stat by key
  Future<dynamic> getStatByKey(String key) async {
    try {
      final stats = await getStats();
      return stats[key];
    } catch (e) {
      rethrow;
    }
  }
}
