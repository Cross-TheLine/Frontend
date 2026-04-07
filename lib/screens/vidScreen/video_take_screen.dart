import 'package:flutter/material.dart';
import 'package:frontend/screens/vidScreen/video_take_finish.dart';

import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/camera_service.dart';

class VideoTakeScreen extends StatefulWidget {
  const VideoTakeScreen({super.key});

  @override
  State<VideoTakeScreen> createState() => _VideoTakeScreenState();
}

class _VideoTakeScreenState extends State<VideoTakeScreen> {
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

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _onRecordButtonPressed() async {
    if (!_isRecording) {
      await _cameraService.startRecording();

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecording = true;
      });
      return;
    }

    final recordedPath = await _cameraService.stopRecording();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRecording = false;
      _recordedVideoPath = recordedPath;
    });

    final action = await showDialog<VideoTakeFinishAction>(
      context: context,
      builder: (_) => const VideoTakeFinish(),
    );

    if (!mounted || action == null) {
      return;
    }

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
      appBar: AppBar(
        title: const Text('동영상 촬영'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppSizes.w(context, 24),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.w(context, 24)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_outlined,
                            size: AppSizes.w(context, 72),
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: AppSizes.h(context, 16)),
                          Text(
                            _isInitialized
                                ? (_isRecording ? '촬영 중입니다.' : '카메라 준비 완료')
                                : '카메라 초기화 중...',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.whiteS(context),
                          ),
                          SizedBox(height: AppSizes.h(context, 12)),
                          Text(
                            '실제 카메라 미리보기와 녹화 기능은 이 영역에 연결하면 됩니다.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h(context, 16)),
              if (_recordedVideoPath != null)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.h(context, 12)),
                  child: Text(
                    '최근 녹화 파일: $_recordedVideoPath',
                    style: AppTextStyles.caption(context),
                  ),
                ),
              WhiteTextAppButton(
                text: _isRecording ? '촬영 종료' : '촬영 시작',
                onPressed: _isInitialized ? _onRecordButtonPressed : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
