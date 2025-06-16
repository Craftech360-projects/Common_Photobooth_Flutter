import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ComfyApiService {
  static ComfyApiService? _instance;
  final String _apiUrl;

  ComfyApiService._({required String apiUrl}) : _apiUrl = apiUrl;

  static ComfyApiService get instance {
    if (_instance == null) {
      throw Exception('ComfyApiService not initialized');
    }
    return _instance!;
  }

  static Future<void> initialize({required String apiUrl}) async {
    _instance = ComfyApiService._(apiUrl: apiUrl);
  }

  static bool get isInitialized => _instance != null;

  // Generic method to post a workflow to the ComfyUI API
  Future<Map<String, dynamic>> _postWorkflow(
      Map<String, dynamic> workflow) async {
    final sentTime = DateTime.now();
    final response = await http.post(
      Uri.parse('$_apiUrl/prompt'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': workflow,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'status': 'success',
        'message': 'Workflow sent successfully',
        'sentTime': sentTime.toIso8601String(),
      };
    } else {
      debugPrint('Error sending workflow: ${response.body}');
      throw Exception('Failed to send workflow: ${response.statusCode}');
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

  // Send workflow in offline mode
  Future<Map<String, dynamic>> sendOfflineWorkflow(
      {required Map<String, dynamic> workflow}) async {
    try {
      debugPrint('======= SENDING OFFLINE WORKFLOW ======');
      final workflowJson = const JsonEncoder.withIndent('  ').convert(workflow);
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint('========================================');

      final response = await _postWorkflow(workflow);
      return response;
    } catch (e) {
      debugPrint('Exception sending offline workflow: $e');
      rethrow;
    }
  }
}
