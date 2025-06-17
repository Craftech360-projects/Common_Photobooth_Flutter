import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/presentation/welcome_screen.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
import 'package:photobooth_flutter/widgets/settings_preview.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class WelcomeScreenSettings extends StatelessWidget {
  const WelcomeScreenSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final welcomeSettings = context.watch<WelcomeScreenProvider>();
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Screen Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview section - takes fixed width based on the preview scale
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SettingsPreview(
                width: 1080,
                height: 1920,
                // scale: 0.45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: const WelcomeScreen(),
              ),
            ),

            // Settings section - takes remaining width
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Enable Welcome Screen',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                      Constants.h16,
                      _buildSectionHeader('Welcome Message'),
                      Constants.h8,
                      TextFormField(
                        initialValue: welcomeSettings.welcomeMessage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter welcome message',
                        ),
                        maxLines: 3,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessage(value),
                      ),

                      // Welcome Message Styling
                      Constants.h16,
                      _buildSectionHeader('Welcome Message Styling'),

                      // Font Size
                      _buildSliderWithLabel(
                        label: 'Font Size',
                        value: welcomeSettings.welcomeMessageFontSize,
                        min: 12,
                        max: 80,
                        divisions: 68,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessageFontSize(value),
                      ),

                      // Font Weight
                      _buildDropdownWithLabel<FontWeight>(
                        label: 'Font Weight',
                        value: welcomeSettings.welcomeMessageFontWeight,
                        items: {
                          FontWeight.w100: 'Thin',
                          FontWeight.w300: 'Light',
                          FontWeight.w400: 'Regular',
                          FontWeight.w500: 'Medium',
                          FontWeight.w700: 'Bold',
                          FontWeight.w900: 'Black',
                        },
                        onChanged: (value) {
                          if (value != null) {
                            welcomeSettings.setWelcomeMessageFontWeight(value);
                          }
                        },
                      ),

                      // Line Height
                      _buildSliderWithLabel(
                        label: 'Line Height',
                        value: welcomeSettings.welcomeMessageLineHeight,
                        min: 0.8,
                        max: 2.0,
                        divisions: 24,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessageLineHeight(value),
                      ),

                      // Text Align
                      _buildDropdownWithLabel<TextAlign>(
                        label: 'Text Alignment',
                        value: welcomeSettings.welcomeMessageTextAlign,
                        items: {
                          TextAlign.left: 'Left',
                          TextAlign.center: 'Center',
                          TextAlign.right: 'Right',
                        },
                        onChanged: (value) {
                          if (value != null) {
                            welcomeSettings.setWelcomeMessageTextAlign(value);
                          }
                        },
                      ),

                      // Font Color
                      _buildColorPickerWithLabel(
                        context: context,
                        label: 'Text Color',
                        color: welcomeSettings.welcomeMessageColor,
                        onColorChanged: (color) =>
                            welcomeSettings.setWelcomeMessageColor(color),
                      ),

                      // Text Opacity
                      _buildSliderWithLabel(
                        label: 'Text Opacity',
                        value: welcomeSettings.welcomeMessageOpacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessageOpacity(value),
                      ),

                      // Italic Style
                      _buildSwitchWithLabel(
                        label: 'Italic Style',
                        value: welcomeSettings.welcomeMessageItalic,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessageItalic(value),
                      ),

                      // Margins
                      Constants.h8,
                      const Text('Positioning',
                          style: TextStyle(fontWeight: FontWeight.bold)),

                      _buildSliderWithLabel(
                        label: 'Left Position',
                        value: welcomeSettings.welcomeMessageLeft,
                        min: 0,
                        max: 1080,
                        divisions: 108,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessagePosition(
                          value,
                          welcomeSettings.welcomeMessageTop,
                          welcomeSettings.welcomeMessageWidth,
                        ),
                      ),

                      _buildSliderWithLabel(
                        label: 'Top Position',
                        value: welcomeSettings.welcomeMessageTop,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessagePosition(
                          welcomeSettings.welcomeMessageLeft,
                          value,
                          welcomeSettings.welcomeMessageWidth,
                        ),
                      ),

                      _buildSliderWithLabel(
                        label: 'Width',
                        value: welcomeSettings.welcomeMessageWidth,
                        min: 200,
                        max: 1080,
                        divisions: 88,
                        onChanged: (value) =>
                            welcomeSettings.setWelcomeMessagePosition(
                          welcomeSettings.welcomeMessageLeft,
                          welcomeSettings.welcomeMessageTop,
                          value,
                        ),
                      ),

                      Constants.h24,
                      _buildSectionHeader('Welcome Screen Background'),
                      Constants.h8,
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
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.image,
                                  allowMultiple: false,
                                  dialogTitle:
                                      'Select welcome screen background',
                                );

                                if (result != null && result.files.isNotEmpty) {
                                  final file = result.files.first;
                                  if (file.path != null) {
                                    await welcomeSettings
                                        .setWelcomeScreenBackground(
                                      file.path,
                                      isAsset: false,
                                    );
                                    showSnackBar(context,
                                        'Welcome screen background updated');
                                  }
                                }
                              } on Exception catch (e) {
                                debugPrint('Error picking file: $e');
                                showSnackBar(
                                    context, 'Error selecting file: $e');
                              }
                            },
                            child: const Text('Choose Background'),
                          ),
                          Constants.w16,
                          TextButton(
                            onPressed: () {
                              welcomeSettings.setWelcomeScreenBackground(null);
                              showSnackBar(
                                  context, 'Using global background image');
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
                      Constants.h24,
                      _buildSectionHeader('Button Settings'),
                      Constants.h8,
                      _buildSliderWithLabel(
                        label: 'Button Position From Left',
                        value: welcomeSettings.buttonLeft,
                        min: 0,
                        max: 1000,
                        onChanged: (value) => welcomeSettings.setButtonPosition(
                            value, welcomeSettings.buttonBottom),
                      ),
                      _buildSliderWithLabel(
                        label: 'Button Position From Bottom',
                        value: welcomeSettings.buttonBottom,
                        min: 0,
                        max: 1000,
                        onChanged: (value) => welcomeSettings.setButtonPosition(
                            welcomeSettings.buttonLeft, value),
                      ),

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

                      // Common Button Settings
                      _buildSliderWithLabel(
                        label: 'Button Width',
                        value: welcomeSettings.buttonWidth,
                        min: 100,
                        max: 800,
                        onChanged: (value) =>
                            welcomeSettings.setButtonWidth(value),
                      ),
                      _buildSliderWithLabel(
                        label: 'Button Height',
                        value: welcomeSettings.buttonHeight,
                        min: 20,
                        max: 300,
                        onChanged: (value) =>
                            welcomeSettings.setButtonHeight(value),
                      ),
                      _buildSliderWithLabel(
                        label: 'Button Border Radius',
                        value: welcomeSettings.buttonBorderRadius,
                        min: 0,
                        max: 30,
                        divisions: 30,
                        onChanged: (value) =>
                            welcomeSettings.setButtonBorderRadius(value),
                      ),

                      _buildSliderWithLabel(
                        label: 'Button Opacity',
                        value: welcomeSettings.buttonOpacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        onChanged: (value) =>
                            welcomeSettings.setButtonOpacity(value),
                      ),

                      // Text Button Settings
                      if (!welcomeSettings.useImageButton) ...[
                        Constants.h16,
                        _buildSectionHeader('Text Button Settings'),

                        TextFormField(
                          initialValue: welcomeSettings.welcomeButtonText,
                          decoration: const InputDecoration(
                            labelText: 'Button Text',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              welcomeSettings.setWelcomeButtonText(value),
                        ),
                        Constants.h8,

                        _buildColorPickerWithLabel(
                          context: context,
                          label: 'Button Color',
                          color: welcomeSettings.welcomeButtonColor,
                          onColorChanged: (color) =>
                              welcomeSettings.setWelcomeButtonColor(color),
                        ),

                        _buildColorPickerWithLabel(
                          context: context,
                          label: 'Button Text Color',
                          color: welcomeSettings.welcomeButtonTextColor,
                          onColorChanged: (color) =>
                              welcomeSettings.setWelcomeButtonTextColor(color),
                        ),

                        // Text Button Additional Styling
                        _buildSliderWithLabel(
                          label: 'Text Font Size',
                          value: welcomeSettings.buttonTextFontSize,
                          min: 12,
                          max: 60,
                          divisions: 46,
                          onChanged: (value) =>
                              welcomeSettings.setButtonTextFontSize(value),
                        ),

                        _buildDropdownWithLabel<FontWeight>(
                          label: 'Text Font Weight',
                          value: welcomeSettings.buttonTextFontWeight,
                          items: {
                            FontWeight.w100: 'Thin',
                            FontWeight.w300: 'Light',
                            FontWeight.w400: 'Regular',
                            FontWeight.w500: 'Medium',
                            FontWeight.w700: 'Bold',
                            FontWeight.w900: 'Black',
                          },
                          onChanged: (value) {
                            if (value != null) {
                              welcomeSettings.setButtonTextFontWeight(value);
                            }
                          },
                        ),

                        _buildSliderWithLabel(
                          label: 'Text Line Height',
                          value: welcomeSettings.buttonTextLineHeight,
                          min: 0.8,
                          max: 2.0,
                          divisions: 24,
                          onChanged: (value) =>
                              welcomeSettings.setButtonTextLineHeight(value),
                        ),

                        _buildSwitchWithLabel(
                          label: 'Text Italic Style',
                          value: welcomeSettings.buttonTextItalic,
                          onChanged: (value) =>
                              welcomeSettings.setButtonTextItalic(value),
                        ),

                        _buildSliderWithLabel(
                          label: 'Text Opacity',
                          value: welcomeSettings.buttonTextOpacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (value) =>
                              welcomeSettings.setButtonTextOpacity(value),
                        ),

                        // Button Padding
                        _buildSliderWithLabel(
                          label: 'Button Vertical Padding',
                          value: welcomeSettings.buttonPaddingVertical,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          onChanged: (value) =>
                              welcomeSettings.setButtonPadding(
                            value,
                            welcomeSettings.buttonPaddingHorizontal,
                          ),
                        ),

                        _buildSliderWithLabel(
                          label: 'Button Horizontal Padding',
                          value: welcomeSettings.buttonPaddingHorizontal,
                          min: 0,
                          max: 50,
                          divisions: 50,
                          onChanged: (value) =>
                              welcomeSettings.setButtonPadding(
                            welcomeSettings.buttonPaddingVertical,
                            value,
                          ),
                        ),
                      ],

                      // Image Button Settings
                      if (welcomeSettings.useImageButton) ...[
                        Constants.h16,
                        _buildSectionHeader('Image Button Settings'),
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
                                  final result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.image,
                                    allowMultiple: false,
                                    dialogTitle: 'Select button image',
                                  );

                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    final file = result.files.first;
                                    if (file.path != null) {
                                      await welcomeSettings.setButtonImage(
                                        file.path,
                                        isAsset: false,
                                      );
                                      showSnackBar(
                                          context, 'Button image updated');
                                    }
                                  }
                                } on Exception catch (e) {
                                  debugPrint('Error picking file: $e');
                                  showSnackBar(
                                      context, 'Error selecting file: $e');
                                }
                              },
                              child: const Text('Choose Button Image'),
                            ),
                          ],
                        ),
                        if (welcomeSettings.buttonImagePath != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                'Selected: ${welcomeSettings.buttonImagePath}'),
                          ),
                        _buildSliderWithLabel(
                          label: 'Image Opacity',
                          value: welcomeSettings.buttonImageOpacity,
                          min: 0.1,
                          max: 1.0,
                          divisions: 9,
                          onChanged: (value) =>
                              welcomeSettings.setButtonImageOpacity(value),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSliderWithLabel({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorPickerWithLabel({
    required BuildContext context,
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select $label'),
                  content: SingleChildScrollView(
                    child: ImprovedColorPicker(
                      pickerColor: color,
                      onColorChanged: onColorChanged,
                      colorPalette: [
                        AppColors.white,
                        AppColors.black,
                        AppColors.yellow,
                        AppColors.goldenYellow,
                        AppColors.blue,
                        AppColors.darkBlue,
                        AppColors.red,
                        AppColors.green,
                        AppColors.orange,
                        AppColors.purple,
                        AppColors.deepPurple,
                        AppColors.purpleBright,
                        AppColors.grey,
                        AppColors.lightGrey,
                        AppColors.darkGrey,
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: AppColors.black),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchWithLabel({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownWithLabel<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<T>(
            value: value,
            onChanged: onChanged,
            items: items.entries.map((entry) {
              return DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
