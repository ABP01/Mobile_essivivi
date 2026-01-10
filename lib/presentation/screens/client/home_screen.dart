import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/l10n/app_localizations.dart';
import 'package:essivi_mobile/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/data/models/user_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _sortOption = 'newest';
  bool _isLoading = true;
  String? _errorMessage;

  late TextEditingController _searchController;
  final _salesRepo = SalesRepository();
  final _authRepo = AuthRepository();

  List<Commande> _recentOrders = [];
  CustomUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load user profile
      _currentUser = await _authRepo.getCurrentUser();
      
      if (_currentUser != null) {
        // Load recent orders for this client
        final allOrders = await _salesRepo.getCommandesByClient(_currentUser!.id);
        _recentOrders = allOrders.take(5).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Commande> get _filteredAndSortedOrders {
    List<Commande> filtered = _recentOrders.where((order) {
      final matchesSearch = order.id.toString().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    if (_sortOption == 'newest') {
      filtered.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
    } else if (_sortOption == 'oldest') {
      filtered.sort((a, b) => DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
    } else if (_sortOption == 'id') {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage('assets/images/delivery_man.png'), // Placeholder
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.hello(_currentUser?.username ?? 'User'),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              _currentUser?.email ?? 'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(FluentIcons.person_24_regular, color: theme.textTheme.bodyLarge?.color),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? theme.cardColor : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(FluentIcons.alert_24_regular, color: theme.textTheme.bodyLarge?.color),
                                if (context.watch<NotificationProvider>().unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 8,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(
                          context,
                          icon: FluentIcons.map_24_filled,
                          label: AppLocalizations.of(context)!.route,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.tracking),
                        ),
                        _buildQuickAction(
                          context,
                          icon: FluentIcons.history_24_filled,
                          label: AppLocalizations.of(context)!.history,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.shipmentHistory),
                        ),
                        _buildQuickAction(
                          context,
                          icon: FluentIcons.chat_help_24_filled,
                          label: AppLocalizations.of(context)!.support,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
                        ),
                        _buildQuickAction(
                          context,
                          icon: FluentIcons.arrow_clockwise_24_filled,
                          label: AppLocalizations.of(context)!.returnText,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.bottleReturn),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // New Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.createOrder);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.add_circle_24_filled, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.newOrder,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      AppLocalizations.of(context)!.currentWaterOrder,
                       style: GoogleFonts.poppins(
                         fontSize: 18, 
                         fontWeight: FontWeight.bold,
                         color: theme.textTheme.bodyLarge?.color,
                       ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.tracking);
                      },
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          'Water Bottles\n20L x 4',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'ID:V789456AR123',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Image Box
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Image.asset(
                                'assets/images/cardboard_boxes.png',
                                height: 140,
                                width: 140,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Shipment Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.recentOrders,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.shipmentHistory);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              AppLocalizations.of(context)!.viewMore,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(FluentIcons.search_24_regular, color: theme.textTheme.bodyLarge?.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              style: GoogleFonts.poppins(color: theme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.searchOrderPlaceholder,
                                hintStyle: GoogleFonts.poppins(color: isDark ? Colors.white54 : Colors.black54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showSortMenu(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(FluentIcons.filter_24_filled, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(context, AppLocalizations.of(context)!.all, 'all'),
                          _buildFilterChip(context, AppLocalizations.of(context)!.pending, 'pending'),
                          _buildFilterChip(context, AppLocalizations.of(context)!.onDelivery, 'on_delivery'),
                          _buildFilterChip(context, AppLocalizations.of(context)!.delivered, 'delivered'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // List Items
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      Center(
                        child: Column(
                          children: [
                            Text('Erreur: $_errorMessage'),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    else if (_filteredAndSortedOrders.isEmpty)
                      const Center(child: Text('Aucune commande'))
                    else
                      ..._filteredAndSortedOrders.map((order) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildShipmentItem(
                          title: '${order.montant.toStringAsFixed(0)} FCFA',
                          id: '#${order.id}',
                          status: order.statutLabel,
                          icon: order.isDelivered ? FluentIcons.box_checkmark_24_filled : FluentIcons.box_24_filled,
                        ),
                      )),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.2), // Faint orange bg
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(FluentIcons.home_24_filled, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.home,
                          style: GoogleFonts.poppins(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    child: Icon(FluentIcons.settings_24_regular, color: theme.textTheme.bodySmall?.color),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                    child: Icon(FluentIcons.person_24_regular, color: theme.textTheme.bodySmall?.color),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(FluentIcons.alert_24_regular, color: theme.textTheme.bodySmall?.color),
                        if (context.watch<NotificationProvider>().unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 8,
                                minHeight: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String statusKey) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _searchQuery.isEmpty && statusKey == 'all'; // Temporary logic or just remove isSelected if not needed

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.ordersList,
          arguments: statusKey,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : (isDark ? theme.cardColor : Colors.white),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentItem({required String title, required String id, required String status, required IconData icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (status == 'on_delivery') {
          Navigator.pushNamed(context, AppRoutes.tracking);
        } else {
          Navigator.pushNamed(
            context, 
            AppRoutes.shipmentDetails,
            arguments: {
              'title': title,
              'id': id,
              'status': status,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    id,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: theme.textTheme.bodyLarge?.color),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sortBy,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption(context, AppLocalizations.of(context)!.newest, 'newest'),
            _buildSortOption(context, AppLocalizations.of(context)!.oldest, 'oldest'),
            _buildSortOption(context, AppLocalizations.of(context)!.orderNumber, 'id'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _sortOption == value;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
      onTap: () {
        setState(() {
          _sortOption = value;
        });
        Navigator.pop(context);
      },
    );
  }
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
