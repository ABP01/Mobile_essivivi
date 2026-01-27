import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatSupportSheet extends StatelessWidget {
  const ChatSupportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Besoin d\'aide ?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),
            title: const Text('Support WhatsApp'),
            subtitle: const Text('Réponse instantanée'),
            onTap: () {
               launchUrl(Uri.parse('https://wa.me/22890000000'));
            },
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
           ListTile(
            leading: const Icon(Icons.phone, color: Colors.blue, size: 30),
            title: const Text('Appeler le service client'),
            onTap: () {
               launchUrl(Uri.parse('tel:+22890000000'));
            },
             shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
