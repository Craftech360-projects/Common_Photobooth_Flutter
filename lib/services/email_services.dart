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

    if (serviceId == null || templateId == null || publicKey == null) {
      debugPrint('EmailJS credentials are not set in the admin settings.');
      return;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'public_key': publicKey,
          'private_key': privateKey,
          'template_params': {
            'to_email': toEmail,
            'image_url': imageUrl,
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully!');
      } else {
        debugPrint('Failed to send email: ${response.body}');
      }
    } on Exception catch (e) {
      debugPrint('Error sending email: $e');
    }
  }
}