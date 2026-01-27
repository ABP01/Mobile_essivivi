import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/faq_models.dart';

class SupportRepository {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les FAQs actives
  Future<List<FAQ>> getFAQs() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(ApiConfig.faqsEndpoint);
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => FAQ.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <FAQ>[];

        rethrow;
      }
    }
  }

  /// Récupérer les FAQs par catégorie
  Future<List<FAQ>> getFAQsByCategory(String category) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.faqsEndpoint,
          queryParameters: {'category': category},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => FAQ.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <FAQ>[];

        rethrow;
      }
    }
  }
}
