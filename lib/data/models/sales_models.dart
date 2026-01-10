/// Sales-related data models matching the Django backend structure

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
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as int,
      clientId: json['client'] as int,
      agentId: json['agent'] as int?,
      statut: json['statut'] as String,
      montant: (json['montant'] as num).toDouble(),
      dateSouhaitee: json['date_souhaitee'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deliveryLatitude: json['delivery_latitude'] != null ? (json['delivery_latitude'] as num).toDouble() : null,
      deliveryLongitude: json['delivery_longitude'] != null ? (json['delivery_longitude'] as num).toDouble() : null,
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
  final double? gpsLat;
  final double? gpsLng;
  final String? photoPreuve;
  final String? signature;
  final String timestamp;

  Livraison({
    required this.id,
    required this.tourneeId,
    this.commandeId,
    required this.clientId,
    this.gpsLat,
    this.gpsLng,
    this.photoPreuve,
    this.signature,
    required this.timestamp,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] as int,
      tourneeId: json['tournee'] as int,
      commandeId: json['commande'] as int?,
      clientId: json['client'] as int,
      gpsLat: json['gps_lat'] != null ? (json['gps_lat'] as num).toDouble() : null,
      gpsLng: json['gps_lng'] != null ? (json['gps_lng'] as num).toDouble() : null,
      photoPreuve: json['photo_preuve'] as String?,
      signature: json['signature'] as String?,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournee': tourneeId,
      'commande': commandeId,
      'client': clientId,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'photo_preuve': photoPreuve,
      'signature': signature,
      'timestamp': timestamp,
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

  CreateCommandeRequest({
    required this.clientId,
    required this.montant,
    required this.dateSouhaitee,
    this.agentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'client': clientId,
      'montant': montant,
      'date_souhaitee': dateSouhaitee,
      'agent': agentId,
      'statut': 'pending',
    };
  }
}

/// Update Commande request model
class UpdateCommandeRequest {
  final String? statut;
  final int? agentId;

  UpdateCommandeRequest({
    this.statut,
    this.agentId,
  });

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
