class CartItem {
  final String bottleSize;
  int quantity;
  final double unitPrice;

  CartItem({
    required this.bottleSize,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'bottleSize': bottleSize,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      bottleSize: json['bottleSize'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  // Helper pour obtenir le prix selon la taille
  static double getPriceForSize(String size) {
    switch (size) {
      case '5L':
        return 500;
      case '10L':
        return 1000;
      case '20L':
        return 2000;
      default:
        return 0;
    }
  }
}
