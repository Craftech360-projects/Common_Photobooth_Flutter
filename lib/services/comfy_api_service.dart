import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/faceswap.dart';
import 'package:photobooth_flutter/api/ghibli.dart';
import 'package:photobooth_flutter/api/ghibli_offline.dart';
import 'package:photobooth_flutter/api/pixar.dart'; // Add import for Pixar workflow
import 'package:photobooth_flutter/api/snoopy.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';

class ComfyApiService {
  static ComfyApiService? _instance;
  final String _apiUrl;
  final BuildContext? _context;

  // Private constructor
  ComfyApiService._({required String apiUrl, BuildContext? context})
      : _apiUrl = apiUrl,
        _context = context;

  // Singleton instance
  static ComfyApiService get instance {
    if (_instance == null) {
      throw Exception('ComfyApiService not initialized');
    }
    return _instance!;
  }

  // Initialize the service
  static Future<void> initialize(
      {required String apiUrl, BuildContext? context}) async {
    _instance = ComfyApiService._(apiUrl: apiUrl, context: context);
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
        // Generate a unique ID instead of refresh trigger
        final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        ghibliWorkflow.updateUniqueId(
            uniqueId); // Use updateUniqueId instead of updateRefreshTrigger

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

  // Send workflow based on serviceId
  Future<Map<String, dynamic>> sendWorkflowByServiceId(
      String serviceId, String faceImageUrl, int seed,
      {BuildContext? context, String? uniqueId}) async {
    try {
      Map<String, dynamic>? workflow;
      final ctx = context ?? _context;

      // If no uniqueId is provided, this is an error as we need the same ID used in Supabase
      if (uniqueId == null) {
        throw Exception('No uniqueId provided for workflow');
      }

      // Select workflow based on serviceId
      switch (serviceId) {
        case 'LjCIQ5ONsqCHIHd6Rmyu':
          // Faceswap Workflow
          workflow = await _getFaceswapWorkflow(faceImageUrl, seed,
              uniqueId: uniqueId, context: ctx);
          break;
        case 'LxdfSxqisSz6upaGX2Ly':
          // Snoopy Workflow
          workflow =
              await _getSnoopyWorkflow(faceImageUrl, seed, uniqueId: uniqueId);
          break;
        case 's8I5m3JkBICqt2X1itzQ':
          // Pixar Workflow
          workflow =
              await _getPixarWorkflow(faceImageUrl, seed, uniqueId: uniqueId);
          break;
        case 'ufD3VgOLuZD14zk601in':
          // Disco Workflow
          workflow =
              await _getDiscoWorkflow(faceImageUrl, seed, uniqueId: uniqueId);
          break;
        case 'v0cHGA51YbXw7xteYLBM':

          ///=====> Default is Ghibli
          // Ghibli Workflow (default)
          final ghibliWorkflow = await GhibliWorkflow.getWorkflow();
          ghibliWorkflow.updateFaceImageUrl(faceImageUrl);
          ghibliWorkflow.updateNoiseSeed(seed);

          // Use the provided uniqueId from Supabase
          ghibliWorkflow.updateUniqueId(uniqueId);

          workflow = ghibliWorkflow.toMap();
          break;
        default:
          // Default to Ghibli workflow if serviceId is not recognized
          final ghibliWorkflow = await GhibliWorkflow.getWorkflow();
          ghibliWorkflow.updateFaceImageUrl(faceImageUrl);
          ghibliWorkflow.updateNoiseSeed(seed);

          // Use the provided uniqueId from Supabase
          ghibliWorkflow.updateUniqueId(uniqueId);

          workflow = ghibliWorkflow.toMap();
          break;
      }

      // Print workflow details for debugging
      debugPrint('======= WORKFLOW DETAILS =======');
      debugPrint('Service ID: $serviceId');
      debugPrint('Unique ID: $uniqueId');
      debugPrint('Face Image URL: $faceImageUrl');
      debugPrint('Seed: $seed');

      // Pretty print the workflow JSON for better readability
      final workflowJson = const JsonEncoder.withIndent('  ').convert(workflow);
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint('======= END WORKFLOW DETAILS =======');

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
    } catch (e) {
      debugPrint('Exception sending workflow: $e');
      rethrow;
    }
  }

  // Helper methods to get different workflows
  Future<Map<String, dynamic>> _getFaceswapWorkflow(
      String faceImageUrl, int seed,
      {BuildContext? context, required String uniqueId}) async {
    // Get the PhotoboothProvider to access the character image
    final ctx = context ?? _context;
    if (ctx == null) {
      throw Exception('No BuildContext provided for faceswap workflow');
    }

    final provider = Provider.of<PhotoboothProvider>(ctx, listen: false);

    // Check if we have a character image
    if (provider.characterImagePath == null) {
      throw Exception('No character image selected for faceswap');
    }

    // Get character image URL from Supabase
    final characterImageUrl = await SupabaseService.instance
        .uploadCharacterImage(File(provider.characterImagePath!),
            DateTime.now().millisecondsSinceEpoch.toString());

    if (characterImageUrl == null) {
      throw Exception('Failed to upload character image');
    }

    // Implement Faceswap workflow using the FaceswapWorkflow class
    final faceswapWorkflow = await FaceswapWorkflow.getWorkflow();

    // Use updateImageUrls instead of updateFaceImageUrl
    faceswapWorkflow.updateImageUrls(
      sourceImageUrl: characterImageUrl, // Character image
      targetImageUrl: faceImageUrl, // User's face image
    );

    // Use the provided uniqueId from Supabase
    faceswapWorkflow.updateUniqueId(uniqueId);

    return faceswapWorkflow.toMap();
  }

  Future<Map<String, dynamic>> _getSnoopyWorkflow(String faceImageUrl, int seed,
      {required String uniqueId}) async {
    // Implement Snoopy workflow using the SnoopyWorkflow class
    final snoopyWorkflow = await SnoopyWorkflow.getWorkflow();
    snoopyWorkflow.updateFaceImageUrl(faceImageUrl);

    // Use the provided uniqueId
    snoopyWorkflow.updateUniqueId(uniqueId);

    return snoopyWorkflow.toMap();
  }

  Future<Map<String, dynamic>> _getPixarWorkflow(String faceImageUrl, int seed,
      {required String uniqueId}) async {
    // Use PixarWorkflow instead of GhibliWorkflow
    final pixarWorkflow = await PixarWorkflow.getWorkflow();
    pixarWorkflow.updateFaceImageUrl(faceImageUrl);

    // Use the provided uniqueId
    pixarWorkflow.updateUniqueId(uniqueId);

    return pixarWorkflow.toMap();
  }

  Future<Map<String, dynamic>> _getDiscoWorkflow(String faceImageUrl, int seed,
      {required String uniqueId}) async {
    // For now, use GhibliWorkflow for Disco until a proper DiscoWorkflow is implemented
    // TODO: Create a proper DiscoWorkflow class
    final ghibliWorkflow = await GhibliWorkflow.getWorkflow();
    ghibliWorkflow.updateFaceImageUrl(faceImageUrl);

    // Use the provided uniqueId
    ghibliWorkflow.updateUniqueId(uniqueId);

    return ghibliWorkflow.toMap();
  }

// Send workflow in offline mode
  Future<Map<String, dynamic>> sendOfflineWorkflow({
    required String faceImagePath,
    required String outputPathPrefix,
    required String serviceId,
    int? seed,
  }) async {
    try {
      Map<String, dynamic>? workflow;
      seed ??= DateTime.now().millisecondsSinceEpoch;

      // Get the offline workflow based on serviceId
      switch (serviceId) {
        case 'v0cHGA51YbXw7xteYLBM':
        default:
          // Default to Ghibli offline workflow
          final ghibliOfflineWorkflow =
              await GhibliOfflineWorkflow.getWorkflow();
          ghibliOfflineWorkflow.updateFaceImagePath(faceImagePath);
          ghibliOfflineWorkflow.updateOutputPath(outputPathPrefix);
          ghibliOfflineWorkflow.updateNoiseSeed(seed);
          workflow = ghibliOfflineWorkflow.toMap();
          break;
      }

      // Print workflow details for debugging
      debugPrint('======= OFFLINE WORKFLOW DETAILS =======');
      debugPrint('Service ID: $serviceId');
      debugPrint('Face Image Path: $faceImagePath');
      debugPrint('Output Path Prefix: $outputPathPrefix');
      debugPrint('Seed: $seed');

      // Pretty print the workflow JSON for better readability
      final workflowJson = const JsonEncoder.withIndent('  ').convert(workflow);
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint('======= END OFFLINE WORKFLOW DETAILS =======');

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
          'message': 'Offline workflow sent successfully',
          'sentTime': sentTime.toIso8601String(),
          'outputPathPrefix': outputPathPrefix,
        };
      } else {
        debugPrint('Error sending offline workflow: ${response.body}');
        throw Exception(
            'Failed to send offline workflow: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception sending offline workflow: $e');
      rethrow;
    }
  }
}
