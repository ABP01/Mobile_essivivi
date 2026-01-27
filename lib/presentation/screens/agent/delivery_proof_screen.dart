import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';

class DeliveryProofScreen extends StatefulWidget {
  final String deliveryId;
  final String clientName;
  final String address;

  const DeliveryProofScreen({
    super.key,
    required this.deliveryId,
    required this.clientName,
    required this.address,
  });

  @override
  State<DeliveryProofScreen> createState() => _DeliveryProofScreenState();
}

class _DeliveryProofScreenState extends State<DeliveryProofScreen> {

  
  bool _photoTaken = false;
  bool _signatureCaptured = false;
  bool _gpsValidated = false;
  bool _isSubmitting = false;
  


  Future<void> _submitProof() async {
    setState(() => _isSubmitting = true);
    
    try {
      // In a real app, you would:
      // 1. Get actual GPS coordinates
      // 2. Convert photo to base64 or upload file
      // 3. Convert signature to base64
      
      // For now, simulate with mock data
      // final proofData = {
      //   'gps_lat': _currentLat ?? 6.1319,
      //   'gps_lng': _currentLng ?? 1.2223,
      //   'signature': 'base64_signature_data',
      //   'preuve_validee': true,
      // };
      
      // Extract delivery ID from widget.deliveryId (remove # if present)
      // final deliveryId = int.parse(widget.deliveryId.replaceAll('#', ''));
      
      // Submit to backend (you'll need to add this method to SalesRepository)
      // await _salesRepo.submitDeliveryProof(deliveryId, proofData);
      
      if (!mounted) return;
      
      _completeDelivery(context);
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    'Delivery Proof',
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
                    // Delivery Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.clientName,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(FluentIcons.location_24_regular, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.address,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: ${widget.deliveryId}',
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

                    // GPS Validation
                    Text(
                      'Location Verification',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        // In a real app, get actual GPS coordinates
                        setState(() {
                          _gpsValidated = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('GPS location validated', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _gpsValidated ? Colors.green.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _gpsValidated ? Colors.green : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _gpsValidated ? FluentIcons.checkmark_circle_24_filled : FluentIcons.location_24_regular,
                              color: _gpsValidated ? Colors.green : AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _gpsValidated ? 'Location Verified' : 'Verify Location',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  Text(
                                    _gpsValidated ? 'You are at the delivery location' : 'Tap to verify you are at the location',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Photo Proof
                    Text(
                      'Delivery Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() => _photoTaken = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Photo captured', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: _photoTaken ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _photoTaken ? Colors.blue : Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _photoTaken ? FluentIcons.checkmark_circle_24_filled : FluentIcons.camera_24_regular,
                                color: _photoTaken ? Colors.blue : AppColors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _photoTaken ? 'Photo Captured' : 'Tap to Take Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _photoTaken ? Colors.blue : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Signature
                    Text(
                      'Customer Signature',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() => _signatureCaptured = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Signature captured', style: GoogleFonts.poppins()),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: _signatureCaptured ? Colors.purple.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _signatureCaptured ? Colors.purple : Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _signatureCaptured ? FluentIcons.checkmark_circle_24_filled : FluentIcons.signature_24_regular,
                                color: _signatureCaptured ? Colors.purple : AppColors.textSecondary,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _signatureCaptured ? 'Signature Captured' : 'Tap to Capture Signature',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _signatureCaptured ? Colors.purple : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Complete Delivery Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_gpsValidated && _photoTaken && _signatureCaptured && !_isSubmitting)
                            ? _submitProof
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Complete Delivery',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  void _completeDelivery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.checkmark_circle_24_filled, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Delivery Completed!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All proof has been captured successfully.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
