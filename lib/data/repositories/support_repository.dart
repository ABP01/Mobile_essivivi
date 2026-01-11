
import '../datasources/api_service.dart';
import '../models/faq_models.dart';
import '../../utils/api_config.dart';

class SupportRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les FAQs actives
  Future<List<FAQ>> getFAQs() async {
    try {
      final response = await _apiService.client.get(ApiConfig.faqsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => FAQ.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer les FAQs par catégorie
  Future<List<FAQ>> getFAQsByCategory(String category) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.faqsEndpoint,
        queryParameters: {'category': category},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => FAQ.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
