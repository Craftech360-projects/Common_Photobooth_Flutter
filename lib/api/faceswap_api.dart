import 'dart:convert';

import 'package:flutter/services.dart';

class FaceswapWorkflow {
  final Map<String, dynamic> _workflow;

  FaceswapWorkflow(this._workflow);

  /// Load the workflow from the JSON file
  static Future<FaceswapWorkflow> getWorkflow() async {
    final jsonString = await rootBundle.loadString('lib/api/faceswap_api.json');
    final workflow = jsonDecode(jsonString);
    return FaceswapWorkflow(workflow);
  }

  /// Update the image URLs in the workflow
  void updateImageUrls({
    required String sourceImageUrl,
    required String targetImageUrl,
  }) {
    // Update the Supabase URLs in the workflow
    // Node 28 is the source image (character)
    if (_workflow.containsKey('28') && _workflow['28'].containsKey('inputs')) {
      _workflow['28']['inputs']['supabase_url'] = sourceImageUrl;
    }

    // Node 29 is the target image (user's face)
    if (_workflow.containsKey('29') && _workflow['29'].containsKey('inputs')) {
      _workflow['29']['inputs']['supabase_url'] = targetImageUrl;
    }
  }

  /// Update refresh trigger in the workflow
  void updateRefreshTrigger(int value) {
    if (_workflow.containsKey('28') && _workflow['28'].containsKey('inputs')) {
      _workflow['28']['inputs']['refresh_trigger'] = value;
    }

    if (_workflow.containsKey('29') && _workflow['29'].containsKey('inputs')) {
      _workflow['29']['inputs']['refresh_trigger'] = value;
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
