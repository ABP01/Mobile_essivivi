/// Logistics-related data models matching the Django backend structure

class Tricycle {
  final int id;
  final String immatriculation;
  final String status;
  final String createdAt;

  Tricycle({
    required this.id,
    required this.immatriculation,
    required this.status,
    required this.createdAt,
  });

  factory Tricycle.fromJson(Map<String, dynamic> json) {
    return Tricycle(
      id: json['id'] as int,
      immatriculation: json['immatriculation'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'immatriculation': immatriculation,
      'status': status,
      'created_at': createdAt,
    };
  }

  bool get isActive => status == 'active';
  bool get isMaintenance => status == 'maintenance';
  bool get isInactive => status == 'inactive';

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'maintenance':
        return 'En Maintenance';
      case 'inactive':
        return 'Inactif';
      default:
        return status;
    }
  }
}

class Tournee {
  final int id;
  final int agentId;
  final int? tricycleId;
  final String dateDebut;
  final String? dateFin;
  final int stockInitial;
  final int stockRetour;

  Tournee({
    required this.id,
    required this.agentId,
    this.tricycleId,
    required this.dateDebut,
    this.dateFin,
    required this.stockInitial,
    required this.stockRetour,
  });

  factory Tournee.fromJson(Map<String, dynamic> json) {
    return Tournee(
      id: json['id'] as int,
      agentId: json['agent'] as int,
      tricycleId: json['tricycle'] as int?,
      dateDebut: json['date_debut'] as String,
      dateFin: json['date_fin'] as String?,
      stockInitial: json['stock_initial'] as int,
      stockRetour: json['stock_retour'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agent': agentId,
      'tricycle': tricycleId,
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'stock_initial': stockInitial,
      'stock_retour': stockRetour,
    };
  }

  bool get isActive => dateFin == null;
  bool get isCompleted => dateFin != null;

  int get stockVendu => stockInitial - stockRetour;
}

/// Create Tournee request model
class CreateTourneeRequest {
  final int agentId;
  final int? tricycleId;
  final String dateDebut;
  final int stockInitial;

  CreateTourneeRequest({
    required this.agentId,
    this.tricycleId,
    required this.dateDebut,
    required this.stockInitial,
  });

  Map<String, dynamic> toJson() {
    return {
      'agent': agentId,
      'tricycle': tricycleId,
      'date_debut': dateDebut,
      'stock_initial': stockInitial,
      'stock_retour': 0,
    };
  }
}

/// Update Tournee request model
class UpdateTourneeRequest {
  final String? dateFin;
  final int? stockRetour;

  UpdateTourneeRequest({
    this.dateFin,
    this.stockRetour,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (dateFin != null) data['date_fin'] = dateFin;
    if (stockRetour != null) data['stock_retour'] = stockRetour;
    return data;
  }
}
