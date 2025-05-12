import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFlow {
  defaultFlow,
  alternativeFlow,
}

class AppFlowProvider extends ChangeNotifier {
  AppFlow _currentFlow = AppFlow.defaultFlow;
  bool _isInitialized = false;

  AppFlow get currentFlow => _currentFlow;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serviceId = prefs.getString('authenticated_service_id');

      // Set the flow based on serviceId
      if (serviceId == 'LjCIQ5ONsqCHIHd6Rmyu') {
        _currentFlow = AppFlow.defaultFlow;
      } else if (serviceId != null) {
        _currentFlow = AppFlow.alternativeFlow;
      } else {
        // Default to default flow if no serviceId is found
        _currentFlow = AppFlow.defaultFlow;
      }

      _isInitialized = true;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint('Error initializing app flow: $e');
      _currentFlow = AppFlow.defaultFlow;
      _isInitialized = true;
      notifyListeners();
    }
  }

  void setFlow(AppFlow flow) {
    _currentFlow = flow;
    notifyListeners();
  }
}
