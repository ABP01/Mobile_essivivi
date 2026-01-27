import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'mobile_money';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre méthode',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMethodTile(
              context,
              title: 'Mobile Money',
              subtitle: 'TMoney, Flooz',
              value: 'mobile_money',
              icon: Icons.phone_android,
            ),
            _buildMethodTile(
              context,
              title: 'Paiement à la livraison',
              subtitle: 'Espèces',
              value: 'cash',
              icon: Icons.payments_outlined,
            ),
            _buildMethodTile(
              context,
              title: 'Carte bancaire',
              subtitle: 'Visa / MasterCard',
              value: 'card',
              icon: Icons.credit_card,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paiement enregistré')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedMethod,
        onChanged: (v) => setState(() => _selectedMethod = v ?? value),
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: theme.primaryColor),
      ),
    );
  }
}
