import 'package:flutter/material.dart';

class PhotoboothProvider extends ChangeNotifier {
  String? name;
  String? email;
  String? gender;
  String? selectedCharacter;
  String? capturedImage;
  String? swappedImageUrl;

  void setUserDetails(String name, String email) {
    this.name = name;
    this.email = email;
    notifyListeners();
  }

  void setGender(String gender) {
    this.gender = gender;
    notifyListeners();
  }

  void setSelectedCharacter(String character) {
    selectedCharacter = character;
    notifyListeners();
  }

  void setCapturedImage(String imagePath) {
    capturedImage = imagePath;
    notifyListeners();
  }

  void setSwappedImage(String imageUrl) {
    swappedImageUrl = imageUrl;
    notifyListeners();
  }

  void reset() {
    name = null;
    email = null;
    gender = null;
    selectedCharacter = null;
    capturedImage = null;
    swappedImageUrl = null;
    notifyListeners();
  }
}
