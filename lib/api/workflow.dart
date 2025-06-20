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
    // Node 46 is the Image Load node for the character image in swaplabonline.json.json
    if (_workflow.containsKey('46') && _workflow['46'].containsKey('inputs')) {
      _workflow['46']['inputs']['image_path'] = path.replaceAll(r'\', '/');
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
