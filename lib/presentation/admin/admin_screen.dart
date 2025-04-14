import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _GlobalSettingsSection(),
            const Divider(height: 32),
            const Text(
              'Screen Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ScreenSettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _GlobalSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalSettings = context.watch<GlobalSettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resolution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<Size>(
          value: globalSettings.selectedResolution,
          items: [
            const Size(1920, 1080),
            const Size(1024, 768),
          ].map((Size size) {
            return DropdownMenuItem<Size>(
              value: size,
              child: Text('${size.width.toInt()} x ${size.height.toInt()}'),
            );
          }).toList(),
          onChanged: (Size? newSize) {
            if (newSize != null) {
              globalSettings.setResolution(newSize);
            }
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Global Background Image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Constants.h8,
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
                dialogTitle: 'Please select an image file',
              );

              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                if (file.path != null) {
                  await globalSettings.setBackgroundImage(
                    file.path!,
                    isAsset: false,
                  );
                  showSnackBar(
                      context, 'Background image updated successfully');
                }
              }
            } on Exception catch (e) {
              debugPrint('Error picking file: $e');
              showSnackBar(context, 'Error selecting file: $e');
            }
          },
          child: const Text('Choose Background Image'),
        ),
        if (globalSettings.backgroundImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Selected: ${globalSettings.backgroundImage}'),
          ),
      ],
    );
  }
}

class _ScreenSettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingCard(
          context,
          'Welcome Screen',
          'Configure welcome screen appearance and content',
          Icons.home,
          () => Navigator.pushNamed(context, AppRoutes.welcomeScreenSettings),
        ),
        _buildSettingCard(
          context,
          'Registration Screen',
          'Configure registration form fields and appearance',
          Icons.app_registration,
          () => Navigator.pushNamed(
              context, AppRoutes.registrationScreenSettings),
        ),
        _buildSettingCard(
          context,
          'Gender Selection Screen',
          'Configure gender selection options and appearance',
          Icons.people,
          () => Navigator.pushNamed(context, AppRoutes.genderScreenSettings),
        ),
        _buildSettingCard(
          context,
          'Character Selection Screen',
          'Configure character selection options and appearance',
          Icons.tips_and_updates_rounded,
          () => Navigator.pushNamed(context, AppRoutes.characterScreenSettings),
        ),
        _buildSettingCard(
          context,
          'Capturing Screen',
          'Configure capturing options and appearance',
          Icons.camera,
          () => Navigator.pushNamed(context, AppRoutes.faceCaptureSettings),
        ),
        _buildSettingCard(
          context,
          'Loading Screen',
          'Configure loading screen appearance and animation',
          Icons.hourglass_empty,
          () => Navigator.pushNamed(context, AppRoutes.loadingScreenSettings),
        ),
        _buildSettingCard(
          context,
          'Output Screen',
          'Configure output screen appearance and content',
          Icons.print_rounded,
          () => Navigator.pushNamed(context, AppRoutes.outputScreenSettings),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        onTap: onTap,
      ),
    );
  }
}

// class _SettingsCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _SettingsCard({
//     required this.title,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: Icon(icon, color: AppColors.goldenYellow),
//         title: Text(title),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }
