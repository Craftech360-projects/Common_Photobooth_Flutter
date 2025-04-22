import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/faceswap_api.dart';

class RunPodService {
  static final RunPodService instance = RunPodService._internal();
  
  factory RunPodService() {
    return instance;
  }
  
  RunPodService._internal();
  
  bool _isInitialized = false;
  String? _runpodApiUrl;
  String? _runpodApiKey;
  
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize({
    required String apiUrl,
    required String apiKey,
  }) async {
    _runpodApiUrl = apiUrl;
    _runpodApiKey = apiKey;
    _isInitialized = true;
    debugPrint('RunPod service initialized');
  }
  
  /// Sends a faceswap job to RunPod
  Future<String?> submitFaceswapJob({
    required String sourceImageUrl,
    required String targetImageUrl,
  }) async {
    if (!_isInitialized) {
      throw Exception('RunPod service not initialized');
    }
    
    try {
      // Get the workflow from the JSON file
      final workflow = await FaceswapWorkflow.getWorkflow();
      
      // Update the workflow with the correct image URLs
      workflow.updateImageUrls(
        sourceImageUrl: sourceImageUrl,
        targetImageUrl: targetImageUrl,
      );
      
      // Create the API request
      final response = await http.post(
        Uri.parse('$_runpodApiUrl/run'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_runpodApiKey',
        },
        body: jsonEncode({
          'input': {
            'prompt': workflow.toJson(),
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobId = data['id'];
        debugPrint('Faceswap job submitted with ID: $jobId');
        return jobId;
      } else {
        debugPrint('Failed to submit faceswap job: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error submitting faceswap job: $e');
      return null;
    }
  }
  
  /// Checks the status of a RunPod job
  Future<Map<String, dynamic>?> checkJobStatus(String jobId) async {
    if (!_isInitialized) {
      throw Exception('RunPod service not initialized');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_runpodApiUrl/status/$jobId'),
        headers: {
          'Authorization': 'Bearer $_runpodApiKey',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to check job status: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error checking job status: $e');
      return null;
    }
  }
  
  /// Gets the result of a completed RunPod job
  Future<String?> getJobResult(String jobId) async {
    if (!_isInitialized) {
      throw Exception('RunPod service not initialized');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_runpodApiUrl/output/$jobId'),
        headers: {
          'Authorization': 'Bearer $_runpodApiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The output structure depends on your ComfyUI workflow
        // Typically, it will contain a URL to the generated image
        final outputUrl = data['output']['image_url'];
        return outputUrl;
      } else {
        debugPrint('Failed to get job result: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting job result: $e');
      return null;
    }
  }
}