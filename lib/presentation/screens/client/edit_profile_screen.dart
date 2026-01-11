import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';

import 'package:essivi_mobile/data/repositories/user_repository.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/user_models.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userRepo = UserRepository();
  final _authRepo = AuthRepository();
  
  final _nomPointVenteController = TextEditingController();
  final _nomProprietaireController = TextEditingController();
  final _adresseController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  CustomUser? _user;
  ClientProfile? _clientProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      _user = await _authRepo.getCurrentUser();
      if (_user != null) {
        final clients = await _userRepo.getClients();
        _clientProfile = clients.firstWhere((c) => c.userId == _user!.id);
        
        _nomPointVenteController.text = _clientProfile?.nomPointVente ?? '';
        _nomProprietaireController.text = _clientProfile?.nomProprietaire ?? '';
        _adresseController.text = _clientProfile?.adresse ?? '';
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clientProfile == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfile = ClientProfile(
        id: _clientProfile!.id,
        userId: _clientProfile!.userId,
        nomPointVente: _nomPointVenteController.text.trim(),
        nomProprietaire: _nomProprietaireController.text.trim(),
        adresse: _adresseController.text.trim(),
        gpsLat: _clientProfile!.gpsLat,
        gpsLng: _clientProfile!.gpsLng,
        solde: _clientProfile!.solde,
      );

      await _userRepo.updateClient(_clientProfile!.id, updatedProfile.toJson());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nomPointVenteController.dispose();
    _nomProprietaireController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Point de vente
                      TextFormField(
                        controller: _nomPointVenteController,
                        decoration: InputDecoration(
                          labelText: 'Nom du Point de Vente',
                          prefixIcon: const Icon(FluentIcons.building_24_regular),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du point de vente';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Proprietaire
                      TextFormField(
                        controller: _nomProprietaireController,
                        decoration: InputDecoration(
                          labelText: 'Nom du Propriétaire',
                          prefixIcon: const Icon(FluentIcons.person_24_regular),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom du propriétaire';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Adresse
                      TextFormField(
                        controller: _adresseController,
                        decoration: InputDecoration(
                          labelText: 'Adresse',
                          prefixIcon: const Icon(FluentIcons.location_24_regular),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer l\'adresse';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Save Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
