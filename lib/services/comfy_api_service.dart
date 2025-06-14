import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/workflow.dart';

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

  // Send workflow for online mode (Supabase)
  Future<Map<String, dynamic>> sendOnlineWorkflow(int seed,
      {required String uniqueId}) async {
    try {
      final workflow = await Workflow.getWorkflow();

      // CORRECT: Update the workflow with the unique_id for the watcher node.
      workflow.updateSupabaseWatcherNode(uniqueId);

      // CORRECT: Update the noise seed.
      workflow.updateNoiseSeed(seed);

      debugPrint('======= SENDING ONLINE WORKFLOW =======');
      final workflowJson =
          const JsonEncoder.withIndent('  ').convert(workflow.toMap());
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint('=======================================');

      return await _postWorkflow(workflow.toMap());
    } catch (e) {
      debugPrint('Exception sending online workflow: $e');
      rethrow;
    }
  }

  // // Send workflow in offline mode
  // Future<Map<String, dynamic>> sendOfflineWorkflow({
  //   required String faceImagePath,
  //   required String outputPathPrefix,
  //   required int seed,
  // }) async {
  //   try {
  //     final workflow = await Workflow.getWorkflow();

  //     // --- Input Path Processing ---
  //     // Get the filename and its immediate parent directory.
  //     final inputFileName = path.basename(faceImagePath);
  //     final inputDirectoryName = path.basename(path.dirname(faceImagePath));
  //     // Create the relative path and ensure it uses forward slashes.
  //     final relativeInputPath =
  //         path.join(inputDirectoryName, inputFileName).replaceAll('\\', '/');

  //     workflow.updateInputImagePath(relativeInputPath);
  //     workflow.updateNoiseSeed(seed);

  //     // --- Output Path Processing ---
  //     // Get the filename prefix and its immediate parent directory.
  //     final outputPrefixBase = path.basename(outputPathPrefix);
  //     final outputDirectoryName = path.basename(path.dirname(outputPathPrefix));
  //     // Create the final output filename.
  //     final outputFileName = '$outputPrefixBase$seed.png';
  //     // Create the relative path and ensure it uses forward slashes.
  //     final relativeOutputPath =
  //         path.join(outputDirectoryName, outputFileName).replaceAll('\\', '/');

  //     workflow.updateOutputImagePath(relativeOutputPath);

  //     debugPrint('======= SENDING OFFLINE WORKFLOW ======');
  //     debugPrint('Relative Input Path: $relativeInputPath');
  //     debugPrint('Relative Output Path: $relativeOutputPath');
  //     final workflowJson =
  //         const JsonEncoder.withIndent('  ').convert(workflow.toMap());
  //     debugPrint('Workflow JSON: $workflowJson');
  //     debugPrint('========================================');

  //     final response = await _postWorkflow(workflow.toMap());
  //     response['outputPathPrefix'] = outputPathPrefix; // For polling logic
  //     return response;
  //   } catch (e) {
  //     debugPrint('Exception sending offline workflow: $e');
  //     rethrow;
  //   }
  // }
}
