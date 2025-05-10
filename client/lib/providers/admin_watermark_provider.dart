import 'package:flutter/material.dart';

class AdminWatermarkProvider extends ChangeNotifier {
  bool _showWatermark = true;

  bool get showWatermark => _showWatermark;

  void setShowWatermark(bool show) {
    _showWatermark = show;
    notifyListeners();
  }
}
