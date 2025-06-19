import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/models/user_model.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart';
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/sqflite_service.dart';
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

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final watermarkProvider =
          Provider.of<AdminWatermarkProvider>(context, listen: false);
      watermarkProvider.setShowWatermark(!authProvider.isAuthenticated);
    });
  }

  // Helper method to convert user data to CSV format
  String _usersToCsv(List<UserData> users) {
    List<List<dynamic>> rows = [];
    // Add header row
    rows.add(['Name', 'Email', 'Output Filename']);
    // Add data rows
    for (var user in users) {
      rows.add([user.name, user.email, user.outputImageFilename]);
    }
    // Convert to CSV string
    return rows.map((row) => row.join(',')).join('\n');
  }

  // Handle the export and save logic
  void _exportUserData() async {
    try {
      final users = await DatabaseService.instance.getAllUsers();
      if (users.isEmpty) {
        showSnackBar(context, 'No user data to export.');
        return;
      }

      final csvData = _usersToCsv(users);

      // MODIFIED: Create a filename-safe timestamp.
      final now = DateTime.now();
      final timestamp =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

      // Use file_picker to let the user choose a save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save User Data as CSV',
        fileName: 'photobooth_users_$timestamp.csv',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);
        showSnackBar(context, 'User data exported successfully to $outputFile');
      }
    } catch (e) {
      showSnackBar(context, 'Error exporting data: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _supabaseUrlController.dispose();
    _supabaseAnonKeyController.dispose();
    super.dispose();
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
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
          ),
          onPressed: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.authScreen,
                (Route<dynamic> route) => false,
              );
            }
          },
          child: const Text('Add New Key'),
        ),
        Constants.w8,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
          ),
          onPressed: () => _showResetConfirmationDialog(),
          child: const Text('Reset All Preferences'),
        ),
        Constants.w8,
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: AppColors.white,
          ),
          onPressed: _exportUserData,
          icon: const Icon(Icons.download),
          label: const Text('Export User Data (CSV)'),
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
              // Pop the dialog first
              Navigator.of(context).pop();

              // Get all providers
              final globalSettings =
                  Provider.of<GlobalSettingsProvider>(context, listen: false);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              // Clear all SharedPreferences data
              await globalSettings.clearAllPreferences();

              // Log the user out, which clears secure storage and updates auth state
              await authProvider.logout();

              // Re-initialize all settings providers to load their default state
              await Provider.of<WelcomeScreenProvider>(context, listen: false)
                  .init();
              await Provider.of<RegistrationScreenProvider>(context,
                      listen: false)
                  .init();
              await Provider.of<GenderSelectionProvider>(context, listen: false)
                  .init();
              await Provider.of<CategorySettingsProvider>(context,
                      listen: false)
                  .init();
              await Provider.of<ThemeSelectionProvider>(context, listen: false)
                  .init();
              await Provider.of<FaceCaptureProvider>(context, listen: false)
                  .init();
              await Provider.of<LoadingScreenProvider>(context, listen: false)
                  .init();
              await Provider.of<OutputScreenProvider>(context, listen: false)
                  .init();

              // Update the local text controllers in the AdminScreen
              _supabaseUrlController.text = '';
              _supabaseAnonKeyController.text = '';

              // Give user feedback and navigate
              if (mounted) {
                showSnackBar(context, 'All settings have been reset.');
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.authScreen,
                  (Route<dynamic> route) => false,
                );
              }
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

  @override
  Widget build(BuildContext context) {
    final globalSettings = context.watch<GlobalSettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Global Background Image',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Constants.h8,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4))),
          onPressed: () async {
            try {
              final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                  dialogTitle: 'Please select an image file');
              if (result?.files.first.path != null) {
                await globalSettings.setBackgroundImage(
                    result!.files.first.path!,
                    isAsset: false);
                showSnackBar(context, 'Background image updated successfully');
              }
            } catch (e) {
              debugPrint('Error picking file: $e');
              showSnackBar(context, 'Error selecting file: $e');
            }
          },
          child: const Text('Choose Background Image'),
        ),
        if (globalSettings.backgroundImage != null)
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Selected: ${globalSettings.backgroundImage}')),
        Constants.h24,
        const Text('Storage Mode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Constants.h8,
        SwitchListTile(
          title: const Text('Offline Mode'),
          subtitle: Text(globalSettings.isOfflineMode
              ? 'Using local storage for images'
              : 'Using Supabase for image storage'),
          value: globalSettings.isOfflineMode,
          onChanged: (value) {
            globalSettings.setOfflineMode(value);
          },
        ),
        if (globalSettings.isOfflineMode) ...[
          ListTile(
            title: const Text('Input Directory'),
            subtitle: Text(globalSettings.inputDirectory ?? 'Not set'),
          ),
          ListTile(
            title: const Text('Output Directory'),
            subtitle: Text(globalSettings.outputDirectory ?? 'Not set'),
          ),
        ],
        if (!globalSettings.isOfflineMode) ...[
          const Text('Supabase Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Constants.h8,
          TextFormField(
            controller: supabaseUrlController,
            decoration: const InputDecoration(
                labelText: 'Supabase URL',
                border: OutlineInputBorder(),
                hintText: 'https://your-project.supabase.co'),
            onChanged: (value) => globalSettings.setSupabaseUrl(value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: supabaseAnonKeyController,
            decoration: const InputDecoration(
                labelText: 'Supabase Anon Key',
                border: OutlineInputBorder(),
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9........'),
            onChanged: (value) => globalSettings.setSupabaseAnonKey(value),
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
            () =>
                Navigator.pushNamed(context, AppRoutes.welcomeScreenSettings)),
        _buildSettingCard(
            context,
            'Registration Screen',
            'Configure registration form fields and appearance',
            Icons.app_registration,
            () => Navigator.pushNamed(
                context, AppRoutes.registrationScreenSettings)),
        _buildSettingCard(
            context,
            'Gender Selection Screen',
            'Configure gender selection options and appearance',
            Icons.people,
            () => Navigator.pushNamed(context, AppRoutes.genderScreenSettings)),
        _buildSettingCard(
            context,
            'Categories Screen',
            'Configure main and sub-category cards',
            Icons.category,
            () =>
                Navigator.pushNamed(context, AppRoutes.categoryScreenSettings)),
        _buildSettingCard(
          context,
          'Theme Selection Screen',
          'Configure theme carousel and appearance',
          Icons.burst_mode,
          // FIX: Corrected navigation route
          () => Navigator.pushNamed(context, AppRoutes.themeSelectionSettings),
        ),
        _buildSettingCard(
            context,
            'Capturing Screen',
            'Configure capturing options and appearance',
            Icons.camera,
            () => Navigator.pushNamed(context, AppRoutes.faceCaptureSettings)),
        _buildSettingCard(
            context,
            'Loading Screen',
            'Configure loading screen appearance and animation',
            Icons.hourglass_empty,
            () =>
                Navigator.pushNamed(context, AppRoutes.loadingScreenSettings)),
        _buildSettingCard(
            context,
            'Output Screen',
            'Configure output screen appearance and content',
            Icons.print_rounded,
            () => Navigator.pushNamed(context, AppRoutes.outputScreenSettings)),
      ],
    );
  }

  Widget _buildSettingCard(BuildContext context, String title,
      String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        onTap: onTap,
      ),
    );
  }
}
