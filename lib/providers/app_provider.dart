import 'package:flutter/material.dart';

class PhotoboothProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? gender;
  String? selectedCharacterId;
  String? characterImagePath;
  bool? isCharacterAsset;
  String? faceImagePath;
  String? swappedImageUrl;

  String get selectedGender => gender ?? 'male'; // Default to male if not set

  void setUserDetails(String name, String email) {
    this.name = name;
    this.email = email;
    notifyListeners();
  }

  void setGender(String gender) {
    this.gender = gender;
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
    notifyListeners();
  }
}
