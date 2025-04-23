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

  /// Update Supabase credentials in the workflow
  // void updateSupabaseCredentials({
  //   required String supabaseUrl,
  //   required String supabaseKey,
  // }) {
  //   // Update credentials for node 28
  //   if (_workflow.containsKey('28') && _workflow['28'].containsKey('inputs')) {
  //     _workflow['28']['inputs']['supabase_url'] = supabaseUrl;
  //     _workflow['28']['inputs']['supabase_key'] = supabaseKey;
  //   }

  //   // Update credentials for node 29
  //   if (_workflow.containsKey('29') && _workflow['29'].containsKey('inputs')) {
  //     _workflow['29']['inputs']['supabase_url'] = supabaseUrl;
  //     _workflow['29']['inputs']['supabase_key'] = supabaseKey;
  //   }

  //   // Update credentials for node 30
  //   if (_workflow.containsKey('30') && _workflow['30'].containsKey('inputs')) {
  //     _workflow['30']['inputs']['supabase_url'] = supabaseUrl;
  //     _workflow['30']['inputs']['supabase_key'] = supabaseKey;
  //   }
  // }

  /// Update refresh trigger in the workflow
  void updateRefreshTrigger(int value) {
    if (_workflow.containsKey('27') && _workflow['28'].containsKey('inputs')) {
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
