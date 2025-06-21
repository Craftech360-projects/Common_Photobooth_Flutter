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

  // For Online Workflows
  void updateSupabaseWatcherNode(String uniqueId, {required String nodeId}) {
    if (_workflow.containsKey(nodeId) &&
        _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['unique_id'] = uniqueId;
    }
  }

  // For Offline Workflows
  void updateInputImagePath(String path, {String nodeId = '289'}) {
     if (_workflow.containsKey(nodeId) && _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['image'] = path.replaceAll(r'\', '/');
    }
  }
  
  void updateOutputImagePath(String path, {String nodeId = '288'}) {
    if (_workflow.containsKey(nodeId) && _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['path'] = path.replaceAll(r'\', '/');
    }
  }

  // For Swaplab (Online & Offline)
  void updateSwaplabCharacterImage(String path) {
    if (_workflow.containsKey('46') && _workflow['46'].containsKey('inputs')) {
      _workflow['46']['inputs']['image_path'] = path.replaceAll(r'\', '/');
    }
  }
  
  // For Swaplab Offline (Input Face)
  void updateSwaplabInputFaceImage(String path, {String nodeId = '35'}) {
    if (_workflow.containsKey(nodeId) && _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['image_path'] = path.replaceAll(r'\', '/');
    }
  }
  
  // For Swaplab Offline (Output Path)
  void updateSwaplabOutputImagePath(String path, {String nodeId = '37'}) {
     if (_workflow.containsKey(nodeId) && _workflow[nodeId].containsKey('inputs')) {
      _workflow[nodeId]['inputs']['path'] = path.replaceAll(r'\', '/');
    }
  }


  // For Packaging Workflow
  void updatePackagingPrompt(String gender, String accessories) {
    if (_workflow.containsKey('270') &&
        _workflow['270'].containsKey('inputs')) {
      final String newPrompt =
          "TRAINBOX, Create an artistic image of a fashion action figure styled like a doll in plastic packaging. The packaging should be sleek and modern. The central figure is a stylish $gender. To the right of the figure, neatly arranged in separate compartments within the packaging, include the following accessories:\n$accessories\n\n";
      _workflow['270']['inputs']['text'] = newPrompt;
    }
  }
  
  // For all workflows
  void updateNoiseSeed(int seed) {
    if (_workflow.containsKey('25') && _workflow['25'].containsKey('inputs')) {
      _workflow['25']['inputs']['noise_seed'] = seed;
    }
  }

  Map<String, dynamic> toMap() => _workflow;
}