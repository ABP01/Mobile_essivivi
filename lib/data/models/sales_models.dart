/// Sales-related data models matching the Django backend structure

class Product {
  final int id;
  final String name;
  final String category;
  final String unit;
  final int quantityPerUnit;
  final double price;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantityPerUnit,
    required this.price,
    this.description,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      quantityPerUnit: json['quantity_per_unit'] as int,
      price: double.parse(json['price'].toString()),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'quantity_per_unit': quantityPerUnit,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Commande {
  final int id;
  final int clientId;
  final int? agentId;
  final String statut;
  final double montant;
  final String dateSouhaitee;
  final String createdAt;
  final String updatedAt;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? clientPhone;
  final String? agentPhone;
  final List<Livraison>? livraisons;

  Commande({
    required this.id,
    required this.clientId,
    this.agentId,
    required this.statut,
    required this.montant,
    required this.dateSouhaitee,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.clientPhone,
    this.agentPhone,
    this.livraisons,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as int,
      clientId: json['client'] as int,
      agentId: json['agent'] as int?,
      statut: json['statut'] as String,
      montant: double.parse(json['montant'].toString()),
      dateSouhaitee: json['date_souhaitee'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deliveryLatitude: json['delivery_latitude'] != null
          ? double.tryParse(json['delivery_latitude'].toString())
          : null,
      deliveryLongitude: json['delivery_longitude'] != null
          ? double.tryParse(json['delivery_longitude'].toString())
          : null,
      clientPhone: json['client_phone'] as String?,
      agentPhone: json['agent_phone'] as String?,
      livraisons: (json['livraisons'] as List<dynamic>?)
          ?.map((e) => Livraison.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'agent': agentId,
      'statut': statut,
      'montant': montant,
      'date_souhaitee': dateSouhaitee,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
    };
  }

  // Getter pour compatibilité
  int? get agent => agentId;

  bool get isPending => statut == 'pending';
  bool get isValidated => statut == 'validated';
  bool get isDelivered => statut == 'delivered';
  bool get isCancelled => statut == 'cancelled';

  String get statutLabel {
    switch (statut) {
      case 'pending':
        return 'En attente';
      case 'validated':
        return 'Validée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return statut;
    }
  }
}

class Livraison {
  final int id;
  final int tourneeId;
  final int? commandeId;
  final int clientId;
  final String? statutLivraison;
  final double? gpsLat;
  final double? gpsLng;
  final String? photoPreuve;
  final String? signature;
  final bool preuveValidee;
  final String timestamp;
  final String? clientPhone;
  final String? agentPhone;
  final int? agentAllocated;

  // Added getters for UI compatibility
  bool get isDelivered => preuveValidee;
  String get createdAt => timestamp;

  // Status helpers
  bool get isAssigned => statutLivraison == 'assigned';
  bool get isEnRoute => statutLivraison == 'en_route';
  bool get isArriving => statutLivraison == 'arriving';
  bool get isCancelled => false; // Not implemented in backend yet

  Livraison({
    required this.id,
    required this.tourneeId,
    this.commandeId,
    required this.clientId,
    this.statutLivraison,
    this.gpsLat,
    this.gpsLng,
    this.photoPreuve,
    this.signature,
    required this.preuveValidee,
    required this.timestamp,
    this.clientPhone,
    this.agentPhone,
    this.agentAllocated,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] as int,
      tourneeId: json['tournee'] as int,
      commandeId: json['commande'] as int?,
      clientId: json['client'] as int,
      statutLivraison: json['statut_livraison'] as String? ?? 'assigned',
      gpsLat: json['gps_lat'] != null
          ? (json['gps_lat'] as num).toDouble()
          : null,
      gpsLng: json['gps_lng'] != null
          ? (json['gps_lng'] as num).toDouble()
          : null,
      photoPreuve: json['photo_preuve'] as String?,
      signature: json['signature'] as String?,
      preuveValidee: json['preuve_validee'] as bool? ?? false,
      timestamp: json['timestamp'] as String,
      clientPhone: json['client_phone'] as String?,
      agentPhone: json['agent_phone'] as String?,
      agentAllocated: json['agent_allocated'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournee': tourneeId,
      'commande': commandeId,
      'client': clientId,
      'statut_livraison': statutLivraison,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'photo_preuve': photoPreuve,
      'signature': signature,
      'preuve_validee': preuveValidee,
      'timestamp': timestamp,
      'agent_allocated': agentAllocated,
    };
  }

  bool get hasLocation => gpsLat != null && gpsLng != null;
  bool get hasProof => photoPreuve != null;
  bool get hasSignature => signature != null;
  bool get isComplete => hasLocation && hasProof && hasSignature;
}

/// Create Commande request model
class CreateCommandeRequest {
  final int clientId;
  final double montant;
  final String dateSouhaitee;
  final int? agentId;
  final double? deliveryLatitude;
  final double? deliveryLongitude;

  CreateCommandeRequest({
    required this.clientId,
    required this.montant,
    required this.dateSouhaitee,
    this.agentId,
    this.deliveryLatitude,
    this.deliveryLongitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'client': clientId,
      'montant': montant,
      'date_souhaitee': dateSouhaitee,
      'agent': agentId,
      'statut': 'pending',
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
    };
  }
}

/// Update Commande request model
class UpdateCommandeRequest {
  final String? statut;
  final int? agentId;

  UpdateCommandeRequest({this.statut, this.agentId});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (statut != null) data['statut'] = statut;
    if (agentId != null) data['agent'] = agentId;
    return data;
  }
}

/// Create Livraison request model
/// Note: For file uploads, use FormData with multipart
class CreateLivraisonRequest {
  final int tourneeId;
  final int clientId;
  final int? commandeId;
  final double? gpsLat;
  final double? gpsLng;

  CreateLivraisonRequest({
    required this.tourneeId,
    required this.clientId,
    this.commandeId,
    this.gpsLat,
    this.gpsLng,
  });

  Map<String, dynamic> toJson() {
    return {
      'tournee': tourneeId,
      'client': clientId,
      'commande': commandeId,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
    };
  }
}
