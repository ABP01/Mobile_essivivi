import 'package:essivi_mobile/data/models/cart_models.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/services/cart_service.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'select_location_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String _selectedBottleSize = '20L';
  int _quantity = 4;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _deliveryTime = '9:00 AM - 12:00 PM';
  String _paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  // Position de livraison
  double? _deliveryLatitude;
  double? _deliveryLongitude;
  String? _deliveryAddress;

  // Selected products (support multiple items)
  List<Map<String, dynamic>> _selectedItems = [];
  List<Product> _availableProducts = [];

  final _salesRepo = SalesRepository();
  final _authRepo = AuthRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args.containsKey('cartItems')) {
        final items = args['cartItems'] as List<CartItem>;
        // Convert cart items to selected items
        _selectedItems = items.map((cartItem) {
          // Find product by name (assuming bottleSize matches product name)
          final product = _availableProducts.firstWhere(
            (p) => p.name == cartItem.bottleSize,
            orElse: () => Product(
              id: 0, // Fallback, will be updated when products load
              name: cartItem.bottleSize,
              category: 'water',
              unit: 'bottle',
              quantityPerUnit: 1,
              price: cartItem.unitPrice,
              isActive: true,
              createdAt: '',
              updatedAt: '',
            ),
          );
          return {'product': product.id, 'quantity': cartItem.quantity};
        }).toList();
      } else if (args.containsKey('selectedProduct')) {
        final product = args['selectedProduct'] as Product;
        setState(() {
          _selectedItems = [
            {'product': product.id, 'quantity': _quantity},
          ];
        });
      } else if (args.containsKey('initialBottleSize')) {
        final bottleSize = args['initialBottleSize'] as String;
        // Find product by name
        final product = _availableProducts.firstWhere(
          (p) => p.name == bottleSize,
          orElse: () => Product(
            id: 0,
            name: bottleSize,
            category: 'water',
            unit: 'bottle',
            quantityPerUnit: 1,
            price: CartItem.getPriceForSize(bottleSize),
            isActive: true,
            createdAt: '',
            updatedAt: '',
          ),
        );
        setState(() {
          _selectedItems = [
            {'product': product.id, 'quantity': _quantity},
          ];
        });
      }
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _salesRepo.getProducts();
      setState(() {
        _availableProducts = products;
      });

      // Update selected items with correct product IDs if they were set before products loaded
      if (_selectedItems.isNotEmpty &&
          _selectedItems.any((item) => item['product'] == 0)) {
        setState(() {
          _selectedItems = _selectedItems.map((item) {
            if (item['product'] == 0) {
              // Find product by name from the first item (assuming bottleSize was stored)
              final bottleSize = item['bottleSize'] as String? ?? '20L';
              Product? product;
              if (_availableProducts.isNotEmpty) {
                product = _availableProducts.firstWhere(
                  (p) => p.name == bottleSize,
                  orElse: () => _availableProducts.firstWhere(
                    (p) => p.category == 'water',
                    orElse: () => _availableProducts.first,
                  ),
                );
              }
              if (product != null) {
                return {'product': product.id, 'quantity': item['quantity']};
              }
            }
            return item;
          }).toList();
        });
      }
    } catch (e) {
      // Handle error - maybe show a message
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un produit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_deliveryLatitude == null || _deliveryLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un lieu de livraison'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('🔵 Début création commande...');

      // Get current user
      final user = await _authRepo.getCurrentUser();
      debugPrint('🔵 User récupéré: ${user.id}');

      // Calculate total amount
      final montant = _calculateTotalAmount();
      debugPrint('🔵 Montant calculé: $montant');

      // Create order request
      final request = CreateCommandeRequest(
        clientId: user.id,
        montant: montant,
        dateSouhaitee: _selectedDate.toIso8601String(),
        deliveryLatitude: _deliveryLatitude,
        deliveryLongitude: _deliveryLongitude,
        itemsData: _selectedItems.isNotEmpty ? _selectedItems : null,
      );

      debugPrint('🔵 Request créée: ${request.toJson()}');

      // Submit to backend
      final commande = await _salesRepo.createCommande(request);
      debugPrint('✅ Commande créée avec succès! ID: ${commande.id}');

      // Si la commande vient du panier, on le vide
      await CartService().clearCart();

      if (!mounted) return;

      // Show success dialog
      _showOrderConfirmation(context);
    } catch (e) {
      debugPrint('❌ Erreur création commande: $e');
      if (!mounted) return;

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateTotalAmount() {
    double total = 0.0;
    for (final item in _selectedItems) {
      final productId = item['product'] as int;
      final quantity = item['quantity'] as int;

      final product = _availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: productId,
          name: 'Unknown',
          category: 'water',
          unit: 'bottle',
          quantityPerUnit: 1,
          price: 2000.0, // Default price
          isActive: true,
          createdAt: '',
          updatedAt: '',
        ),
      );

      total += product.price * quantity;
    }

    // Fallback if no items selected
    if (_selectedItems.isEmpty) {
      return CartItem.getPriceForSize(_selectedBottleSize) * _quantity;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Nouvelle Commande',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Icône Panier avec badge
                  FutureBuilder<int>(
                    future: CartService().getItemCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.cart),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                FluentIcons.cart_24_regular,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Selection
                    Text(
                      'Choisir le Produit',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _availableProducts.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _availableProducts.map((product) {
                                return Row(
                                  children: [
                                    _buildProductCard(product),
                                    if (_availableProducts.last != product)
                                      const SizedBox(width: 12),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                    const SizedBox(height: 24),

                    // Quantity
                    Text(
                      'Quantité',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedItems.isNotEmpty) {
                                  // Decrease quantity of first selected item
                                  if (_selectedItems[0]['quantity'] > 1) {
                                    _selectedItems[0]['quantity']--;
                                  }
                                } else {
                                  // Decrease global quantity
                                  if (_quantity > 1) {
                                    _quantity--;
                                  }
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${_selectedItems.isNotEmpty ? _selectedItems[0]['quantity'] : _quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              Text(
                                'Bouteilles',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedItems.isNotEmpty) {
                                  // Increase quantity of first selected item
                                  _selectedItems[0]['quantity']++;
                                } else {
                                  // Increase global quantity
                                  _quantity++;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date de Livraison
                    Text(
                      'Date de Livraison',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              FluentIcons.calendar_24_regular,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMain,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Heure de Livraison
                    Text(
                      'Heure de Livraison',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeSlot('9:00 AM - 12:00 PM'),
                    const SizedBox(height: 12),
                    _buildTimeSlot('12:00 PM - 3:00 PM'),
                    const SizedBox(height: 12),
                    _buildTimeSlot('3:00 PM - 6:00 PM'),
                    const SizedBox(height: 24),

                    // Mode de Paiement
                    Text(
                      'Mode de Paiement',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(
                      'Paiement à la livraison',
                      FluentIcons.money_24_regular,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(
                      'Mobile Money',
                      FluentIcons.phone_24_regular,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentMethod(
                      'Carte Bancaire',
                      FluentIcons.payment_24_regular,
                    ),
                    const SizedBox(height: 24),

                    // Lieu de Livraison
                    Text(
                      'Lieu de Livraison',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectLocationScreen(
                              initialLatitude: _deliveryLatitude,
                              initialLongitude: _deliveryLongitude,
                            ),
                          ),
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _deliveryLatitude = result['latitude'];
                            _deliveryLongitude = result['longitude'];
                            _deliveryAddress = result['address'];
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _deliveryLatitude != null
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.location_24_regular,
                              color: _deliveryLatitude != null
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _deliveryAddress ??
                                        'Sélectionner sur la carte',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: _deliveryAddress != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: _deliveryAddress != null
                                          ? AppColors.textMain
                                          : AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_deliveryLatitude != null)
                                    Text(
                                      'Position confirmée',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Résumé de la Commande
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résumé de la Commande',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedItems.isNotEmpty) ...[
                            ..._selectedItems.map((item) {
                              final productId = item['product'] as int;
                              final quantity = item['quantity'] as int;
                              final product = _availableProducts.firstWhere(
                                (p) => p.id == productId,
                                orElse: () => Product(
                                  id: productId,
                                  name: 'Unknown',
                                  category: 'water',
                                  unit: 'bottle',
                                  quantityPerUnit: 1,
                                  price: 2000.0,
                                  isActive: true,
                                  createdAt: '',
                                  updatedAt: '',
                                ),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildSummaryRow(
                                  '${product.name} (${quantity}x)',
                                  '${(product.price * quantity).toInt()} FCFA',
                                ),
                              );
                            }),
                          ] else ...[
                            _buildSummaryRow('Taille', _selectedBottleSize),
                            _buildSummaryRow(
                              'Quantité',
                              '$_quantity bouteilles',
                            ),
                            _buildSummaryRow('Prix Unitaire', _getPrice()),
                          ],
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                              Text(
                                '${_calculateTotalAmount().toStringAsFixed(0)} FCFA',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Boutons d'action
                    Row(
                      children: [
                        // Bouton Ajouter au Panier
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _addToCart,
                            icon: const Icon(FluentIcons.cart_24_regular),
                            label: Text(
                              'Ajouter',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Bouton Commander Maintenant
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Commander',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleSizeCard(String size, String price) {
    final isSelected = _selectedBottleSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottleSize = size),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              FluentIcons.drop_24_filled,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              size,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isSelected = _selectedItems.any(
      (item) => item['product'] == product.id,
    );
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          // Remove product if already selected
          _selectedItems.removeWhere((item) => item['product'] == product.id);
        } else {
          // Add product with current quantity
          _selectedItems.add({'product': product.id, 'quantity': _quantity});
        }
        _selectedBottleSize = product.name;
      }),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Afficher l'image du produit si elle existe, sinon l'icône
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // En cas d'erreur de chargement, afficher l'icône
                          return Icon(
                            product.category == 'water'
                                ? FluentIcons.drop_24_filled
                                : FluentIcons.food_24_filled,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      product.category == 'water'
                          ? FluentIcons.drop_24_filled
                          : FluentIcons.food_24_filled,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${product.price.toInt()} FCFA',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = _deliveryTime == time;
    return GestureDetector(
      onTap: () => setState(() => _deliveryTime = time),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? FluentIcons.radio_button_24_filled
                  : FluentIcons.radio_button_24_regular,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? FluentIcons.radio_button_24_filled
                  : FluentIcons.radio_button_24_regular,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.textMain),
            const SizedBox(width: 12),
            Text(
              method,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  String _getPrice() {
    if (_selectedItems.isNotEmpty) {
      final productId = _selectedItems[0]['product'] as int;
      final product = _availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: 0,
          name: 'Unknown',
          category: 'water',
          unit: 'bottle',
          quantityPerUnit: 1,
          price: 2000.0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
        ),
      );
      return '${product.price.toInt()} FCFA';
    }
    return '0 FCFA';
  }

  double _getPriceValue() {
    if (_selectedItems.isNotEmpty) {
      final productId = _selectedItems[0]['product'] as int;
      final product = _availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: 0,
          name: 'Unknown',
          category: 'water',
          unit: 'bottle',
          quantityPerUnit: 1,
          price: 2000.0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
        ),
      );
      return product.price;
    }
    return 0.0;
  }

  Future<void> _addToCart() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un produit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cartService = CartService();

    for (final item in _selectedItems) {
      final productId = item['product'] as int;
      final quantity = item['quantity'] as int;

      final product = _availableProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => Product(
          id: productId,
          name: 'Unknown',
          category: 'water',
          unit: 'bottle',
          quantityPerUnit: 1,
          price: 2000.0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
        ),
      );

      final cartItem = CartItem(
        bottleSize: product.name,
        quantity: quantity,
        unitPrice: product.price,
      );

      await cartService.addToCart(cartItem);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedItems.length} produit(s) ajouté(s) au panier',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.primary,
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
          ),
        ),
      );
    }
  }

  void _showOrderConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FluentIcons.checkmark_circle_24_filled,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Commande Passée !',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre commande d\'eau a été enregistrée avec succès.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.payment);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Choisir un paiement',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Terminé',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
