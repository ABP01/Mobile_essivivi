import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryProofCard extends StatelessWidget {
  final String? photoUrl;
  final String? signatureUrl;
  final DateTime? timestamp;
  final VoidCallback? onTapPhoto;
  final VoidCallback? onTapSignature;
  final VoidCallback? onSubmit;
  final String? actionLabel;

  const DeliveryProofCard({
    super.key,
    this.photoUrl,
    this.signatureUrl,
    this.timestamp,
    this.onTapPhoto,
    this.onTapSignature,
    this.onSubmit,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preuve de Livraison',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (timestamp != null)
                Text(
                  '${timestamp!.hour}:${timestamp!.minute}',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapPhoto,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoUrl == null
                        ? const Center(
                            child: Icon(Icons.camera_alt, color: Colors.grey),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: onTapSignature,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                      image: signatureUrl != null
                          ? DecorationImage(
                              image: NetworkImage(signatureUrl!),
                              fit: BoxFit.contain,
                            )
                          : null,
                    ),
                    child: signatureUrl == null
                        ? const Center(child: Text('Signature'))
                        : null,
                  ),
                ),
              ),
            ],
          ),
          if (onSubmit != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                child: Text(actionLabel ?? 'Soumettre la preuve'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
