import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/bottle_return_models.dart';

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
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Récupérer l'historique des retours de bouteilles
  Future<List<BottleReturn>> getReturnHistory() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.bottleReturnsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => BottleReturn.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <BottleReturn>[];

        rethrow;
      }
    }
  }

  /// Récupérer un retour spécifique par ID
  Future<BottleReturn> getReturnById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.bottleReturnsEndpoint}$id/',
      );
      return BottleReturn.fromJson(response.data);
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
