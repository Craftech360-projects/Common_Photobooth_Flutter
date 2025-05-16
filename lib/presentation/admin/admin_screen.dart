import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/snackbar.dart';
import 'package:photobooth_flutter/widgets/watermark_overlay.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _supabaseUrlController = TextEditingController();
  final _supabaseAnonKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalSettings =
          Provider.of<GlobalSettingsProvider>(context, listen: false);
      _supabaseUrlController.text = globalSettings.supabaseUrl ?? '';
      _supabaseAnonKeyController.text = globalSettings.supabaseAnonKey ?? '';

      // Set watermark visibility based on authentication status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final watermarkProvider =
          Provider.of<AdminWatermarkProvider>(context, listen: false);
      watermarkProvider.setShowWatermark(!authProvider.isAuthenticated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final watermarkProvider = context.watch<AdminWatermarkProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: WatermarkOverlay(
        show: watermarkProvider.showWatermark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Global Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Constants.h16,
              _GlobalSettingsSection(
                supabaseUrlController: _supabaseUrlController,
                supabaseAnonKeyController: _supabaseAnonKeyController,
              ),
              const Divider(height: 32),
              const Text(
                'Screen Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Constants.h16,
              _ScreenSettingsSection(),
              const Divider(height: 32),
              const Text(
                'Advanced Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Constants.h16,
              _buildAdvancedSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
          ),
          onPressed: () => _showResetConfirmationDialog(),
          child: const Text('Reset All Preferences'),
        ),
      ],
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Preferences'),
        content: const Text(
            'This will reset all settings to their default values. This action cannot be undone. Are you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);

              // Reset all providers
              final globalSettings =
                  Provider.of<GlobalSettingsProvider>(context, listen: false);

              await globalSettings.clearAllPreferences();

              // Update text controllers
              _supabaseUrlController.text = '';
              _supabaseAnonKeyController.text = '';

              showSnackBar(context, 'All preferences have been reset');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _GlobalSettingsSection extends StatelessWidget {
  final TextEditingController supabaseUrlController;
  final TextEditingController supabaseAnonKeyController;

  const _GlobalSettingsSection({
    required this.supabaseUrlController,
    required this.supabaseAnonKeyController,
  });

  // In the _GlobalSettingsSection class
  @override
  Widget build(BuildContext context) {
    final globalSettings = context.watch<GlobalSettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Constants.h24,

        // Add Offline Mode Toggle
        const Text(
          'Storage Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Constants.h8,
        SwitchListTile(
          title: const Text('Offline Mode'),
          subtitle: Text(
            globalSettings.isOfflineMode
                ? 'Using local storage for images'
                : 'Using Supabase for image storage',
          ),
          value: globalSettings.isOfflineMode,
          onChanged: (value) {
            globalSettings.setOfflineMode(value);
          },
        ),

        // Show directory settings if in offline mode
        if (globalSettings.isOfflineMode) ...[
          ListTile(
            title: const Text('Input Directory'),
            subtitle: Text(globalSettings.inputDirectory ?? 'Not set'),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  final result = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: 'Select Input Directory',
                  );

                  if (result != null) {
                    await globalSettings.setInputDirectory(result);
                    showSnackBar(context, 'Input directory updated');
                  }
                } on Exception catch (e) {
                  debugPrint('Error selecting directory: $e');
                  showSnackBar(context, 'Error selecting directory: $e');
                }
              },
              child: const Text('Choose Directory'),
            ),
          ),
          ListTile(
            title: const Text('Output Directory'),
            subtitle: Text(globalSettings.outputDirectory ?? 'Not set'),
            trailing: ElevatedButton(
              onPressed: () async {
                try {
                  final result = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: 'Select Output Directory',
                  );

                  if (result != null) {
                    await globalSettings.setOutputDirectory(result);
                    showSnackBar(context, 'Output directory updated');
                  }
                } on Exception catch (e) {
                  debugPrint('Error selecting directory: $e');
                  showSnackBar(context, 'Error selecting directory: $e');
                }
              },
              child: const Text('Choose Directory'),
            ),
          ),
        ],

        // Show Supabase settings if not in offline mode
        if (!globalSettings.isOfflineMode) ...[
          const Text(
            'Supabase Configuration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Constants.h8,
          TextFormField(
            controller: supabaseUrlController,
            decoration: const InputDecoration(
              labelText: 'Supabase URL',
              border: OutlineInputBorder(),
              hintText: 'https://your-project.supabase.co',
            ),
            onChanged: (value) {
              globalSettings.setSupabaseUrl(value);
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: supabaseAnonKeyController,
            decoration: const InputDecoration(
              labelText: 'Supabase Anon Key',
              border: OutlineInputBorder(),
              hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9........',
            ),
            onChanged: (value) {
              globalSettings.setSupabaseAnonKey(value);
            },
          ),
        ],
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
