import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/faceswap_api.dart';

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
    required FaceswapWorkflow workflow,
  }) async {
    try {
      // Send directly to ComfyUI's prompt endpoint
      final response = await http.post(
        Uri.parse('$_apiUrl/prompt'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': workflow.toMap(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if we have a prompt_id in the response
        if (responseData.containsKey('prompt_id')) {
          // Start polling for results
          return await _pollForResults(responseData['prompt_id']);
        }

        return responseData;
      } else {
        debugPrint('Error sending workflow: ${response.body}');
        throw Exception('Failed to send workflow: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception sending workflow: $e');
      rethrow;
    }
  }

  // Poll for results from ComfyUI
  Future<Map<String, dynamic>> _pollForResults(String promptId) async {
    // Maximum number of polling attempts
    const maxAttempts = 30;
    // Delay between polling attempts (in seconds)
    const pollDelay = 3;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        // Check the status of the prompt
        final response = await http.get(
          Uri.parse('$_apiUrl/history/$promptId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Check if processing is complete
          if (data.containsKey('outputs') &&
              data['outputs'] != null &&
              data['outputs'].isNotEmpty) {
            // Find the output image node (usually the last node)
            final outputNode = data['outputs'].keys.last;
            final images = data['outputs'][outputNode]['images'];

            if (images != null && images.isNotEmpty) {
              final imageName = images[0]['filename'];
              final imageUrl = '$_apiUrl/view?filename=$imageName';

              return {
                'status': 'success',
                'prompt_id': promptId,
                'image_url': imageUrl,
              };
            }
          }
        }

        // Wait before polling again
        await Future.delayed(const Duration(seconds: pollDelay));
      } on Exception catch (e) {
        debugPrint('Error polling for results: $e');
        // Continue polling despite errors
      }
    }

    // If we've reached here, polling has timed out
    return {
      'status': 'error',
      'message': 'Timed out waiting for results',
    };
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
