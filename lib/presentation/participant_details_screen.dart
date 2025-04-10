import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_settings_provider.dart';
import 'package:photobooth_flutter/providers/app_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  const ParticipantDetailsScreen({super.key});

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final List<int> _secretPattern = [];
  final List<int> _correctPattern = [1, 2];
  DateTime? _lastTapTime;

  // FOR NAVIGATING TO ADMIN SCREEN
  void _handleSecretTap(int position) {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 5) {
      _secretPattern.clear();
    }
    _lastTapTime = now;

    _secretPattern.add(position);
    if (_secretPattern.length == _correctPattern.length) {
      bool isCorrect = true;
      for (int i = 0; i < _correctPattern.length; i++) {
        if (_secretPattern[i] != _correctPattern[i]) {
          isCorrect = false;
          break;
        }
      }
      if (isCorrect) {
        Navigator.pushNamed(context, AppRoutes.adminScreen);
      }
      _secretPattern.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminSettings = context.watch<AdminSettingsProvider>();

    return Scaffold(
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: adminSettings.backgroundImage != null
                  ? (adminSettings.isAssetImage
                          ? AssetImage(adminSettings.backgroundImage!)
                          : FileImage(File(adminSettings.backgroundImage!)))
                      as ImageProvider
                  : const AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...adminSettings.formFields.map((field) => Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: TextFormField(
                              // CONTROLLER IS MISSING
                              style: TextStyle(
                                color: field.textColor,
                              ),
                              decoration: InputDecoration(
                                hintText: field.hintText,
                                filled: true,
                                fillColor: field.fillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    adminSettings.borderRadius,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (field.isRequired &&
                                    (value?.isEmpty ?? true)) {
                                  return 'Please enter ${field.label.toLowerCase()}';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: adminSettings.fieldSpacing),
                        ],
                      )),
                  SizedBox(height: adminSettings.buttonSpacing),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<PhotoboothProvider>().setUserDetails(
                              _nameController.text,
                              _emailController.text,
                            );
                        Navigator.pushNamed(context, AppRoutes.genderSelection);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldenYellow,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      side: const BorderSide(
                        color: AppColors.white,
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          adminSettings.borderRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      adminSettings.submitButtonText,
                      style: adminSettings.buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _handleSecretTap(1),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => _handleSecretTap(2),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.transparent,
            ),
          ),
        )
      ]),
    );
  }
}
