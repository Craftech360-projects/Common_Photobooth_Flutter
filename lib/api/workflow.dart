import 'dart:convert';

import 'package:flutter/services.dart';

class Workflow {
  final Map<String, dynamic> _workflow;

  Workflow(this._workflow);

  // CHANGED: This method now accepts a workflowFileName to load the correct JSON.
  static Future<Workflow> getWorkflow(String workflowFileName) async {
    // REASON: This allows us to dynamically load files like 'ghibli.json', 'pixar.json', etc.
    final jsonString = await rootBundle.loadString('lib/api/$workflowFileName');
    final workflow = jsonDecode(jsonString);
    return Workflow(workflow);
  }

  void updateInputImagePath(String path, {String nodeId = '289'}) {
    if (_workflow.containsKey(nodeId) &&
        _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['image_path'] = path.replaceAll(r'\', '/');
    }
  }

  void updateSwaplabCharacterImage(String path) {
    if (_workflow.containsKey('36') && _workflow['36'].containsKey('inputs')) {
      _workflow['36']['inputs']['image_path'] = path.replaceAll(r'\', '/');
    }
  }

  /// Update the output image path in the workflow.
  /// Node 288 is the JWImageSaveToPath node.
  void updateOutputImagePath(String path, {String nodeId = '288'}) {
    if (_workflow.containsKey(nodeId) &&
        _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['path'] = path.replaceAll(r'\', '/');
    }
  }

  /// Update the noise seed in the workflow
  void updateNoiseSeed(int seed) {
    // Node 25 is the RandomNoise node
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  /// NEW: Updates the prompt for the packaging workflow with gender and accessories.
  void updatePackagingPrompt(String gender, String accessories) {
    if (_workflow.containsKey('270') &&
        _workflow['270'].containsKey('inputs')) {
      // Construct the new prompt
      final String newPrompt =
          "TRAINBOX, Create an artistic image of a fashion action figure styled like a doll in plastic packaging. The packaging should be sleek and modern. The central figure is a stylish $gender. To the right of the figure, neatly arranged in separate compartments within the packaging, include the following accessories:\n$accessories\n\n";

      // Update the prompt text in the workflow
      _workflow['270']['inputs']['text'] = newPrompt;
    }
  }

  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
