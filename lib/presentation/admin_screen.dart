import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:provider/provider.dart';

import '../providers/admin_settings_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            unselectedLabelColor: AppColors.lightGrey,
            labelColor: AppColors.white,
            tabs: [
              Tab(text: 'Global Settings'),
              Tab(text: 'Participant Details'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _GlobalSettingsTab(),
            _ParticipantDetailsTab(),
          ],
        ),
      ),
    );
  }
}

class _GlobalSettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminSettings = context.watch<AdminSettingsProvider>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resolution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          DropdownButton<Size>(
            value: adminSettings.selectedResolution,
            items: [
              const Size(1920, 1080),
              const Size(1024, 768), // COMMON TAB RESOLUTION
            ].map((Size size) {
              return DropdownMenuItem<Size>(
                value: size,
                child: Text('${size.width.toInt()} x ${size.height.toInt()}'),
              );
            }).toList(),
            onChanged: (Size? newSize) {
              if (newSize != null) {
                adminSettings.setResolution(newSize);
              }
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Background Image',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Constants.h8,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null) {
                adminSettings.setBackgroundImage(
                  result.files.single.path!,
                  isAsset: false,
                );
              }
            },
            child: const Text('Choose Background Image'),
          ),
          if (adminSettings.backgroundImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Selected: ${adminSettings.backgroundImage}'),
            ),
        ],
      ),
    );
  }
}

class _ParticipantDetailsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminSettings = context.watch<AdminSettingsProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Form Fields',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () => adminSettings.addFormField(),
                child: const Text('Add Field'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adminSettings.formFields.length,
            itemBuilder: (context, index) {
              final field = adminSettings.formFields[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            field.label,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                adminSettings.removeFormField(field.id),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: field.hintText,
                        decoration: const InputDecoration(
                          labelText: 'Hint Text',
                        ),
                        onChanged: (value) {
                          adminSettings.updateFormField(
                            field.id,
                            CustomFormField(
                                id: field.id,
                                label: field.label,
                                hintText: value,
                                fillColor: field.fillColor,
                                textColor: field.textColor),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Text(
            'Spacing Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Field Spacing'),
                    Slider(
                      value: adminSettings.fieldSpacing,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: adminSettings.fieldSpacing.toString(),
                      onChanged: (value) =>
                          adminSettings.setFieldSpacing(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Button Spacing'),
                    Slider(
                      value: adminSettings.buttonSpacing,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: adminSettings.buttonSpacing.toString(),
                      onChanged: (value) =>
                          adminSettings.setButtonSpacing(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Submit Button Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: adminSettings.submitButtonText,
            decoration: const InputDecoration(
              labelText: 'Button Text',
            ),
            onChanged: (value) => adminSettings.setSubmitButtonText(value),
          ),
        ],
      ),
    );
  }
}
