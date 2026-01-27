import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AgentAvailabilityScreen extends StatefulWidget {
  const AgentAvailabilityScreen({super.key});

  @override
  State<AgentAvailabilityScreen> createState() =>
      _AgentAvailabilityScreenState();
}

class _AgentAvailabilityScreenState extends State<AgentAvailabilityScreen> {
  bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Disponibilité'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    color: _isOnline ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isOnline
                          ? 'Vous êtes disponible'
                          : 'Vous êtes hors ligne',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: (v) => setState(() => _isOnline = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Passez hors ligne si vous ne souhaitez plus recevoir de missions.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
