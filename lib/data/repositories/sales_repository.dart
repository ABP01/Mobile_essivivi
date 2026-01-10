import 'package:dio/dio.dart';
import '../datasources/api_service.dart';
import '../models/sales_models.dart';
import '../../utils/api_config.dart';

class SalesRepository {
  final ApiService _apiService = ApiService();

  // ========== Commande CRUD ==========

  /// Get all commandes
  Future<List<Commande>> getCommandes() async {
    try {
      final response = await _apiService.client.get(ApiConfig.commandesEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => Commande.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get commande by ID
  Future<Commande> getCommandeById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.commandesEndpoint}$id/');
      return Commande.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Alias for getCommandeById (for compatibility)
  Future<Commande> getCommande(int id) => getCommandeById(id);


  /// Get commandes for a specific client
  Future<List<Commande>> getCommandesByClient(int clientId) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.commandesEndpoint,
        queryParameters: {'client': clientId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Commande.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get commandes for a specific agent
  Future<List<Commande>> getCommandesByAgent(int agentId) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.commandesEndpoint,
        queryParameters: {'agent': agentId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Commande.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get commandes by status
  Future<List<Commande>> getCommandesByStatus(String status) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.commandesEndpoint,
        queryParameters: {'statut': status},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Commande.fromJson(json)).toList();
    } catch (e) {
      rethrow;
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
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  /// Delete commande
  Future<void> deleteCommande(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.commandesEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }

  // ========== Livraison CRUD ==========

  /// Get all livraisons
  Future<List<Livraison>> getLivraisons() async {
    try {
      final response = await _apiService.client.get(ApiConfig.livraisonsEndpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => Livraison.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get livraison by ID
  Future<Livraison> getLivraisonById(int id) async {
    try {
      final response = await _apiService.client.get('${ApiConfig.livraisonsEndpoint}$id/');
      return Livraison.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get livraisons for a specific tournee
  Future<List<Livraison>> getLivraisonsByTournee(int tourneeId) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.livraisonsEndpoint,
        queryParameters: {'tournee': tourneeId},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Livraison.fromJson(json)).toList();
    } catch (e) {
      rethrow;
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
        if (request.commandeId != null) MapEntry('commande', request.commandeId.toString()),
        if (request.gpsLat != null) MapEntry('gps_lat', request.gpsLat.toString()),
        if (request.gpsLng != null) MapEntry('gps_lng', request.gpsLng.toString()),
      ]);

      // Add photo if provided
      if (photoPath != null) {
        final photoFile = await _apiService.createMultipartFile(photoPath);
        formData.files.add(MapEntry('photo_preuve', photoFile));
      }

      // Add signature if provided
      if (signaturePath != null) {
        final signatureFile = await _apiService.createMultipartFile(signaturePath);
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
      if (gpsLat != null) formData.fields.add(MapEntry('gps_lat', gpsLat.toString()));
      if (gpsLng != null) formData.fields.add(MapEntry('gps_lng', gpsLng.toString()));

      // Add photo if provided
      if (photoPath != null) {
        final photoFile = await _apiService.createMultipartFile(photoPath);
        formData.files.add(MapEntry('photo_preuve', photoFile));
      }

      // Add signature if provided
      if (signaturePath != null) {
        final signatureFile = await _apiService.createMultipartFile(signaturePath);
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

  /// Delete livraison
  Future<void> deleteLivraison(int id) async {
    try {
      await _apiService.client.delete('${ApiConfig.livraisonsEndpoint}$id/');
    } catch (e) {
      rethrow;
    }
  }
}
