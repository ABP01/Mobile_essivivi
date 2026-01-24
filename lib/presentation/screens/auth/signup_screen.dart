import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/data/repositories/auth_repository.dart';
import 'package:essivi_mobile/data/models/user_models.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authRepo = AuthRepository();
  
  bool _isLoading = false;
  String _selectedRole = 'client';

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = SignupRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
      );

      await _authRepo.signup(request);

      if (!mounted) return;

      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! Veuillez vous connecter.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Une erreur est survenue';
      
      if (e is DioException) {
        if (e.response?.data != null && e.response!.data is Map) {
          final data = e.response!.data as Map;
          final List<String> messages = [];
          
          data.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((v) => v.toString()));
            } else {
              messages.add(value.toString());
            }
          });
          
          if (messages.isNotEmpty) {
            errorMessage = messages.join('\n');
          }
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Erreur de connexion au serveur. Vérifiez votre internet.';
        }
      } else {
        errorMessage = e.toString();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Common Input Decoration
    InputDecoration buildInputDecoration(String hint, IconData icon) {
      return InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                Text(
                  'Create Account',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Essivi delivery network',
                  style: textTheme.bodyLarge?.copyWith(
                    color: textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Username
                Text('Username', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _usernameController,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    decoration: buildInputDecoration('Enter your username', Icons.person_outline),
                    validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer un nom d\'utilisateur' : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email
                Text('Email', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _emailController,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    decoration: buildInputDecoration('Enter your email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez entrer un email';
                      if (!value.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Phone
                Text('Phone Number', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _phoneController,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    decoration: buildInputDecoration('Enter your phone number', Icons.phone_outlined),
                    validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer un numéro de téléphone' : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password
                Text('Password', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                    decoration: buildInputDecoration('Enter your password', Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                      if (value.length < 6) return 'Le mot de passe doit contenir au moins 6 caractères';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Role selection
                Text('Role', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: theme.cardTheme.color, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      dropdownColor: theme.cardTheme.color,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                      decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary)),
                      items: [
                        DropdownMenuItem(value: 'client', child: Text('Client', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))),
                        DropdownMenuItem(value: 'agent', child: Text('Agent', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface))),
                      ],
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    // Style inherited from AppTheme
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Sign Up',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: Text(
                        'Login',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
