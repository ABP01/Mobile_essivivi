import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appwrite_auth_provider.dart';

/// 📱 Page de connexion par téléphone avec OTP
/// Exemple d'utilisation de l'authentification Appwrite
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion par téléphone')),
      body: Consumer<AppwriteAuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Logo ou image
                  const Icon(Icons.phone_android, size: 80, color: Colors.blue),

                  const SizedBox(height: 24),

                  // Titre
                  Text(
                    _isOtpSent ? 'Vérification du code' : 'Connexion',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Sous-titre
                  Text(
                    _isOtpSent
                        ? 'Entrez le code reçu par SMS'
                        : 'Entrez votre numéro de téléphone',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Champ de téléphone (si OTP pas encore envoyé)
                  if (!_isOtpSent) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        hintText: '90 12 34 56',
                        prefixText: '+228 ',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro';
                        }
                        if (value.length < 8) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Bouton Envoyer OTP
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _sendOTP(authProvider),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Envoyer le code',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],

                  // Champ OTP (si OTP envoyé)
                  if (_isOtpSent) ...[
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Code OTP',
                        hintText: '000000',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le code';
                        }
                        if (value.length != 6) {
                          return 'Le code doit contenir 6 chiffres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Bouton Vérifier OTP
                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _verifyOTP(authProvider),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Vérifier',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Bouton Renvoyer le code
                    TextButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _resendOTP(authProvider),
                      child: const Text('Renvoyer le code'),
                    ),

                    // Bouton Changer de numéro
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isOtpSent = false;
                          _otpController.clear();
                        });
                      },
                      child: const Text('Changer de numéro'),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Message d'erreur
                  if (authProvider.hasError) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bouton connexion par email
                  OutlinedButton.icon(
                    onPressed: () {
                      // Naviguer vers l'écran de connexion par email
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Connexion par email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lien inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Envoie le code OTP
  Future<void> _sendOTP(AppwriteAuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Format du numéro avec indicatif
    String phoneNumber = '+228${_phoneController.text.replaceAll(' ', '')}';

    final success = await authProvider.sendPhoneOTP(phoneNumber);

    if (success) {
      setState(() {
        _isOtpSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code envoyé par SMS'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Vérifie le code OTP
  Future<void> _verifyOTP(AppwriteAuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.verifyPhoneOTP(_otpController.text);

    if (success) {
      if (mounted) {
        // Connexion réussie ! Naviguer vers l'accueil
        Navigator.pushReplacementNamed(context, AppRoutes.clientHomeRedesign);
      }
    }
  }

  /// Renvoie le code OTP
  Future<void> _resendOTP(AppwriteAuthProvider authProvider) async {
    setState(() {
      _isOtpSent = false;
    });

    await _sendOTP(authProvider);
  }
}
