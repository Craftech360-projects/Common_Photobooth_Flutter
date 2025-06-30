import 'dart:convert'; // Import for utf8 decoding
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestIdController = TextEditingController();
  final _authCodeController = TextEditingController();
  bool _showLicenseInput = false;
  String? _licenseContent;
  String? _licenseFileName;

  @override
  void dispose() {
    _requestIdController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success;
      if (_showLicenseInput) {
        if (_licenseContent == null) {
          authProvider.setError('Please upload the license key!');
          return;
        }
        success = await authProvider.verifyLicense(_licenseContent!);
      } else {
        success = await authProvider.verifyAuthCode(
          requestId: _requestIdController.text.trim(),
          authCode: _authCodeController.text.trim(),
        );
      }

      if (success && mounted) {
        await Navigator.of(context)
            .pushReplacementNamed(AppRoutes.welcomeScreen);
      }
    }
  }

  // UPDATED: This function is now web-compatible
  Future<void> _pickLicenseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: ['.lic'],
        withData: kIsWeb, // Only get bytes on the web
      );

      if (result != null) {
        String content;
        // Check if we are on the web or mobile
        if (kIsWeb) {
          // Web: Read from bytes
          content = utf8.decode(result.files.single.bytes!);
        } else {
          // Mobile: Read from the file path
          final path = result.files.single.path!;
          final file = File(path);
          content = await file.readAsString();
        }

        setState(() {
          _licenseContent = content;
          _licenseFileName = result.files.single.name;
        });
      } else {
        // User canceled the picker
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setError('No license file was selected.');
      }
    } on Exception catch (e) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setError('Error reading license key: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.white),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminScreen);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGradientStart,
              AppColors.primaryGradientEnd
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: size.width * 0.9,
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: Constants.br16,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.goldenYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  Constants.h24,
                  const Text(
                    'Authentication Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Constants.h8,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showLicenseInput = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: !_showLicenseInput
                              ? AppColors.goldenYellow
                              : Colors.grey,
                        ),
                        child: const Text('Auth Code'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showLicenseInput = true;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _showLicenseInput
                              ? AppColors.goldenYellow
                              : AppColors.grey,
                        ),
                        child: const Text('License Key'),
                      ),
                    ],
                  ),
                  Constants.h16,
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_showLicenseInput) ...[
                          TextFormField(
                            controller: _requestIdController,
                            decoration: InputDecoration(
                              labelText: 'Request ID',
                              border: OutlineInputBorder(
                                borderRadius: Constants.br8,
                              ),
                              prefixIcon: const Icon(Icons.event),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Request ID';
                              }
                              return null;
                            },
                            enabled: !authProvider.isLoading,
                          ),
                          Constants.h16,
                          TextFormField(
                            controller: _authCodeController,
                            decoration: InputDecoration(
                              labelText: 'Authentication Code',
                              border: OutlineInputBorder(
                                borderRadius: Constants.br8,
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Authentication Code';
                              }
                              if (value.length != 6) {
                                return 'Authentication Code must be 6 digits';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            enabled: !authProvider.isLoading,
                          ),
                        ] else ...[
                          Column(
                            children: [
                              if (_licenseFileName != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Selected key: $_licenseFileName',
                                    style: const TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _pickLicenseFile,
                                      icon: const Icon(Icons.file_upload),
                                      label: const Text('Upload License Key'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.blueGreyDark,
                                        foregroundColor: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                        if (authProvider.error != null) ...[
                          Constants.h16,
                          Text(
                            authProvider.error!,
                            style: const TextStyle(
                              color: AppColors.red,
                            ),
                          ),
                        ],
                        Constants.h24,
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldenYellow,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: Constants.br8,
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _showLicenseInput ? 'VERIFY KEY' : 'VERIFY',
                                    style: const TextStyle(
                                      color: AppColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        Constants.h8,
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Checkout application from here: ",
                                style: TextStyle(color: AppColors.black),
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.welcomeScreen);
                                  },
                                  child: const Text(
                                    "Click Here",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
