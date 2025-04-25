import 'dart:convert';
import 'dart:math'; // Add this import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/ghibli_api.dart';

class ComfyApiService {
  static ComfyApiService? _instance;
  final String _apiUrl;

  // Private constructor
  ComfyApiService._({required String apiUrl}) : _apiUrl = apiUrl;

  // Singleton instance
  static ComfyApiService get instance {
    if (_instance == null) {
      throw Exception('ComfyApiService not initialized');
    }
    return _instance!;
  }

  // Initialize the service
  static Future<void> initialize({required String apiUrl}) async {
    _instance = ComfyApiService._(apiUrl: apiUrl);
  }

  // Check if the service is initialized
  static bool get isInitialized => _instance != null;

  // Send workflow directly to ComfyUI
  Future<Map<String, dynamic>> sendWorkflow({
    GhibliWorkflow? ghibliWorkflow,
  }) async {
    try {
      Map<String, dynamic>? workflow;

      if (ghibliWorkflow != null) {
        // Generate a random 5-digit number (10000-99999)
        final random = Random();
        final refreshTrigger = 10000 + random.nextInt(90000);
        ghibliWorkflow
            .updateRefreshTrigger(refreshTrigger); // Update the trigger

        workflow = ghibliWorkflow.toMap();
      }

      if (workflow == null) {
        throw Exception('No workflow provided');
      }

      // Record the time before sending the workflow
      final sentTime = DateTime.now();

      final response = await http.post(
        Uri.parse('$_apiUrl/prompt'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': workflow, // Send the updated workflow
        }),
      );

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': 'Workflow sent successfully',
          'sentTime': sentTime
              .toIso8601String(), // Include the sent time in the response
        };
      } else {
        debugPrint('Error sending workflow: ${response.body}');
        throw Exception('Failed to send workflow: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception sending workflow: $e');
      rethrow;
    }
  }

  // Check backend health
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/health'));
      return response.statusCode == 200;
    } on Exception catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }
}
