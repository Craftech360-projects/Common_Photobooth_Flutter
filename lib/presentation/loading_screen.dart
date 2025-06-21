import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as path;
import 'package:photobooth_flutter/api/workflow.dart';
import 'package:photobooth_flutter/models/user_model.dart';
import 'package:photobooth_flutter/providers/global_settings_provider.dart';
import 'package:photobooth_flutter/providers/photobooth_provider.dart';
import 'package:photobooth_flutter/routes/routes.dart';
import 'package:photobooth_flutter/services/comfy_api_service.dart';
import 'package:photobooth_flutter/services/local_storage_service.dart';
import 'package:photobooth_flutter/services/sqflite_service.dart';
import 'package:photobooth_flutter/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final Player _player;
  late final VideoController _videoController;
  String? _errorMessage;
  final bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);
    _player.open(Media('asset://assets/videos/loading_bg.mp4'), play: true);
    _player.setPlaylistMode(PlaylistMode.single);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
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

    if (provider.faceImagePath == null) {
      _setErrorMessage('No face image captured');
      return;
    }
    final imageFile = File(provider.faceImagePath!);
    if (!await imageFile.exists()) {
      _setErrorMessage('Image file not found');
      return;
    }

    if (!ComfyApiService.isInitialized) {
      await ComfyApiService.initialize(
        apiUrl: globalSettings.comfyApiUrl ?? "http://127.0.0.1:8188",
      );
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    final hasInternet =
        connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi);

    if (hasInternet) {
      await _handleOnlineFlow(imageFile, provider, globalSettings);
    } else {
      await _handleOfflineFlow(imageFile, provider, globalSettings);
    }
  }

  Future<void> _handleOnlineFlow(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings) async {
    debugPrint("--- Starting Online Flow ---");
    final supabaseUrl = globalSettings.supabaseUrl;
    final supabaseAnonKey = globalSettings.supabaseAnonKey;
    if (supabaseUrl == null || supabaseAnonKey == null) {
      _setErrorMessage('Supabase credentials not configured.');
      return;
    }
    if (!SupabaseService.instance.isInitialized) {
      await SupabaseService.instance
          .initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    }

    try {
      final faceImageUrl =
          await SupabaseService.instance.uploadUserFaceImage(imageFile);
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

      final isSwaplab = provider.selectedTheme != null;
      final prefs = await SharedPreferences.getInstance();
      final workflowFileName = isSwaplab
          ? "faceswaponline.json"
          : prefs.getString('selected_workflow') ?? "ghiblionline.json";
      final watcherNodeId = isSwaplab ? "44" : "283";

      final workflow = await Workflow.getWorkflow(workflowFileName);
      workflow.updateSupabaseWatcherNode(uniqueId, nodeId: watcherNodeId);
      workflow.updateNoiseSeed(DateTime.now().millisecondsSinceEpoch);

      if (isSwaplab) {
        final themeName =
            provider.selectedTheme!.name.toLowerCase().replaceAll(' ', '_');
        final gender = provider.gender ?? 'male';
        final characterNumber = Random().nextInt(4) + 1;
        final characterImageName =
            '${gender == 'male' ? 'm' : 'f'}$characterNumber.png';
        final characterImagePath =
            'C:/storage/themes/$gender/$themeName/$characterImageName';
        workflow.updateSwaplabCharacterImage(characterImagePath);
      } else if (workflowFileName.contains("packaging")) {
        final gender = provider.gender ?? 'person';
        final accessories =
            provider.accessories ?? 'shoes, sunglasses, helmet, motorbikes';
        workflow.updatePackagingPrompt(gender, accessories);
      }

      final response = await ComfyApiService.instance
          .sendWorkflow(workflow: workflow.toMap());
      provider.setWorkflowSentTime(DateTime.parse(response['sentTime']));

      // Start polling Supabase
      await _pollForOutput(uniqueId, provider, isOnline: true);
    } catch (e) {
      _setErrorMessage("Online processing failed: $e");
    }
  }

  Future<void> _handleOfflineFlow(File imageFile, PhotoboothProvider provider,
      GlobalSettingsProvider globalSettings) async {
    debugPrint("--- Starting Offline Flow ---");
    if (!LocalStorageService.isServiceInitialized) {
      await LocalStorageService.initialize(
          inputDirectory: globalSettings.inputDirectory!,
          outputDirectory: globalSettings.outputDirectory!);
    }

    try {
      final faceImagePath =
          await LocalStorageService.instance.saveFaceImage(imageFile);
      final outputPath = LocalStorageService.instance.getOutputPathWithPrefix();

      final isSwaplab = provider.selectedTheme != null;
      final prefs = await SharedPreferences.getInstance();
      final workflowFileName = isSwaplab
          ? "swaplab.json"
          : prefs
                  .getString('selected_workflow')
                  ?.replaceFirst("online", "offline") ??
              "ghiblioffline.json";

      final workflow = await Workflow.getWorkflow(workflowFileName);
      workflow.updateNoiseSeed(DateTime.now().millisecondsSinceEpoch);

      if (isSwaplab) {
        final themeName =
            provider.selectedTheme!.name.toLowerCase().replaceAll(' ', '_');
        final gender = provider.gender ?? 'male';
        final characterNumber = Random().nextInt(4) + 1;
        final characterImageName =
            '${gender == 'male' ? 'm' : 'f'}$characterNumber.png';
        final characterImagePath =
            'C:/storage/themes/$gender/$themeName/$characterImageName';

        workflow.updateSwaplabInputFaceImage(faceImagePath);
        workflow.updateSwaplabCharacterImage(characterImagePath);
        workflow.updateSwaplabOutputImagePath(outputPath);
      } else {
        workflow.updateInputImagePath(faceImagePath);
        workflow.updateOutputImagePath(outputPath);
        if (workflowFileName.contains("packaging")) {
          final gender = provider.gender ?? 'person';
          final accessories =
              provider.accessories ?? 'shoes, sunglasses, helmet, motorbikes';
          workflow.updatePackagingPrompt(gender, accessories);
        }
      }

      final response = await ComfyApiService.instance
          .sendWorkflow(workflow: workflow.toMap());
      provider.setWorkflowSentTime(DateTime.parse(response['sentTime']));

      await _pollForOutput(outputPath, provider, isOnline: false);
    } catch (e) {
      _setErrorMessage("Offline processing failed: $e");
    }
  }

  Future<void> _pollForOutput(String identifier, PhotoboothProvider provider,
      {required bool isOnline}) async {
    int attempts = 0;
    const maxAttempts = 120;
    const pollDelay = Duration(seconds: 2);

    while (attempts < maxAttempts) {
      String? outputUrl;
      if (isOnline) {
        outputUrl = await SupabaseService.instance.getLatestOutputImage(
            identifier,
            afterTime: provider.workflowSentTime);
      } else {
        outputUrl = await LocalStorageService.instance.getLatestOutputImage(
            identifier,
            afterTime: provider.workflowSentTime);
      }

      if (outputUrl != null) {
        debugPrint('Found output image: $outputUrl');
        provider.setCapturedImageUrl(outputUrl);

        if (!isOnline) {
          await DatabaseService.instance.insertUser(UserData(
            name: provider.name ?? 'N/A',
            email: provider.email ?? 'N/A',
            outputImageFilename: path.basename(outputUrl),
          ));
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
  }

  //   final seed = DateTime.now().millisecondsSinceEpoch;
  //   final isSwaplabFlow = provider.selectedTheme != null;
  //   final prefs = await SharedPreferences.getInstance();

  //   final String workflowFileName;
  //   final String watcherNodeId;

  //   if (isSwaplabFlow) {
  //     workflowFileName = 'swaplabonline.json';
  //     watcherNodeId = '44'; // As per swaplabonline.json
  //   } else {
  //     workflowFileName =
  //         prefs.getString('selected_workflow') ?? 'ghiblionline.json';
  //     watcherNodeId = '283'; // As per AI Artistry JSON files
  //   }

  //   await _processOnlineFlow(
  //     imageFile: imageFile,
  //     provider: provider,
  //     globalSettings: globalSettings,
  //     seed: seed,
  //     workflowFileName: workflowFileName,
  //     watcherNodeId: watcherNodeId,
  //     isSwaplab: isSwaplabFlow,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _errorMessage != null
            ? _buildErrorDisplay()
            : Video(
                controls: NoVideoControls,
                controller: _videoController,
              ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          const Text(
            'An Error Occurred',
            style: TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
