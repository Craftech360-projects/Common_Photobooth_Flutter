
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photobooth_flutter/core/themes/app_colors.dart';
import 'package:photobooth_flutter/providers/admin_watermark_provider.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/loading_screen_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/email_services.dart';
import 'package:photobooth_flutter/services/license_service.dart';
import 'package:photobooth_flutter/services/runpod_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:photobooth_flutter/workflows/workflow.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  final bool isPreviewMode;
  const LoadingScreen({super.key, this.isPreviewMode = false});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final Player _player;
  VideoController? _videoController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _player = Player();
    final settings = context.read<LoadingScreenProvider>();

    if (settings.loaderAssetType == 'video') {
      _videoController = VideoController(_player);
      final media = settings.isLoaderAsset
          ? Media('asset://${settings.loaderAssetPath}')
          : Media(settings.loaderAssetPath);
      _player.open(media, play: true);
      _player.setPlaylistMode(PlaylistMode.loop);
    }

    if (!widget.isPreviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _processImage());
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _setErrorMessage(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _player.pause();
      });
    }
  }

  Future<void> _processImage() async {
    final provider = Provider.of<PhotoboothProvider>(context, listen: false);
    final globalSettings =
        Provider.of<GlobalSettingsProvider>(context, listen: false);
    final watermarkProvider =
        Provider.of<AdminWatermarkProvider>(context, listen: false);

    if (provider.faceImagePath == null) {
      _setErrorMessage('No face image captured');
      return;
    }
    // On web, we can't check file existence like on native platforms
    // The path is actually a blob URL or data URL from the camera plugin

    // Check credits before processing
    final userId = await LicenseService.instance.getUserId();
    if (userId != null) {
      final creditsLeft =
          await SupabaseService.instance.getUserCreditsLeft(userId);
      if (creditsLeft == null || creditsLeft <= 0) {
        _setErrorMessage(
            'You don\'t have any credits left to continue with generating images. Please use a different license key.');
        watermarkProvider.setShowWatermark(true);
        // Navigate back to welcome screen after showing error
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Provider.of<PhotoboothProvider>(context, listen: false)
              .clearUserData();
          Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.welcomeScreen, (route) => false);
        }
        return;
      }
    }

    final seed = DateTime.now().millisecondsSinceEpoch;
    final isSwaplabFlow = provider.selectedTheme != null;
    final prefs = await SharedPreferences.getInstance();

    final String workflowFileName;
    final String watcherNodeId;

    if (isSwaplabFlow) {
      workflowFileName = 'swaplabonline.json';
      watcherNodeId = '44';
    } else {
      workflowFileName =
          prefs.getString('selected_workflow') ?? 'ghiblionline.json';
      watcherNodeId = '283';
    }

    await _processOnlineFlow(
      imagePath: provider.faceImagePath!,
      provider: provider,
      globalSettings: globalSettings,
      seed: seed,
      workflowFileName: workflowFileName,
      watcherNodeId: watcherNodeId,
      isSwaplab: isSwaplabFlow,
    );
  }

  Future<void> _processOnlineFlow({
    required String imagePath,
    required PhotoboothProvider provider,
    required GlobalSettingsProvider globalSettings,
    required int seed,
    required String workflowFileName,
    required String watcherNodeId,
    required bool isSwaplab,
  }) async {
    final watermarkProvider =
        Provider.of<AdminWatermarkProvider>(context, listen: false);
    final userId = await LicenseService.instance.getUserId();
    final supabaseUrl = globalSettings.supabaseUrl;
    final supabaseAnonKey = globalSettings.supabaseAnonKey;
    final runpodApiKey = dotenv.env['RUNPOD_API_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      _setErrorMessage('Supabase credentials not configured.');
      return;
    }

    if (runpodApiKey == null) {
      _setErrorMessage('RunPod API Key not configured in .env file.');
      return;
    }

    final String? endpointUrl = isSwaplab
        ? dotenv.env['RUNPOD_SWAPLAB_URL']
        : dotenv.env['RUNPOD_AI_ARTISTRY_URL'];

    if (endpointUrl == null) {
      _setErrorMessage('RunPod URL not configured in .env file.');
      return;
    }

    if (!SupabaseService.instance.isInitialized) {
      await SupabaseService.instance.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }

    try {
      final faceImageUrl =
          await SupabaseService.instance.uploadUserFaceImageFromPath(imagePath);
      if (faceImageUrl == null) {
        _setErrorMessage('Failed to upload face image.');
        return;
      }

      final uniqueId = await SupabaseService.instance.storeParticipantDetails(
        name: provider.name ?? 'N/A',
        email: provider.email ?? 'N/A',
        gender: provider.gender ?? 'male',
        imageUrl: faceImageUrl,
      );
      if (uniqueId == null) {
        _setErrorMessage('Failed to store participant details in Supabase.');
        return;
      }

      final workflow = await Workflow.getWorkflow(workflowFileName);
      workflow.updateSupabaseWatcherNode(uniqueId, nodeId: watcherNodeId);
      workflow.updateNoiseSeed(seed);

      if (isSwaplab) {
        await SupabaseService.instance.selectAndUpdateRandomCharacterImage(
          uniqueId: uniqueId,
          gender: provider.gender ?? 'male',
          themeName: provider.selectedTheme!.name,
        );
      } else if (workflowFileName == 'packagingonline.json') {
        final gender = provider.gender ?? 'person';
        final accessories =
            provider.accessories ?? 'shoes, sunglasses, helmet, motorbikes';
        workflow.updatePackagingPrompt(gender, accessories);
      }

      await RunPodService.triggerRunPodWorkflow(
        workflow: workflow.toMap(),
        apiUrl: endpointUrl,
        apiKey: runpodApiKey,
      );

      // log("Workflow sent to RunPod successfully: ${workflow.toJSON()}");

      provider.setWorkflowSentTime(DateTime.now());

      int attempts = 0;
      const maxAttempts = 200;
      const pollDelay = Duration(seconds: 3);

      while (attempts < maxAttempts) {
        final supabaseImageUrl =
            await SupabaseService.instance.getLatestOutputImage(
          uniqueId,
          afterTime: provider.workflowSentTime,
        );

        if (supabaseImageUrl != null) {
          provider.setSwappedImage(supabaseImageUrl);
          provider.setCapturedImageUrl(supabaseImageUrl);

          // Decrement credits after successful image generation
          if (userId != null) {
            await SupabaseService.instance.decrementUserCredits(userId);
            // Update local credits count
            final updatedCredits =
                await SupabaseService.instance.getUserCreditsLeft(userId);
            if (updatedCredits != null) {
              await LicenseService.instance.setCreditsLeft(updatedCredits);
              // Show watermark if credits are exhausted
              if (updatedCredits <= 0) {
                watermarkProvider.setShowWatermark(true);
              }
            }
          }

          if (globalSettings.sharingMethod == 'Email') {
            await EmailService.sendEmail(
              toEmail: provider.email!,
              imageUrl: supabaseImageUrl,
              serviceId: globalSettings.emailJsServiceId,
              templateId: globalSettings.emailJsTemplateId,
              publicKey: globalSettings.emailJsPublicKey,
              privateKey: globalSettings.emailJsPrivateKey,
            );
          }

          if (mounted) {
            await Navigator.of(context)
                .pushReplacementNamed(AppRoutes.swappedFace);
          }
          return;
        }
        await Future.delayed(pollDelay);
        attempts++;
      }
      _setErrorMessage('Timed out waiting for image processing.');
    } on Exception catch (e) {
      _setErrorMessage('Error processing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<LoadingScreenProvider>();
    final globalSettings = context.watch<GlobalSettingsProvider>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Image
          if (settings.showBackground && settings.backgroundImagePath != null)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getBackgroundImage(settings, globalSettings),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Loader Asset
          if (_errorMessage == null) _buildLoaderWidget(settings, screenSize),

          // Title
          if (settings.showTitle)
            Positioned(
              top: settings.titleTop * screenSize.height,
              width: settings.titleWidth * screenSize.width,
              child: Text(
                settings.titleText,
                textAlign: settings.titleAlignment,
                style: TextStyle(
                  fontSize: settings.titleFontSize,
                  fontWeight: settings.titleFontWeight,
                  color: settings.titleColor
                      .withValues(alpha: settings.titleOpacity),
                ),
              ),
            ),

          // Error Message Overlay
          if (_errorMessage != null) _buildErrorDisplay(),
        ],
      ),
    );
  }

  Widget _buildLoaderWidget(LoadingScreenProvider settings, Size screenSize) {
    Widget loader;
    if (settings.loaderAssetType == 'video') {
      if (_videoController == null) return const SizedBox.shrink();
      loader = Video(
        controller: _videoController!,
        controls: NoVideoControls,
        fit: BoxFit.cover,
      );
    } else {
      // 'gif'
      loader = settings.isLoaderAsset
          ? Image.asset(settings.loaderAssetPath)
          : Image.network(settings.loaderAssetPath);
    }

    if (settings.loaderAssetType == 'video' && settings.loaderIsFullscreen) {
      return SizedBox.expand(child: loader);
    }

    return Positioned(
      top: settings.loaderTop * screenSize.height,
      left: settings.loaderLeft * screenSize.width,
      width: settings.loaderWidth * screenSize.width,
      height: settings.loaderHeight * screenSize.height,
      child: loader,
    );
  }

  ImageProvider _getBackgroundImage(
      LoadingScreenProvider settings, GlobalSettingsProvider globalSettings) {
    // This method remains the same
    if (settings.showBackground && settings.backgroundImagePath != null) {
      if (settings.isBackgroundImageAsset) {
        return AssetImage(settings.backgroundImagePath!);
      } else {
        return NetworkImage(settings.backgroundImagePath!);
      }
    } else {
      if (globalSettings.backgroundImagePath != null) {
        if (globalSettings.isBackgroundImageAsset) {
          return AssetImage(globalSettings.backgroundImagePath!);
        } else {
          return NetworkImage(globalSettings.backgroundImagePath!);
        }
      } else {
        return const AssetImage('assets/images/common_bg.png');
      }
    }
  }

  Widget _buildErrorDisplay() {
    // This method remains the same
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text('An Error Occurred',
              style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(_errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}
