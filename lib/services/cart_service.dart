import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/cart_models.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  /// Ajouter un article au panier
  Future<void> addToCart(CartItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();
    
    // Vérifier si l'article existe déjà (même taille)
    final existingIndex = cart.indexWhere((i) => i.bottleSize == item.bottleSize);
    
    if (existingIndex != -1) {
      // Augmenter la quantité
      cart[existingIndex].quantity += item.quantity;
    } else {
      // Ajouter nouvel article
      cart.add(item);
    }
    
    await _saveCart(cart);
  }

  /// Obtenir tous les articles du panier
  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    
    if (cartJson == null || cartJson.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(cartJson);
      return decoded.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print('Erreur lecture panier: $e');
      return [];
    }
  }

  /// Mettre à jour la quantité d'un article
  Future<void> updateQuantity(int index, int quantity) async {
    final cart = await getCart();
    
    if (index >= 0 && index < cart.length) {
      if (quantity <= 0) {
        // Supprimer si quantité = 0
        cart.removeAt(index);
      } else {
        cart[index].quantity = quantity;
      }
      await _saveCart(cart);
    }
  }

  /// Supprimer un article du panier
  Future<void> removeItem(int index) async {
    final cart = await getCart();
    
    if (index >= 0 && index < cart.length) {
      cart.removeAt(index);
      await _saveCart(cart);
    }
  }

  /// Vider le panier
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  /// Obtenir le total du panier
  Future<double> getTotal() async {
    final cart = await getCart();
    double total = 0;
    for (var item in cart) {
      total += item.total;
    }
    return total;
  }

  /// Obtenir le nombre total d'articles
  Future<int> getItemCount() async {
    final cart = await getCart();
    int count = 0;
    for (var item in cart) {
      count += item.quantity;
    }
    return count;
  }

  /// Sauvegarder le panier
  Future<void> _saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(cart.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }
}
