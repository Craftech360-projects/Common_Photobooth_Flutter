import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum to manage the main category selection state
enum MainCategory { none, aIArtistry, swaplab }

class CategoryProvider extends ChangeNotifier {
  MainCategory _selectedMainCategory = MainCategory.none;
  String? _selectedWorkflow;

  MainCategory get selectedMainCategory => _selectedMainCategory;
  String? get selectedWorkflow => _selectedWorkflow;

  // Called when the user taps on a main category like "AI Artistry"
  void selectMainCategory(MainCategory category) {
    _selectedMainCategory = category;
    notifyListeners();
  }

  // Called when a final selection is made (e.g., Swaplab or a sub-category)
  // This saves the choice for the LoadingScreen to use.
  Future<void> selectWorkflow(String workflowFileName) async {
    _selectedWorkflow = workflowFileName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_workflow', workflowFileName);
    debugPrint("Selected workflow saved: $workflowFileName");
    notifyListeners();
  }

  // Resets the selection when navigating back or finishing a flow
  void resetSelection() {
    _selectedMainCategory = MainCategory.none;
    _selectedWorkflow = null;
    notifyListeners();
  }
}
