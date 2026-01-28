import 'package:dio/dio.dart';

import '../../utils/api_config.dart';
import '../datasources/api_service.dart';
import '../models/sales_models.dart';

class SalesRepository {
  final ApiService _apiService = ApiService();

  // ========== Commande CRUD ==========

  /// Get all commandes
  Future<List<Commande>> getCommandes() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.commandesEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Commande.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Commande>[];

        rethrow;
      }
    }
  }

  /// Get commande by ID
  Future<Commande> getCommandeById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.commandesEndpoint}$id/',
      );
      return Commande.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Alias for getCommandeById (for compatibility)
  Future<Commande> getCommande(int id) => getCommandeById(id);

  /// Get commandes for a specific client
  Future<List<Commande>> getCommandesByClient(int clientId) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.commandesEndpoint,
          queryParameters: {'client': clientId},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Commande.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Commande>[];

        rethrow;
      }
    }
  }

  /// Get commandes for a specific agent
  Future<List<Commande>> getCommandesByAgent(int agentId) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.commandesEndpoint,
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
        return data.map((json) => Commande.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Commande>[];

        rethrow;
      }
    }
  }

  /// Get commandes by status
  Future<List<Commande>> getCommandesByStatus(String status) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.commandesEndpoint,
          queryParameters: {'statut': status},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Commande.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Commande>[];

        rethrow;
      }
    }
  }

  /// Create new commande
  Future<Commande> createCommande(CreateCommandeRequest request) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.commandesEndpoint,
        data: request.toJson(),
      );
      return Commande.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Update commande
  Future<Commande> updateCommande(int id, UpdateCommandeRequest request) async {
    try {
      final response = await _apiService.client.patch(
        '${ApiConfig.commandesEndpoint}$id/',
        data: request.toJson(),
      );
      return Commande.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Confirm commande reception by client
  Future<Commande> confirmCommande(int id) async {
    return updateCommande(id, UpdateCommandeRequest(statut: 'delivered'));
  }

  /// Delete commande
  Future<void> deleteCommande(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.commandesEndpoint}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  // ========== Product CRUD ==========

  /// Get all products
  Future<List<Product>> getProducts() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.productsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Product.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Product>[];

        rethrow;
      }
    }
  }

  /// Get product by ID
  Future<Product> getProductById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.productsEndpoint}$id/',
      );
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  // ========== Livraison CRUD ==========

  /// Get all livraisons
  Future<List<Livraison>> getLivraisons() async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.livraisonsEndpoint,
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Livraison.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Livraison>[];

        rethrow;
      }
    }
  }

  /// Get livraison by ID
  Future<Livraison> getLivraisonById(int id) async {
    try {
      final response = await _apiService.client.get(
        '${ApiConfig.livraisonsEndpoint}$id/',
      );
      return Livraison.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 502) {
        throw Exception(
          'Service temporairement indisponible. Réessayez plus tard.',
        );
      }
      rethrow;
    }
  }

  /// Get livraisons for a specific tournee
  Future<List<Livraison>> getLivraisonsByTournee(int tourneeId) async {
    const int maxAttempts = 3;
    int attempt = 0;
    int delayMs = 500;

    while (true) {
      try {
        final response = await _apiService.client.get(
          ApiConfig.livraisonsEndpoint,
          queryParameters: {'tournee': tourneeId},
        );
        final dynamic raw = response.data;
        final List<dynamic> data = raw is List
            ? raw
            : (raw is Map && raw['results'] is List)
            ? raw['results'] as List<dynamic>
            : (raw is Map && raw['data'] is List)
            ? raw['data'] as List<dynamic>
            : [];
        return data.map((json) => Livraison.fromJson(json)).toList();
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 502 && attempt < maxAttempts - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
          attempt += 1;
          delayMs *= 2;
          continue;
        }

        if (status == 502) return <Livraison>[];

        rethrow;
      }
    }
  }

  /// Create new livraison with photo and signature
  /// [photoPath] and [signaturePath] are file paths to upload
  Future<Livraison> createLivraison({
    required CreateLivraisonRequest request,
    String? photoPath,
    String? signaturePath,
  }) async {
    try {
      // Create form data for multipart upload
      final formData = FormData();

      // Add basic fields
      formData.fields.addAll([
        MapEntry('tournee', request.tourneeId.toString()),
        MapEntry('client', request.clientId.toString()),
        if (request.commandeId != null)
          MapEntry('commande', request.commandeId.toString()),
        if (request.gpsLat != null)
          MapEntry('gps_lat', request.gpsLat.toString()),
        if (request.gpsLng != null)
          MapEntry('gps_lng', request.gpsLng.toString()),
      ]);

      // Add photo if provided
      if (photoPath != null) {
        final photoFile = await _apiService.createMultipartFile(photoPath);
        formData.files.add(MapEntry('photo_preuve', photoFile));
      }

      // Add signature if provided
      if (signaturePath != null) {
        final signatureFile = await _apiService.createMultipartFile(
          signaturePath,
        );
        formData.files.add(MapEntry('signature', signatureFile));
      }

      final response = await _apiService.client.post(
        ApiConfig.livraisonsEndpoint,
        data: formData,
      );

      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update livraison
  Future<Livraison> updateLivraison({
    required int id,
    String? photoPath,
    String? signaturePath,
    double? gpsLat,
    double? gpsLng,
  }) async {
    try {
      final formData = FormData();

      // Add fields
      if (gpsLat != null)
        formData.fields.add(MapEntry('gps_lat', gpsLat.toString()));
      if (gpsLng != null)
        formData.fields.add(MapEntry('gps_lng', gpsLng.toString()));

      // Add photo if provided
      if (photoPath != null) {
        final photoFile = await _apiService.createMultipartFile(photoPath);
        formData.files.add(MapEntry('photo_preuve', photoFile));
      }

      // Add signature if provided
      if (signaturePath != null) {
        final signatureFile = await _apiService.createMultipartFile(
          signaturePath,
        );
        formData.files.add(MapEntry('signature', signatureFile));
      }

      final response = await _apiService.client.patch(
        '${ApiConfig.livraisonsEndpoint}$id/',
        data: formData,
      );

      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit delivery proof (calls the backend action that also updates command status)
  Future<Livraison> submitProof({
    required int id,
    String? photoPath,
    String? signaturePath,
    double? gpsLat,
    double? gpsLng,
  }) async {
    try {
      // Check if we have files to upload
      bool hasFiles = photoPath != null || signaturePath != null;

      dynamic requestData;

      if (hasFiles) {
        // Use FormData when files are present
        final formData = FormData();

        if (gpsLat != null)
          formData.fields.add(MapEntry('gps_lat', gpsLat.toString()));
        if (gpsLng != null)
          formData.fields.add(MapEntry('gps_lng', gpsLng.toString()));

        if (photoPath != null) {
          final photoFile = await _apiService.createMultipartFile(photoPath);
          formData.files.add(MapEntry('photo_preuve', photoFile));
        }

        if (signaturePath != null) {
          final signatureFile = await _apiService.createMultipartFile(
            signaturePath,
          );
          formData.files.add(MapEntry('signature', signatureFile));
        }

        requestData = formData;
      } else {
        // Use JSON when no files
        requestData = {
          if (gpsLat != null) 'gps_lat': gpsLat,
          if (gpsLng != null) 'gps_lng': gpsLng,
        };
      }

      final response = await _apiService.client.post(
        '${ApiConfig.livraisonsEndpoint}$id/submit_proof/',
        data: requestData,
      );

      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update delivery status (en_route, arriving, etc.)
  Future<Livraison> updateDeliveryStatus(
    int id,
    String status, {
    double? gpsLat,
    double? gpsLng,
  }) async {
    try {
      final data = {'statut_livraison': status};
      if (gpsLat != null) data['gps_lat'] = gpsLat.toString();
      if (gpsLng != null) data['gps_lng'] = gpsLng.toString();

      final response = await _apiService.client.post(
        '${ApiConfig.livraisonsEndpoint}$id/update_status/',
        data: data,
      );

      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete livraison
  Future<void> deleteLivraison(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.livraisonsEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  /// Submit delivery proof (photo/signature)
  Future<Livraison> submitDeliveryProof(
    int deliveryId,
    Map<String, dynamic> proofData,
  ) async {
    try {
      final response = await _apiService.client.post(
        '${ApiConfig.livraisonsEndpoint}$deliveryId/submit_proof/',
        data: proofData,
      );

      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
