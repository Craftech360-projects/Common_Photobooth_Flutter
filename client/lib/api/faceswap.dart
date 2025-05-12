import 'dart:convert';

import 'package:flutter/services.dart';

class FaceswapWorkflow {
  final Map<String, dynamic> _workflow;

  FaceswapWorkflow(this._workflow);

  /// Load the workflow from the JSON file
  static Future<FaceswapWorkflow> getWorkflow() async {
    // Fixed the path to use the correct JSON file name
    final jsonString = await rootBundle.loadString('lib/api/faceswap.json');
    final workflow = jsonDecode(jsonString);
    return FaceswapWorkflow(workflow);
  }

  /// Update the image URLs in the workflow
  void updateImageUrls({
    required String sourceImageUrl, // Character image URL
    required String targetImageUrl, // User's face image URL
  }) {
    // Node 27 is the target image (user's face)
    if (_workflow.containsKey('27') && _workflow['27'].containsKey('inputs')) {
      _workflow['27']['inputs']['direct_url'] = targetImageUrl;
    }

    // Node 29 is the source image (character)
    if (_workflow.containsKey('29') && _workflow['29'].containsKey('inputs')) {
      _workflow['29']['inputs']['direct_url'] = sourceImageUrl;
    }
  }

  /// Update refresh trigger in the workflow
  void updateRefreshTrigger(int value) {
    // Fixed the condition to check for node 28 instead of 27
    if (_workflow.containsKey('28') && _workflow['28'].containsKey('inputs')) {
      _workflow['28']['inputs']['refresh_trigger'] = value;
    }

    if (_workflow.containsKey('29') && _workflow['29'].containsKey('inputs')) {
      _workflow['29']['inputs']['refresh_trigger'] = value;
    }
  }

  /// Update refresh trigger in the workflow with unique_id
  void updateUniqueId(String uniqueId) {
    // Update the unique_id in the SupabaseTableWatcherNode nodes
    if (_workflow.containsKey('30') && _workflow['30'].containsKey('inputs')) {
      _workflow['30']['inputs']['unique_id'] = uniqueId;
    }

    if (_workflow.containsKey('31') && _workflow['31'].containsKey('inputs')) {
      _workflow['31']['inputs']['unique_id'] = uniqueId;
    }

    // Update the unique_id in the SupabaseImageUploader node
    if (_workflow.containsKey('28') && _workflow['28'].containsKey('inputs')) {
      _workflow['28']['inputs']['unique_id'] = ["31", 2];
    }
  }

  /// Convert the workflow to JSON
  String toJson() {
    return jsonEncode(_workflow);
  }

  /// Get the workflow as a Map
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
