import 'package:essivi_mobile/presentation/widgets/inputs/custom_text_field.dart';
import 'package:essivi_mobile/presentation/widgets/layout/custom_app_bar.dart';
import 'package:essivi_mobile/providers/client_provider.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(context, listen: false).loadClientData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Carnet d\'adresses',
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Consumer<ClientProvider>(
        builder: (context, provider, child) {
          final addresses = provider.savedAddresses;
          
          if (provider.isLoading) {
             return const Center(child: CircularProgressIndicator());
          }

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(FluentIcons.location_24_regular, size: 64, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text(
                     'Aucune adresse enregistrée',
                     style: GoogleFonts.poppins(color: Colors.grey[600]),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Dismissible(
                key: Key(address['address'] ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.removeAddress(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adresse supprimée')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FluentIcons.location_24_filled,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['name'] ?? 'Lieu',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              address['address'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (address['note'] != null && address['note']!.isNotEmpty)
                              Text(
                                address['note']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAddressBottomSheet(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(FluentIcons.add_24_filled, color: Colors.white),
      ),
    );
  }

  void _showAddAddressBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajouter une adresse',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: nameController,
              hintText: 'Nom (ex: Maison)',
              labelText: 'Nom du lieu',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: addressController,
              hintText: 'Adresse complète',
              labelText: 'Adresse',
              prefixIcon: const Icon(FluentIcons.location_24_regular),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: noteController,
              hintText: 'Instructions supp. (facultatif)',
              labelText: 'Note',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                    Provider.of<ClientProvider>(context, listen: false).addAddress({
                      'name': nameController.text,
                      'address': addressController.text,
                      'note': noteController.text,
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enregistrer',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
