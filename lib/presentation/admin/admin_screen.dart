import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_flutter/core/constants/constants.dart';
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
  final _emailJsServiceIdController = TextEditingController();
  final _emailJsTemplateIdController = TextEditingController();
  final _emailJsPublicKeyController = TextEditingController();
  final _emailJsPrivateKeyController = TextEditingController();
  final _runpodApiUrlController = TextEditingController();
  final _runpodApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalSettings =
          Provider.of<GlobalSettingsProvider>(context, listen: false);
      _supabaseUrlController.text = globalSettings.supabaseUrl ?? '';
      _supabaseAnonKeyController.text = globalSettings.supabaseAnonKey ?? '';
      _emailJsServiceIdController.text = globalSettings.emailJsServiceId ?? '';
      _emailJsTemplateIdController.text =
          globalSettings.emailJsTemplateId ?? '';
      _emailJsPublicKeyController.text = globalSettings.emailJsPublicKey ?? '';
      // FIX: Initialize the private key controller
      _emailJsPrivateKeyController.text =
          globalSettings.emailJsPrivateKey ?? '';

      _runpodApiUrlController.text = globalSettings.runpodApiUrl ?? '';
      _runpodApiKeyController.text = globalSettings.runpodApiKey ?? '';

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
    _emailJsServiceIdController.dispose();
    _emailJsTemplateIdController.dispose();
    _emailJsPublicKeyController.dispose();
    // FIX: Dispose all controllers
    _emailJsPrivateKeyController.dispose();
    _runpodApiUrlController.dispose();
    _runpodApiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watermarkProvider = context.watch<AdminWatermarkProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
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
                  runpodApiUrlController: _runpodApiUrlController,
                  runpodApiKeyController: _runpodApiKeyController,
                ),
                const Divider(height: 32, color: Colors.white54),
                _buildSharingSettings(
                  context,
                  globalSettings,
                  _emailJsServiceIdController,
                  _emailJsTemplateIdController,
                  _emailJsPublicKeyController,
                  _emailJsPrivateKeyController,
                ),
                const Divider(height: 32, color: Colors.white54),
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

  Widget _buildSharingSettings(
    BuildContext context,
    GlobalSettingsProvider settings,
    TextEditingController emailJsServiceIdController,
    TextEditingController emailJsTemplateIdController,
    TextEditingController emailJsPublicKeyController,
    TextEditingController emailJsPrivateKeyController,
  ) {
    return SettingsGroup(
      icon: '📤',
      title: 'Sharing Settings',
      child: Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: AppColors.darkGrey,
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.darkGrey;
                }
                return AppColors.darkGrey;
              },
            ),
            overlayColor: WidgetStateProperty.all(AppColors.darkGrey),
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                title: const Text('QR Code',
                    style: TextStyle(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Display a QR code on the output screen for users to scan.',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12)),
                value: 'QR Code',
                activeColor: AppColors.darkGrey,
                groupValue: settings.sharingMethod,
                onChanged: (value) {
                  settings.setSharingMethod(value!);
                },
              ),
            ),
            Constants.h16,
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                title: const Text('Email',
                    style: TextStyle(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.bold)),
                subtitle: const Text(
                    'Send the output image directly to the user\'s email address.',
                    style: TextStyle(color: AppColors.darkGrey, fontSize: 12)),
                value: 'Email',
                activeColor: AppColors.darkGrey,
                groupValue: settings.sharingMethod,
                onChanged: (value) {
                  settings.setSharingMethod(value!);
                },
              ),
            ),
            const SizedBox(height: 15),
            if (settings.sharingMethod == "Email")
              SettingsGroup(
                isSubgroup: true,
                icon: '✉️',
                title: 'EmailJS Configuration',
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailJsPublicKeyController,
                      decoration: inputDecoration(context, 'Public Key'),
                      onChanged: (value) => settings.setEmailJsPublicKey(value),
                    ),
                    Constants.h16,
                    TextFormField(
                      controller: emailJsPrivateKeyController,
                      decoration: inputDecoration(context, 'Private Key'),
                      onChanged: (value) =>
                          settings.setEmailJsPrivateKey(value),
                    ),
                    Constants.h16,
                    TextFormField(
                      controller: emailJsServiceIdController,
                      decoration: inputDecoration(context, 'Service ID'),
                      onChanged: (value) => settings.setEmailJsServiceId(value),
                    ),
                    Constants.h16,
                    TextFormField(
                      controller: emailJsTemplateIdController,
                      decoration: inputDecoration(context, 'Template ID'),
                      onChanged: (value) =>
                          settings.setEmailJsTemplateId(value),
                    ),
                  ],
                ),
              )
          ],
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
              _emailJsServiceIdController.text = '';
              _emailJsTemplateIdController.text = '';
              _emailJsPublicKeyController.text = '';
              _emailJsPrivateKeyController.text = '';
              _runpodApiKeyController.text = '';
              _runpodApiUrlController.text = '';

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
  final TextEditingController runpodApiUrlController;
  final TextEditingController runpodApiKeyController;

  const _GlobalSettingsSection({
    required this.supabaseUrlController,
    required this.supabaseAnonKeyController,
    required this.runpodApiUrlController,
    required this.runpodApiKeyController,
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
                    context,
                    'Supabase Project URL',
                  ),
                  onChanged: (value) => globalSettings.setSupabaseUrl(value),
                ),
                Constants.h16,
                TextFormField(
                  controller: supabaseAnonKeyController,
                  decoration: inputDecoration(context, 'Supabase Anon Key'),
                  onChanged: (value) =>
                      globalSettings.setSupabaseAnonKey(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SettingsGroup(
            isSubgroup: true,
            icon: '🚀',
            title: 'RunPod Configuration',
            child: Column(
              children: [
                TextFormField(
                  controller: runpodApiUrlController,
                  decoration: inputDecoration(context, 'RunPod API URL'),
                  onChanged: (value) => globalSettings.setRunpodApiUrl(value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: runpodApiKeyController,
                  decoration: inputDecoration(context, 'RunPod API Key'),
                  onChanged: (value) => globalSettings.setRunpodApiKey(value),
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
          color: AppColors.darkGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkGrey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: AppColors.darkGrey.withOpacity(0.8)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: textTheme.titleMedium
                          ?.copyWith(color: AppColors.darkGrey)),
                  Text(subtitle,
                      style: textTheme.bodySmall?.copyWith(
                          color: AppColors.darkGrey.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: AppColors.darkGrey.withOpacity(0.8)),
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
                backgroundColor: AppColors.black.withValues(alpha: 0.6),
                foregroundColor: AppColors.white,
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
                backgroundColor: AppColors.red.withValues(alpha: 0.8),
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
