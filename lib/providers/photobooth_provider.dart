import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart'
    as theme_provider;

class PhotoboothProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? gender;
  String? selectedCharacterId;
  String? characterImagePath;
  bool? isCharacterAsset;
  String? faceImagePath;
  String? swappedImageUrl;
  String? capturedImageUrl;
  DateTime? workflowSentTime;
  theme_provider.Theme? selectedTheme;
  String? accessories;

  String get selectedGender => gender ?? 'male';

  void setUserDetails(String name, String email) {
    this.name = name;
    this.email = email;

    notifyListeners();
  }

  void setGender(String gender) {
    this.gender = gender;
    notifyListeners();
  }

  void setTheme(theme_provider.Theme theme) {
    selectedTheme = theme;
    notifyListeners();
  }

  // NEW: Setter for accessories
  void setAccessories(String text) {
    accessories = text;
    notifyListeners();
  }

  void setCharacter(String id, String imagePath, bool isAsset) {
    selectedCharacterId = id;
    characterImagePath = imagePath;
    isCharacterAsset = isAsset;
    notifyListeners();
  }

  void setFaceImage(String path) {
    faceImagePath = path;
    notifyListeners();
  }

  void setSwappedImage(String url) {
    swappedImageUrl = url;
    notifyListeners();
  }

  void setCapturedImageUrl(String url) {
    capturedImageUrl = url;
    notifyListeners();
  }

  // Add method to set workflow sent time
  void setWorkflowSentTime(DateTime time) {
    workflowSentTime = time;
    notifyListeners();
  }

  // Add method to clear all user data
  void clearUserData() async {
    name = null;
    email = null;
    gender = null;
    selectedCharacterId = null;
    characterImagePath = null;
    isCharacterAsset = null;
    faceImagePath = null;
    swappedImageUrl = null;
    capturedImageUrl = null; // Clear this as well
    workflowSentTime = null; // Clear this as well
    selectedTheme = null;
    accessories = null; // NEW: Reset accessories
    notifyListeners();
  }
}
