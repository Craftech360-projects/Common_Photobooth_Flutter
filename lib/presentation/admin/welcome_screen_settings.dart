import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/widgets/color_picker.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class WelcomeScreenSettings extends StatelessWidget {
  const WelcomeScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Screen Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Welcome Screen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: welcomeSettings.showWelcomeScreen,
                  onChanged: (value) {
                    welcomeSettings.setShowWelcomeScreen(value);
                    showSnackBar(
                        context,
                        value
                            ? 'Welcome screen enabled'
                            : 'Welcome screen disabled');
                  },
                ),
              ],
            ),
            const Divider(),
            if (welcomeSettings.showWelcomeScreen) ...[
              const SizedBox(height: 16),
              const Text(
                'Welcome Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: welcomeSettings.welcomeMessage,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter welcome message',
                ),
                maxLines: 3,
                onChanged: (value) => welcomeSettings.setWelcomeMessage(value),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome Screen Background',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                          dialogTitle: 'Select welcome screen background',
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          if (file.path != null) {
                            await welcomeSettings.setWelcomeScreenBackground(
                              file.path,
                              isAsset: false,
                            );
                            showSnackBar(
                                context, 'Welcome screen background updated');
                          }
                        }
                      } on Exception catch (e) {
                        debugPrint('Error picking file: $e');
                        showSnackBar(context, 'Error selecting file: $e');
                      }
                    },
                    child: const Text('Choose Background'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      welcomeSettings.setWelcomeScreenBackground(null);
                      showSnackBar(context, 'Using global background image');
                    },
                    child: const Text('Use Global Background'),
                  ),
                ],
              ),
              if (welcomeSettings.welcomeScreenBackground != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'Selected: ${welcomeSettings.welcomeScreenBackground}'),
                ),
              const SizedBox(height: 24),
              const Text(
                'Button Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Button Type Selection
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Text Button'),
                      value: false,
                      groupValue: welcomeSettings.useImageButton,
                      onChanged: (value) {
                        if (value != null) {
                          welcomeSettings.setUseImageButton(value);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Image Button'),
                      value: true,
                      groupValue: welcomeSettings.useImageButton,
                      onChanged: (value) {
                        if (value != null) {
                          welcomeSettings.setUseImageButton(value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Text Button Settings
              if (!welcomeSettings.useImageButton) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: welcomeSettings.welcomeButtonText,
                  decoration: const InputDecoration(
                    labelText: 'Button Text',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      welcomeSettings.setWelcomeButtonText(value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Button Color'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Select Button Color'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor:
                                          welcomeSettings.welcomeButtonColor,
                                      onColorChanged: (color) {
                                        welcomeSettings
                                            .setWelcomeButtonColor(color);
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: welcomeSettings.welcomeButtonColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Text Color'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Select Text Color'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: welcomeSettings
                                          .welcomeButtonTextColor,
                                      onColorChanged: (color) {
                                        welcomeSettings
                                            .setWelcomeButtonTextColor(color);
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: welcomeSettings.welcomeButtonTextColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Image Button Settings
              if (welcomeSettings.useImageButton) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                        allowMultiple: false,
                        dialogTitle: 'Select button image',
                      );

                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        if (file.path != null) {
                          await welcomeSettings.setButtonImage(
                            file.path,
                            isAsset: false,
                          );
                          showSnackBar(context, 'Button image updated');
                        }
                      }
                    } on Exception catch (e) {
                      debugPrint('Error picking file: $e');
                      showSnackBar(context, 'Error selecting file: $e');
                    }
                  },
                  child: const Text('Choose Button Image'),
                ),
                if (welcomeSettings.buttonImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Selected: ${welcomeSettings.buttonImagePath}'),
                  ),
              ],

              // Common Button Settings (for both text and image buttons)
              const SizedBox(height: 24),
              const Text(
                'Button Dimensions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Width'),
                        Slider(
                          value: welcomeSettings.buttonWidth,
                          min: 100,
                          max: 400,
                          divisions: 30,
                          label: welcomeSettings.buttonWidth.round().toString(),
                          onChanged: (value) {
                            welcomeSettings.setButtonDimensions(
                                value, welcomeSettings.buttonHeight);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Height'),
                        Slider(
                          value: welcomeSettings.buttonHeight,
                          min: 40,
                          max: 120,
                          divisions: 20,
                          label:
                              welcomeSettings.buttonHeight.round().toString(),
                          onChanged: (value) {
                            welcomeSettings.setButtonDimensions(
                                welcomeSettings.buttonWidth, value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Border Radius',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: welcomeSettings.buttonBorderRadius,
                min: 0,
                max: 50,
                divisions: 50,
                label: welcomeSettings.buttonBorderRadius.round().toString(),
                onChanged: (value) {
                  welcomeSettings.setButtonBorderRadius(value);
                },
              ),

              const SizedBox(height: 24),
              const Text('Button Preview'),
              const SizedBox(height: 16),
              Center(
                child: welcomeSettings.useImageButton
                    ? _buildImageButtonPreview(welcomeSettings)
                    : _buildTextButtonPreview(welcomeSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextButtonPreview(WelcomeScreenProvider settings) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: settings.welcomeButtonColor,
        foregroundColor: settings.welcomeButtonTextColor,
        minimumSize: Size(settings.buttonWidth, settings.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
        ),
      ),
      onPressed: null,
      child: Text(
        settings.welcomeButtonText,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: settings.welcomeButtonTextColor,
        ),
      ),
    );
  }

  Widget _buildImageButtonPreview(WelcomeScreenProvider settings) {
    if (settings.buttonImagePath == null) {
      return Container(
        width: settings.buttonWidth,
        height: settings.buttonHeight,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
        ),
        child: const Center(
          child: Text('No image selected'),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
      child: Container(
        width: settings.buttonWidth,
        height: settings.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(settings.buttonBorderRadius),
          image: DecorationImage(
            image: settings.isButtonImageAsset
                ? AssetImage(settings.buttonImagePath!)
                : FileImage(File(settings.buttonImagePath!)) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
