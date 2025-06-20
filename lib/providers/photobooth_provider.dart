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

  void setTheme(theme_provider.Theme? theme) {
    selectedTheme = theme;
    notifyListeners();
  }

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

  /// Clears the path to the last captured face image.
  void clearFaceImage() {
    faceImagePath = null;
    notifyListeners();
  }
  
  /// Clears the user details.
  void clearUserDetails() {
    name = null;
    email = null;
    notifyListeners();
  }
  
  /// Clears the selected gender.
  void clearGender() {
    gender = null;
    notifyListeners();
  }

  /// Clears the selected theme.
  void clearTheme() {
    selectedTheme = null;
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

  void setWorkflowSentTime(DateTime time) {
    workflowSentTime = time;
    notifyListeners();
  }

  void clearUserData() async {
    name = null;
    email = null;
    gender = null;
    selectedCharacterId = null;
    characterImagePath = null;
    isCharacterAsset = null;
    faceImagePath = null;
    swappedImageUrl = null;
    capturedImageUrl = null;
    workflowSentTime = null;
    selectedTheme = null;
    accessories = null;
    notifyListeners();
  }
}