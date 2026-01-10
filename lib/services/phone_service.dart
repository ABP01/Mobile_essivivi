import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  /// Appeler un numéro de téléphone
  static Future<void> makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw Exception('Impossible d\'appeler le numéro $phoneNumber');
    }
  }

  /// Envoyer un SMS
  static Future<void> sendSMS(String phoneNumber, {String? message}) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: message != null ? {'body': message} : null,
    );
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception('Impossible d\'envoyer un SMS au numéro $phoneNumber');
    }
  }

  /// Ouvrir WhatsApp
  static Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    // Format: https://wa.me/22890123456?text=Hello
    final String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$formattedNumber${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossible d\'ouvrir WhatsApp');
    }
  }
}
