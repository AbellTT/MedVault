import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // IMPORTANT: You need to create a free account at https://www.emailjs.com/
  // and replace these placeholders with your actual keys.
  static const String _serviceId = 'service_smtrkhg';
  static const String _templateId = 'template_se42bns';
  static const String _publicKey = 'hzz7MKPjFBcP1uC6o';

  static Future<bool> sendOTP({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final expiryTime = DateTime.now().add(const Duration(minutes: 15));
      final formattedTime =
          "${expiryTime.hour.toString().padLeft(2, '0')}:${expiryTime.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'email': email,
            'otp_code': otp,
            'app_name': 'MedVault',
            'time': formattedTime,
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
