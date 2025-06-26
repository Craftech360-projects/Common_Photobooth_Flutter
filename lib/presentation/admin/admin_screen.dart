import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/auth_provider.dart';
import 'package:photobooth_flutter/providers/category_settings_provider.dart';
import 'package:photobooth_flutter/providers/face_capture_provider.dart';
import 'package:photobooth_flutter/providers/gender_selection_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/output_screen_provider.dart';
import 'package:photobooth_flutter/providers/registration_screen_provider.dart';
import 'package:photobooth_flutter/providers/theme_selection_provider.dart'
    hide Theme;
import 'package:photobooth_flutter/providers/welcome_screen_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/widgets/file_upload_area.dart';
import 'package:photobooth_flutter/widgets/input_decoration.dart';
import 'package:photobooth_flutter/widgets/settings_group.dart';
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

  @override
  void dispose() {
    _supabaseUrlController.dispose();
    _supabaseAnonKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
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
        child: WatermarkOverlay(
          show: watermarkProvider.showWatermark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(30, kToolbarHeight + 60, 30, 30),
            child: Column(
              children: [
                _GlobalSettingsSection(
                  supabaseUrlController: _supabaseUrlController,
                  supabaseAnonKeyController: _supabaseAnonKeyController,
                ),
                const SizedBox(height: 25),
                const _ScreenSettingsSection(),
                const SizedBox(height: 25),
                _AdvancedSettingsSection(
                  onReset: _showResetConfirmationDialog,
                ),
              ],
            ),
          ),
        ),
      ),
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
              Navigator.of(context).pop();

              final globalSettings =
                  Provider.of<GlobalSettingsProvider>(context, listen: false);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              await globalSettings.clearAllPreferences();
              await authProvider.logout();

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

              _supabaseUrlController.text = '';
              _supabaseAnonKeyController.text = '';

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

    return SettingsGroup(
      icon: '🌍',
      title: 'Global Settings',
      child: Column(
        children: [
          SettingsGroup(
            isSubgroup: true,
            icon: '🖼️',
            title: 'Global Background Image',
            child: FileUploadArea(
              onTap: () async {
                try {
                  final result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result?.files.first.path != null) {
                    await globalSettings.setBackgroundImage(
                        result!.files.first.path!,
                        isAsset: false);
                    showSnackBar(context,
                        'Global background image updated successfully');
                  }
                } on Exception catch (e) {
                  showSnackBar(context, 'Error selecting file: $e',
                      isError: true);
                }
              },
              icon: '📁',
              text: 'Choose Background Image',
              selectedFile: globalSettings.backgroundImage,
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🔑',
            title: 'Supabase Configuration',
            child: Column(
              children: [
                TextFormField(
                  controller: supabaseUrlController,
                  decoration: inputDecoration(
                      context, 'https://your-project.supabase.co'),
                  onChanged: (value) => globalSettings.setSupabaseUrl(value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: supabaseAnonKeyController,
                  decoration: inputDecoration(context, 'Supabase Anon Key'),
                  onChanged: (value) =>
                      globalSettings.setSupabaseAnonKey(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenSettingsSection extends StatelessWidget {
  const _ScreenSettingsSection();

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      icon: '⚙️',
      title: 'Screen Settings',
      child: Column(
        children: [
          _ScreenSettingItem(
            title: 'Welcome Screen',
            subtitle: 'Configure welcome screen appearance and content',
            icon: Icons.home,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.welcomeScreenSettings),
          ),
          _ScreenSettingItem(
            title: 'Registration Screen',
            subtitle: 'Configure registration form fields and appearance',
            icon: Icons.app_registration,
            onTap: () => Navigator.pushNamed(
                context, AppRoutes.registrationScreenSettings),
          ),
          _ScreenSettingItem(
            title: 'Gender Selection Screen',
            subtitle: 'Configure gender selection options and appearance',
            icon: Icons.people,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.genderScreenSettings),
          ),
          _ScreenSettingItem(
            title: 'Categories Screen',
            subtitle: 'Configure main and sub-category cards',
            icon: Icons.category,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.categoryScreenSettings),
          ),
          _ScreenSettingItem(
            title: 'Theme Selection Screen',
            subtitle: 'Configure theme carousel and appearance',
            icon: Icons.burst_mode,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.themeSelectionSettings),
          ),
          _ScreenSettingItem(
            title: 'Capturing Screen',
            subtitle: 'Configure capturing options and appearance',
            icon: Icons.camera_alt,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.faceCaptureSettings),
          ),
          _ScreenSettingItem(
            title: 'Loading Screen',
            subtitle: 'Configure loading screen appearance and animation',
            icon: Icons.hourglass_empty,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.loadingScreenSettings),
          ),
          _ScreenSettingItem(
            title: 'Output Screen',
            subtitle: 'Configure output screen appearance and content',
            icon: Icons.print,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.outputScreenSettings),
          ),
        ],
      ),
    );
  }
}

class _ScreenSettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ScreenSettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.black.withOpacity(0.8)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          textTheme.titleMedium?.copyWith(color: Colors.black)),
                  Text(subtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.black.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}

class _AdvancedSettingsSection extends StatelessWidget {
  final VoidCallback onReset;
  const _AdvancedSettingsSection({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      icon: '🛠️',
      title: 'Advanced',
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black.withOpacity(0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.authScreen, (route) => false);
                }
              },
              label: const Text('Logout'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: onReset,
              label: const Text('Reset All'),
            ),
          ),
        ],
      ),
    );
  }
}
