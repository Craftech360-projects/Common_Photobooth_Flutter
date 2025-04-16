import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/widgets/improved_color_picker.dart';
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
              _buildSectionHeader('Welcome Message'),
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

              // Welcome Message Styling
              const SizedBox(height: 16),
              _buildSectionHeader('Welcome Message Styling'),

              // Font Size
              _buildSliderWithLabel(
                label: 'Font Size',
                value: welcomeSettings.welcomeMessageFontSize,
                min: 16,
                max: 72,
                divisions: 56,
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
              const SizedBox(height: 8),
              const Text('Margins',
                  style: TextStyle(fontWeight: FontWeight.bold)),

              _buildSliderWithLabel(
                label: 'Top Margin',
                value: welcomeSettings.welcomeMessageMarginTop,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setWelcomeMessageMargins(
                  value,
                  welcomeSettings.welcomeMessageMarginBottom,
                  welcomeSettings.welcomeMessageMarginLeft,
                  welcomeSettings.welcomeMessageMarginRight,
                ),
              ),

              _buildSliderWithLabel(
                label: 'Bottom Margin',
                value: welcomeSettings.welcomeMessageMarginBottom,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setWelcomeMessageMargins(
                  welcomeSettings.welcomeMessageMarginTop,
                  value,
                  welcomeSettings.welcomeMessageMarginLeft,
                  welcomeSettings.welcomeMessageMarginRight,
                ),
              ),

              _buildSliderWithLabel(
                label: 'Left Margin',
                value: welcomeSettings.welcomeMessageMarginLeft,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setWelcomeMessageMargins(
                  welcomeSettings.welcomeMessageMarginTop,
                  welcomeSettings.welcomeMessageMarginBottom,
                  value,
                  welcomeSettings.welcomeMessageMarginRight,
                ),
              ),

              _buildSliderWithLabel(
                label: 'Right Margin',
                value: welcomeSettings.welcomeMessageMarginRight,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setWelcomeMessageMargins(
                  welcomeSettings.welcomeMessageMarginTop,
                  welcomeSettings.welcomeMessageMarginBottom,
                  welcomeSettings.welcomeMessageMarginLeft,
                  value,
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Welcome Screen Background'),
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
              _buildSectionHeader('Button Settings'),
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

              // Common Button Settings
              _buildSliderWithLabel(
                label: 'Button Width',
                value: welcomeSettings.buttonWidth,
                min: 100,
                max: 400,
                divisions: 30,
                onChanged: (value) => welcomeSettings.setButtonWidth(value),
              ),
              _buildSliderWithLabel(
                label: 'Button Height',
                value: welcomeSettings.buttonHeight,
                min: 40,
                max: 120,
                divisions: 16,
                onChanged: (value) => welcomeSettings.setButtonHeight(value),
              ),
              _buildSliderWithLabel(
                label: 'Button Border Radius',
                value: welcomeSettings.buttonBorderRadius,
                min: 0,
                max: 50,
                divisions: 50,
                onChanged: (value) =>
                    welcomeSettings.setButtonBorderRadius(value),
              ),

              // Button Margins
              _buildSliderWithLabel(
                label: 'Button Top Margin',
                value: welcomeSettings.buttonMarginTop,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setButtonMargins(
                  value,
                  welcomeSettings.buttonMarginBottom,
                ),
              ),

              _buildSliderWithLabel(
                label: 'Button Bottom Margin',
                value: welcomeSettings.buttonMarginBottom,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) => welcomeSettings.setButtonMargins(
                  welcomeSettings.buttonMarginTop,
                  value,
                ),
              ),

              _buildSliderWithLabel(
                label: 'Button Opacity',
                value: welcomeSettings.buttonOpacity,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) => welcomeSettings.setButtonOpacity(value),
              ),

              // Text Button Settings
              if (!welcomeSettings.useImageButton) ...[
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),

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
                  max: 48,
                  divisions: 36,
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
                  onChanged: (value) => welcomeSettings.setButtonPadding(
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
                  onChanged: (value) => welcomeSettings.setButtonPadding(
                    welcomeSettings.buttonPaddingVertical,
                    value,
                  ),
                ),
              ],

              // Image Button Settings
              if (welcomeSettings.useImageButton) ...[
                const SizedBox(height: 16),
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
                  ],
                ),
                if (welcomeSettings.buttonImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Selected: ${welcomeSettings.buttonImagePath}'),
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
    required int divisions,
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
                border: Border.all(color: Colors.grey),
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
