import 'dart:convert';

import 'package:flutter/services.dart';

class Workflow {
  final Map<String, dynamic> _workflow;

  Workflow(this._workflow);

  /// Load the workflow from the JSON file
  static Future<Workflow> getWorkflow() async {
    final jsonString = await rootBundle.loadString('lib/api/workflow.json');
    final workflow = jsonDecode(jsonString);
    return Workflow(workflow);
  }

  /// Update the input image path in the workflow.
  /// Node 289 is the Image Load node.
  void updateInputImagePath(String path) {
    if (_workflow.containsKey('289') && _workflow['289'].containsKey('inputs')) {
      _workflow['289']['inputs']['image_path'] = path;
    }
  }

  /// Update the output image path in the workflow.
  /// Node 288 is the JWImageSaveToPath node.
  void updateOutputImagePath(String path) {
    if (_workflow.containsKey('288') && _workflow['288'].containsKey('inputs')) {
      _workflow['288']['inputs']['path'] = path;
    }
  }

  /// Update the noise seed in the workflow
  void updateNoiseSeed(int seed) {
    // Node 25 is the RandomNoise node
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  /// Get the workflow as a Map
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}