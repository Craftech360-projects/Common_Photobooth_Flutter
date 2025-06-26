Global Settings
* Change App Font.

Gender Screen
* Btn Padding is not working
* Btn Border is not working.

Character screen
* If character length is 3 can I toggle the Use Carousel View switch
* Character Border is not working.
* 2 x 2 row: 2nd row selection has a problem.

Capture Screen
* Properly dispose camera ⚠️

Loading Screen
* Ensure the Asset loads every time.
* Add a fallback loader.

Output Screen
* Title Margins, FW, LH, Txt Align
* Image Margins and Padding




// ... other imports
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photobooth_flutter/services/local_storage_service.dart';
import 'package:path/path.dart' as path;

// ...

class _LoadingScreenState extends State<LoadingScreen> {
  // ... (existing properties and methods)

  Future<void> _processImage() async {
    // ... (existing code to get providers, imageFile, etc.)

    // ADDED: Logic to select the correct workflow file based on mode
    final prefs = await SharedPreferences.getInstance();
    String? baseWorkflowFileName = prefs.getString('selected_workflow');

    if (baseWorkflowFileName == null) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: No workflow selected. Please re-authenticate.';
      });
      return;
    }

    // Append '_offline' to the filename if in offline mode
    // e.g., 'pixar.json' becomes 'pixar_offline.json'
    final String finalWorkflowFileName = globalSettings.isOfflineMode
        ? baseWorkflowFileName.replaceAll('.json', '_offline.json')
        : baseWorkflowFileName;

    debugPrint("Final workflow file to be used: $finalWorkflowFileName");


    // Check if we're in offline mode
    if (globalSettings.isOfflineMode) {
      await _processOfflineMode(imageFile, provider, globalSettings, seed, finalWorkflowFileName);
    } else {
      await _processOnlineMode(imageFile, provider, globalSettings, name, email, gender, seed, finalWorkflowFileName);
    }
    // ...
  }

  // MODIFIED: Pass the workflow file name to the offline method
  Future<void> _processOfflineMode(
      File imageFile,
      PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings,
      int seed,
      String workflowFileName // ADDED
    ) async {
    // ... (code to initialize LocalStorageService)

    // Send offline workflow to ComfyAPI
    if (ComfyApiService.isInitialized) {
      try {
        // ... (logging)
        final response = await ComfyApiService.instance.sendOfflineWorkflow(
          faceImagePath: faceImagePath,
          outputPathPrefix: outputPathPrefix,
          seed: seed,
          workflowFileName: workflowFileName, // ADDED
        );
        // ... (rest of the polling logic is correct)
      }
      //...
    }
    //...
  }

  // MODIFIED: Pass the workflow file name to the online method
  Future<void> _processOnlineMode(
      File imageFile,
      PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings,
      String name,
      String email,
      String gender,
      int seed,
      String workflowFileName // ADDED
    ) async {
        // ... (code to check supabase, upload image, get uniqueId)
        if (uniqueId != null) {
          if (ComfyApiService.isInitialized) {
            try {
              // ... (logging)
              final response =
                  await ComfyApiService.instance.sendOnlineWorkflow(
                seed,
                uniqueId: uniqueId,
                workflowFileName: workflowFileName, // MODIFIED
              );
              // ... (rest of the polling logic is correct)
            } 
            // ...
          }
        }
    }
}

Here is the complete code for comfy_api_service.dart with the offline method uncommented and updated to accept the workflowFileName.

File to Edit: lib/services/comfy_api_service.dart

Dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photobooth_flutter/api/workflow.dart';
import 'package:path/path.dart' as path;

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

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/health'));
      return response.statusCode == 200;
    } on Exception catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> sendOnlineWorkflow(
    int seed, {
    required String uniqueId,
    required String workflowFileName,
  }) async {
    try {
      final workflow = await Workflow.getWorkflow(workflowFileName);
      
      // This assumes the online workflow uses a SupabaseTableWatcherNode
      // You need to create a method for this in your workflow.dart file if it's not there
      // workflow.updateSupabaseWatcherNode(uniqueId);

      workflow.updateNoiseSeed(seed);

      debugPrint(
          '======= SENDING ONLINE WORKFLOW ($workflowFileName) =======');
      final workflowJson =
          const JsonEncoder.withIndent('  ').convert(workflow.toMap());
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint(
          '===========================================================');

      return await _postWorkflow(workflow.toMap());
    } catch (e) {
      debugPrint('Exception sending online workflow: $e');
      rethrow;
    }
  }

  // UNCOMMENTED AND UPDATED
  Future<Map<String, dynamic>> sendOfflineWorkflow({
    required String faceImagePath,
    required String outputPathPrefix,
    required int seed,
    required String workflowFileName,
  }) async {
    try {
      final workflow = await Workflow.getWorkflow(workflowFileName);

      // --- Input Path Processing ---
      final inputFileName = path.basename(faceImagePath);
      final inputDirectoryName = path.basename(path.dirname(faceImagePath));
      final relativeInputPath =
          path.join(inputDirectoryName, inputFileName).replaceAll('\\', '/');

      workflow.updateInputImagePath(relativeInputPath);
      workflow.updateNoiseSeed(seed);

      // --- Output Path Processing ---
      final outputPrefixBase = path.basename(outputPathPrefix);
      final outputDirectoryName = path.basename(path.dirname(outputPathPrefix));
      final outputFileName = '$outputPrefixBase.png';
      final relativeOutputPath =
          path.join(outputDirectoryName, outputFileName).replaceAll('\\', '/');
      
      workflow.updateOutputImagePath(relativeOutputPath);

      debugPrint('======= SENDING OFFLINE WORKFLOW ($workflowFileName) ======');
      debugPrint('Relative Input Path: $relativeInputPath');
      debugPrint('Relative Output Path: $relativeOutputPath');
      final workflowJson =
          const JsonEncoder.withIndent('  ').convert(workflow.toMap());
      debugPrint('Workflow JSON: $workflowJson');
      debugPrint('========================================');

      final response = await _postWorkflow(workflow.toMap());
      response['outputPathPrefix'] = outputPrefixBase;
      return response;
    } catch (e) {
      debugPrint('Exception sending offline workflow: $e');
      rethrow;
    }
  }
}