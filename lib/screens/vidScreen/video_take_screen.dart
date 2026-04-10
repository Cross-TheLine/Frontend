import 'package:flutter/material.dart';
import 'package:frontend/screens/vidScreen/video_take_finish_dialog.dart';

import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/camera_service.dart';
import '../../services/screen_orientation.dart';

class VideoTakeScreen extends StatefulWidget {
  const VideoTakeScreen({super.key});

  @override
  State<VideoTakeScreen> createState() => _VideoTakeScreenState();
}

class _VideoTakeScreenState extends State<VideoTakeScreen>
    with ScreenOrientationMixin<VideoTakeScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.landscape;

  final CameraService _cameraService = CameraService();

  bool _isInitialized = false;
  bool _isRecording = false;
  String? _recordedVideoPath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();

    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _onRecordButtonPressed() async {
    if (!_isRecording) {
      await _cameraService.startRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = true;
      });
      return;
    }

    final recordedPath = await _cameraService.stopRecording();

    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _recordedVideoPath = recordedPath;
    });

    final action = await showDialog<VideoTakeFinishAction>(
      context: context,
      builder: (_) => const VideoTakeFinish(),
    );

    if (!mounted || action == null) return;

    if (action == VideoTakeFinishAction.judge) {
      Navigator.pushReplacementNamed(context, AppRoutes.videoPick);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.resultSkip);
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      
      bottomNavigationBar: SafeArea(
        top: false,
          child: TextAppButton(
            text: _isRecording ? '촬영 종료' : '촬영 시작',
            isExpanded: false,
            onPressed: _isInitialized ? _onRecordButtonPressed : null,
            variant: AppButtonVariant.gray,
          ),
        ),

      body: SafeArea( // appBar 대신 SafeArea로 띄워서 버튼과 겹치지 않게
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.w(context, 20),
                AppSizes.h(context, 8),
                AppSizes.w(context, 20),
                AppSizes.h(context, 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // appBar 대신
                  SizedBox(height: AppSizes.h(context, 36)),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.w(context, 10),
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.w(context, 24)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '촬영 여기에 띄우기',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  if (_recordedVideoPath != null) ...[
                    SizedBox(height: AppSizes.h(context, 10)),
                    Text(
                      '최근 녹화 파일: $_recordedVideoPath',
                      style: AppTextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // 뒤로가기 버튼
            Positioned(
              left: AppSizes.w(context, 8),
              top: AppSizes.h(context, 2),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}