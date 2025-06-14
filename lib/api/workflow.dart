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

  /// Update the Supabase watcher node with the unique ID of the database row.
  /// Node 283 is the SupabaseTableWatcherNode.
  void updateSupabaseWatcherNode(String uniqueId) {
    if (_workflow.containsKey('283') &&
        _workflow['283'].containsKey('inputs')) {
      _workflow['283']['inputs']['unique_id'] = uniqueId;
    }
  }

  /// Update the noise seed in the workflow
  /// Node 25 is the RandomNoise node.
  void updateNoiseSeed(int seed) {
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  /// Get the workflow as a Map
  Map<String, dynamic> toMap() {
    return _workflow;
  }
}
