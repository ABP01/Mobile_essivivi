class Subscription {
  final int? id;
  final int client;
  final String? clientName;
  final String plan;
  final String bottleSize;
  final int quantity;
  final String preferredDay;
  final String timeSlot;
  final String status;
  final String? nextDelivery;
  final String? createdAt;
  final String? updatedAt;

  Subscription({
    this.id,
    required this.client,
    this.clientName,
    this.plan = 'mensuel',
    this.bottleSize = '20L',
    this.quantity = 4,
    this.preferredDay = 'Lundi',
    this.timeSlot = '09:00 - 12:00',
    this.status = 'active',
    this.nextDelivery,
    this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      client: json['client'],
      clientName: json['client_name'],
      plan: json['plan'],
      bottleSize: json['bottle_size'],
      quantity: json['quantity'],
      preferredDay: json['preferred_day'],
      timeSlot: json['time_slot'],
      status: json['status'],
      nextDelivery: json['next_delivery'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'client': client,
      'plan': plan,
      'bottle_size': bottleSize,
      'quantity': quantity,
      'preferred_day': preferredDay,
      'time_slot': timeSlot,
      'status': status,
      if (nextDelivery != null) 'next_delivery': nextDelivery,
    };
  }
}
