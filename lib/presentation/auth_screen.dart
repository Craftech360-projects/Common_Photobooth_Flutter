import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final _eventIdController = TextEditingController();
  final _authCodeController = TextEditingController();
  bool _showLicenseInput = false;
  String? _licenseContent;
  String? _licenseFileName;

  @override
  void dispose() {
    _eventIdController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success;
      if (_showLicenseInput) {
        // Verify license certificate
        if (_licenseContent == null) {
          // Use the new setError method instead of direct assignment
          authProvider
              .setError('Please select a license file or enter license text');
          return;
        }
        success = await authProvider.verifyLicense(_licenseContent!);
      } else {
        // Verify with event ID and auth code
        success = await authProvider.verifyAuthCode(
          eventId: _eventIdController.text.trim(),
          authCode: _authCodeController.text.trim(),
        );
      }

      if (success && mounted) {
        await Navigator.of(context)
            .pushReplacementNamed(AppRoutes.welcomeScreen);
      }
    }
  }

  Future<void> _pickLicenseFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['lic', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        setState(() {
          _licenseContent = content;
          _licenseFileName = result.files.single.name;
        });
      }
    } on Exception catch (e) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Use the new setError method here too
      authProvider.setError('Error reading license file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
            ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.goldenYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Authentication Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Toggle between auth methods
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
                              : Colors.grey,
                        ),
                        child: const Text('License Certificate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_showLicenseInput) ...[
                          // Event ID field
                          TextFormField(
                            controller: _eventIdController,
                            decoration: InputDecoration(
                              labelText: 'Event ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.event),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Event ID';
                              }
                              return null;
                            },
                            enabled: !authProvider.isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Auth code field
                          TextFormField(
                            controller: _authCodeController,
                            decoration: InputDecoration(
                              labelText: 'Authentication Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
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
                          // License certificate input
                          Column(
                            children: [
                              if (_licenseFileName != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Selected file: $_licenseFileName',
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
                                      label: const Text('Select License File'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Paste License Certificate',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                onChanged: (value) {
                                  setState(() {
                                    _licenseContent = value;
                                  });
                                },
                                enabled: !authProvider.isLoading,
                              ),
                            ],
                          ),
                        ],
                        if (authProvider.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            authProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Satoshi',
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldenYellow,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _showLicenseInput
                                        ? 'VERIFY LICENSE'
                                        : 'VERIFY',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Satoshi',
                                    ),
                                  ),
                          ),
                        ),
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
