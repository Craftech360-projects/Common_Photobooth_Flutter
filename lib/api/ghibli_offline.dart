import 'dart:convert';

import 'package:flutter/services.dart';

class GhibliOfflineWorkflow {
  final Map<String, dynamic> _workflow;

  GhibliOfflineWorkflow(this._workflow);

  /// Load the workflow from the JSON file
  static Future<GhibliOfflineWorkflow> getWorkflow() async {
    final jsonString =
        await rootBundle.loadString('lib/api/ghibli_offline.json');
    final workflow = jsonDecode(jsonString);
    return GhibliOfflineWorkflow(workflow);
  }

  /// Update the face image path in the workflow for offline mode
  void updateFaceImagePath(String imagePath) {
    // Node 289 is the Image Load node that loads the face image
    if (_workflow.containsKey('289') &&
        _workflow['289'].containsKey('inputs')) {
      // Update the image_path to use the provided path
      _workflow['289']['inputs']['image_path'] = imagePath;
    } else {
    }
  }

  /// Update the output path in the workflow for offline mode
  void updateOutputPath(String outputPath) {
    // Node 288 is the JWImageSaveToPath node that saves the output image
    if (_workflow.containsKey('288') &&
        _workflow['288'].containsKey('inputs')) {
      // Update the path to use the provided output path
      _workflow['288']['inputs']['path'] = outputPath;
    } else {
    }
  }

  /// Update the noise seed in the workflow
  void updateNoiseSeed(int seed) {
    // Node 25 is the RandomNoise node
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    } else {
    }
  }

  /// Get the workflow as a Map
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
