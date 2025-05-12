import 'dart:convert';

import 'package:flutter/services.dart';

class SnoopyWorkflow {
  final Map<String, dynamic> _workflow;

  SnoopyWorkflow(this._workflow);

  /// Load the workflow from the JSON file
  static Future<SnoopyWorkflow> getWorkflow() async {
    final jsonString = await rootBundle.loadString('lib/api/snoopy.json');
    final workflow = jsonDecode(jsonString);
    return SnoopyWorkflow(workflow);
  }

  /// Update the face image URL in the workflow
  void updateFaceImageUrl(String imageUrl) {
    // Node 283 is the SupabaseTableWatcherNode that loads the face image
    if (_workflow.containsKey('283') && _workflow['283'].containsKey('inputs')) {
      _workflow['283']['inputs']['unique_id'] = '';
    }
  }

  /// Update the noise seed in the workflow
  void updateNoiseSeed(int seed) {
    // Node 25 is the RandomNoise node
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  /// Update the unique ID in the workflow
  void updateUniqueId(String uniqueId) {
    // Update the unique_id in the SupabaseTableWatcherNode
    if (_workflow.containsKey('283') && _workflow['283'].containsKey('inputs')) {
      _workflow['283']['inputs']['unique_id'] = uniqueId;
    }
    
    // Update the unique_id in the SupabaseImageUploader node
    if (_workflow.containsKey('284') && _workflow['284'].containsKey('inputs')) {
      _workflow['284']['inputs']['unique_id'] = [
        "283",
        2
      ];
    }
  }

  /// Get the workflow as a Map
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}