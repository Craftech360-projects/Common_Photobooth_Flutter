import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static Future<void> sendEmail({
    required String toEmail,
    required String imageUrl,
    required String? serviceId,
    required String? templateId,
    required String? publicKey,
    required String? privateKey,
  }) async {
    // NEW: Log the attempt before sending
    // debugPrint(
    //     'Attempting to send email via EmailJS to: $toEmail with template: $templateId');

    if (serviceId == null ||
        templateId == null ||
        publicKey == null ||
        privateKey == null) {
      debugPrint('EmailJS credentials are not set in the admin settings.');
      return;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final data = {
        'service_id': serviceId,
        'template_id': templateId,
        'user_id':
            publicKey, // Note: EmailJS v1.0 API uses 'user_id' for the Public Key
        'accessToken':
            privateKey, // Note: EmailJS v1.0 API uses 'accessToken' for the Private Key
        'template_params': {
          'to_email': toEmail,
          'image_url': imageUrl,
        },
      };

      // NEW: Log the exact payload being sent (excluding private key for security)
      final sanitizedData = Map.from(data)..remove('accessToken');
      // debugPrint('Sending payload: ${json.encode(sanitizedData)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // UPDATED: More detailed success log
        // debugPrint(
        //     'Email sent successfully to $toEmail. Response: ${response.body}');
      } else {
        // UPDATED: More detailed failure log
        debugPrint(
            'Failed to send email. Status Code: ${response.statusCode}. Response Body: ${response.body}');
      }
    } on Exception catch (e) {
      debugPrint('Error sending email: $e');
    }
  }
}
