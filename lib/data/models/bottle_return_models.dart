class BottleReturn {
  final int? id;
  final int client;
  final String? clientName;
  final int bottleCount;
  final double creditAmount;
  final String status;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  BottleReturn({
    this.id,
    required this.client,
    this.clientName,
    required this.bottleCount,
    required this.creditAmount,
    this.status = 'pending',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BottleReturn.fromJson(Map<String, dynamic> json) {
    return BottleReturn(
      id: json['id'],
      client: json['client'],
      clientName: json['client_name'],
      bottleCount: json['bottle_count'],
      creditAmount: (json['credit_amount'] as num).toDouble(),
      status: json['status'],
      notes: json['notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client': client,
      'bottle_count': bottleCount,
      'credit_amount': creditAmount,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}
