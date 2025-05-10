import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

class GhibliWorkflow {
  final Map<String, dynamic> _workflow;

  GhibliWorkflow(this._workflow);

  // Static method to load the workflow from the JSON file
  static Future<GhibliWorkflow> getWorkflow() async {
    // Load the workflow from the JSON file
    final String jsonString =
        await rootBundle.loadString('lib/api/ghibli.json');
    final Map<String, dynamic> workflow = json.decode(jsonString);
    return GhibliWorkflow(workflow);
  }

  // Update the face image URL in the workflow
  void updateFaceImageUrl({required String faceImageUrl}) {
    // Update node 289 which is the LoadImageFromUrlOrPath node
    if (_workflow.containsKey('289') &&
        _workflow['289'].containsKey('inputs') &&
        _workflow['289']['inputs'].containsKey('url_or_path')) {
      _workflow['289']['inputs']['url_or_path'] = faceImageUrl;
      log('Updated face image URL in workflow: $faceImageUrl');
    } else {
      log('Failed to update face image URL: Node 289 not found or has unexpected structure');
    }
  }

  // Update the noise seed for randomization
  void updateNoiseSeed(int seed) {
    // Update node 25 which is the RandomNoise node
    if (_workflow.containsKey('25') &&
        _workflow['25'].containsKey('inputs') &&
        _workflow['25']['inputs'].containsKey('noise_seed')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
      log('Updated noise seed in workflow: $seed');
    } else {
      log('Failed to update noise seed: Node 25 not found or has unexpected structure');
    }
  }

  // Update the refresh trigger for the workflow
  void updateRefreshTrigger(int trigger) {
    // This could be implemented if needed
    log('Updated refresh trigger in workflow: $trigger');
  }

  // Convert the workflow to a Map for sending to the API
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
