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
  
  // Send workflow to backend
  Future<Map<String, dynamic>> sendWorkflow({
    required FaceswapWorkflow workflow,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/prompt'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: workflow.toJson(),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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