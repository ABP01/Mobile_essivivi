import '../../domain/repositories/i_cart_repository.dart';
import '../models/cart_models.dart';

class CartRepository implements ICartRepository {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  
  CartRepository._internal();

  final List<CartItem> _items = [];

  @override
  Future<void> addToCart(CartItem item) async {
    // Check if item of same size already exists
    final index = _items.indexWhere((element) => element.bottleSize == item.bottleSize);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
  }

  @override
  Future<List<CartItem>> getCart() async {
    return _items;
  }

  @override
  Future<void> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
    }
  }

  @override
  Future<void> removeItem(int index) async {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
  }

  @override
  Future<double> getTotal() async {
    return _items.fold<double>(0.0, (sum, item) => sum + item.total);
  }

  @override
  Future<int> getItemCount() async {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}