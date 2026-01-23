import '../../data/models/cart_models.dart';

abstract class ICartRepository {
  /// Add an item to the cart
  Future<void> addToCart(CartItem item);
  
  /// Get all items in the cart
  Future<List<CartItem>> getCart();
  
  /// Update the quantity of an item at the given index
  Future<void> updateQuantity(int index, int quantity);
  
  /// Remove an item from the cart at the given index
  Future<void> removeItem(int index);
  
  /// Clear all items from the cart
  Future<void> clearCart();
  
  /// Get the total price of all items in the cart
  Future<double> getTotal();
  
  /// Get the total count of items in the cart
  Future<int> getItemCount();
}
