import 'dart:convert';

import 'package:flutter/services.dart';

class Workflow {
  final Map<String, dynamic> _workflow;

  Workflow(this._workflow);

  static Future<Workflow> getWorkflow(String workflowFileName) async {
    final jsonString = await rootBundle.loadString('lib/api/$workflowFileName');
    final workflow = jsonDecode(jsonString);
    return Workflow(workflow);
  }

  void updateSupabaseWatcherNode(String uniqueId, {required String nodeId}) {
    if (_workflow.containsKey(nodeId) &&
        _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['unique_id'] = uniqueId;
    }
  }

  void updateSwaplabCharacterImage(String path) {
    // Node 46 is the Image Load node for the character image in swaplabonline.json
    if (_workflow.containsKey('46') && _workflow['46'].containsKey('inputs')) {
      _workflow['46']['inputs']['image_path'] = path.replaceAll(r'\', '/');
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

  void updateNoiseSeed(int seed) {
    // This node ID seems consistent across the provided workflows.
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
