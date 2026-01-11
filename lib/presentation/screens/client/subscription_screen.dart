import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/data/repositories/subscription_repository.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/subscription_models.dart';

class AbonnementScreen extends StatefulWidget {
  const AbonnementScreen({super.key});

  @override
  State<AbonnementScreen> createState() => _AbonnementScreenState();
}

class _AbonnementScreenState extends State<AbonnementScreen> {
  final _subscriptionRepo = SubscriptionRepository();
  final _authRepo = AuthRepository();
  
  Subscription? _currentSubscription;
  bool _isLoading = true;
  
  String _selectedPlan = 'Mensuel';
  String _selectedBottleSize = '20L';
  int _bottleQuantity = 4;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() => _isLoading = true);
    try {
      _currentSubscription = await _subscriptionRepo.getCurrentSubscription();
      if (_currentSubscription != null) {
        _selectedPlan = _getPlanLabel(_currentSubscription!.plan);
        _selectedBottleSize = _currentSubscription!.bottleSize;
        _bottleQuantity = _currentSubscription!.quantity;
      }
    } catch (e) {
      // No subscription yet
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getPlanLabel(String plan) {
    switch (plan) {
      case 'hebdomadaire': return 'Hebdomadaire';
      case 'bi_mensuel': return 'Bi-mensuel';
      case 'mensuel': return 'Mensuel';
      default: return 'Mensuel';
    }
  }

  String _getPlanCode(String label) {
    switch (label) {
      case 'Hebdomadaire': return 'hebdomadaire';
      case 'Bi-mensuel': return 'bi_mensuel';
      case 'Mensuel': return 'mensuel';
      default: return 'mensuel';
    }
  }

  Future<void> _updateSubscription() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.getCurrentUser();
      final subscription = Subscription(
        client: user.id,
        plan: _getPlanCode(_selectedPlan),
        bottleSize: _selectedBottleSize,
        quantity: _bottleQuantity,
      );

      if (_currentSubscription == null) {
        await _subscriptionRepo.createSubscription(subscription);
      } else {
        await _subscriptionRepo.updateSubscription(_currentSubscription!.id!, subscription);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan mis à jour avec succès', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadSubscription();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pauseSubscription() async {
    if (_currentSubscription == null) return;
    
    try {
      await _subscriptionRepo.pauseSubscription(_currentSubscription!.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abonnement mis en pause', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.primary,
        ),
      );
      await _loadSubscription();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    'Abonnement',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                    // Plan Actuel Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(FluentIcons.food_24_filled, color: Colors.white, size: 32),
                              const SizedBox(width: 12),
                              Text(
                                'Plan Actuel',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Abonnement Mensuel',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bouteilles 20L × 4 par livraison',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Prochaine livraison : 28 déc. 2024',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Abonnement Plans
                    Text(
                      'Choisir votre plan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPlanOption('Hebdomadaire', '13 000 FCFA/semaine', '4 livraisons/mois'),
                    const SizedBox(height: 12),
                    _buildPlanOption('Bi-mensuel', '23 500 FCFA/2 semaines', '2 livraisons/mois'),
                    const SizedBox(height: 12),
                    _buildPlanOption('Mensuel', '41 700 FCFA/mois', '1 livraison/mois', isPopulaire: true),
                    const SizedBox(height: 24),

                    // Bottle Size Sélectionnerion
                    Text(
                      'Taille de la bouteille',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildBottleSizeOption('5L')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBottleSizeOption('10L')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBottleSizeOption('20L')),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quantity Sélectionneror
                    Text(
                      'Bouteilles par livraison',
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
                              if (_bottleQuantity > 1) {
                                setState(() => _bottleQuantity--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                          ),
                          Text(
                            '$_bottleQuantity Bouteilles',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _bottleQuantity++);
                            },
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Delivery Schedule
                    Text(
                      'Calendrier de livraison',
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
                      child: Column(
                        children: [
                          _buildScheduleRow('Jour préféré', 'Lundi'),
                          const Divider(height: 24),
                          _buildScheduleRow('Créneau horaire', '09:00 - 12:00'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _pauseSubscription,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Pause Abonnement',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateSubscription,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Mettre à jour Plan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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

  Widget _buildPlanOption(String title, String price, String frequency, {bool isPopulaire = false}) {
    final isSelected = _selectedPlan == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
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
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.check, size: 14, color: Colors.white))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                      if (isPopulaire) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Populaire',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    frequency,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottleSizeOption(String size) {
    final isSelected = _selectedBottleSize == size;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottleSize = size),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              FluentIcons.drop_24_regular,
              color: isSelected ? Colors.white : AppColors.textMain,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              size,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String label, String value) {
    return GestureDetector(
      onTap: () {
        // Show dialog to modify schedule
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Modification de $label - Fonctionnalité à venir',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
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
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
