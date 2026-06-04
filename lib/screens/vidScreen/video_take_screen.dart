import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../../compo/app_colors.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
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
  final ApiService _apiService = ApiService();

  _VideoSetupPhase _phase = _VideoSetupPhase.initializing;
  Timer? _successPopupTimer;

  bool _isInitialized = false;
  bool _isRecording = false;
  bool _showSuccessPopup = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await applyAppScreenOrientation(AppScreenOrientation.landscape);
      if (!mounted) return;
      await waitForAppliedOrientation(
        context,
        AppScreenOrientation.landscape,
        timeout: const Duration(milliseconds: 900),
      );

      await _cameraService.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _phase = _VideoSetupPhase.intro;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _stringifyError(error);
        _phase = _VideoSetupPhase.failed;
      });
    }
  }

  Future<void> _startLineDetection() async {
    if (_phase == _VideoSetupPhase.detecting) return;

    setState(() {
      _phase = _VideoSetupPhase.detecting;
      _errorMessage = null;
      _showSuccessPopup = false;
    });

    try {
      // 사용자가 확인을 누른 뒤 프레임 1장만 캡처해서 백엔드게 전송
      // 백엔드가 detected=true를 반환하면 준비 완료로 판단하고 이후 녹화 시작
      final XFile frame = await _cameraService.captureFrame();
      final LineDetectionResult result = await _apiService.requestLineDetection(
        imagePath: frame.path,
      );

      if (!mounted) return;

      if (!result.detected) {
        setState(() {
          _phase = _VideoSetupPhase.failed;
          _errorMessage = result.message.isEmpty
              ? '마커와 라인을 인식하지 못했습니다.'
              : result.message;
        });
        return;
      }

      setState(() {
        _phase = _VideoSetupPhase.ready;
        _showSuccessPopup = true;
      });

      _successPopupTimer?.cancel();
      _successPopupTimer = Timer(const Duration(milliseconds: 1250), () {
        if (!mounted) return;
        setState(() {
          _showSuccessPopup = false;
        });
      });

      await _startRecordingAfterDetection();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _phase = _VideoSetupPhase.failed;
        _errorMessage = _stringifyError(error);
      });
    }
  }

  Future<void> _startRecordingAfterDetection() async {
    try {
      await _cameraService.startRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = '라인 인식은 완료됐지만 녹화를 시작하지 못했습니다. ${_stringifyError(error)}';
      });
    }
  }

  Future<void> _onJudgeButtonPressed() async {
    if (_phase != _VideoSetupPhase.ready || !_isRecording) return;

    // 백엔드 판정은 사용자가 버튼을 누른 시점 기준으로 처리
    // 타임스탬프 같이 넘기기
    final DateTime pressedAt = DateTime.now();

    setState(() {
      _phase = _VideoSetupPhase.judging;
      _showSuccessPopup = false;
      _errorMessage = null;
    });

    try {
      // 판정 요청 전 현재 녹화 파일을 확정
      // 이후 ->  loading_result_screen을 안거치고 이 화면의 glass popup 위에서 바로 결과 Api 대기
      final String videoPath = await _cameraService.stopRecording();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
      });

      final bool isIn = await _apiService.requestJudgeByMarkerEvent(
        videoPath: videoPath,
        pressedAt: pressedAt,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: ResultScreenArgs(
          isIn: isIn,
          videoPath: videoPath,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      // 사용자가 다시 마커/라인 인식부터 시작하도록 failed 상태로 되돌리기
      setState(() {
        _phase = _VideoSetupPhase.failed;
        _isRecording = false;
        _errorMessage = _stringifyError(error);
      });
    }
  }

  Future<void> _retryLineDetection() async {
    if (_isRecording) {
      try {
        await _cameraService.stopRecording();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _isRecording = false;
      });
    }

    await _startLineDetection();
  }

  Future<void> _goBack() async {
    if (_isRecording) {
      try {
        await _cameraService.stopRecording();
      } catch (_) {}
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  String _stringifyError(Object error) {
    if (error is CameraServiceException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _successPopupTimer?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _landscapeScale(context);
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final bool isJudgeEnabled = _phase == _VideoSetupPhase.ready && _isRecording;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
              _CameraPreviewLayer(
                isInitialized: _isInitialized,
                controller: _cameraService.controller,
              ),
              _CameraDimOverlay(phase: _phase),



              Positioned(
                right: math.max(26 * scale, safePadding.right + 18 * scale),
                top: safePadding.top,
                bottom: safePadding.bottom,
                child: Center(
                  child: _JudgeButton(
                    scale: scale,
                    enabled: isJudgeEnabled,
                    onPressed: _onJudgeButtonPressed,
                  ),
                ),
              ),
              Positioned(
                left: safePadding.left + 10 * scale,
                top: safePadding.top + 8 * scale,
                child: _RoundIconButton(
                  scale: scale,
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: _goBack,
                ),
              ),

              if (_phase == _VideoSetupPhase.initializing)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.videocam_rounded,
                  title: '카메라 준비 중',
                  message: '잠시만 기다려주세요.',
                  showProgress: true,
                ),

              if (_phase == _VideoSetupPhase.intro)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.center_focus_strong_rounded,
                  title: '라인을 판정할게요',
                  message: '마커가 잘 보이게 배치해주세요.\n인식이 완료되면 자동으로 준비됩니다.',
                  actionText: '확인',
                  onAction: _startLineDetection,
                ),

              if (_phase == _VideoSetupPhase.detecting)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.crop_free_rounded,
                  title: '마커 인식 중',
                  message: '카메라를 움직이지 말고\n마커와 라인이 화면 안에 보이게 해주세요.',
                  showProgress: true,
                ),

              if (_showSuccessPopup)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.check_rounded,
                  title: '인식 성공!',
                  message: '라인 검출이 완료되었습니다.\n판정이 필요할 때 빨간 버튼을 눌러주세요.',
                  compact: true,
                ),
              if (_phase == _VideoSetupPhase.failed)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.priority_high_rounded,
                  title: '인식 실패',
                  message: _errorMessage ?? '마커를 인식하지 못했습니다.',
                  actionText: '다시 인식하기',
                  onAction: _retryLineDetection,
                ),
              if (_phase == _VideoSetupPhase.judging)
                _CenteredGlassPopup(
                  scale: scale,
                  icon: Icons.sports_tennis_rounded,
                  title: '라인 판정 중',
                  message: '버튼을 누른 시점의 영상을 분석하고 있습니다.',
                  lottieAsset: 'assets/lottie/tennis_ball.json',
                  compact: true,
                ),
              if (_errorMessage != null &&
                  _phase == _VideoSetupPhase.ready &&
                  !_showSuccessPopup)
                Positioned(
                  left: 76 * scale,
                  right: 88 * scale,
                  bottom: 18 * scale,
                  child: _SmallGlassMessage(
                    scale: scale,
                    message: _errorMessage!,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

enum _VideoSetupPhase {
  initializing,
  intro,
  detecting,
  ready,
  failed,
  judging,
}

double _landscapeScale(BuildContext context) {
  final Size size = MediaQuery.sizeOf(context);
  return math.min(size.width / 852, size.height / 393)
      .clamp(0.78, 1.25)
      .toDouble();
}

class _CameraPreviewLayer extends StatelessWidget {
  const _CameraPreviewLayer({
    required this.isInitialized,
    required this.controller,
  });

  final bool isInitialized;
  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    final CameraController? cameraController = controller;

    if (!isInitialized ||
        cameraController == null ||
        !cameraController.value.isInitialized) {
      return Container(
        color: const Color(0xFF121212),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final Size? previewSize = cameraController.value.previewSize;
    if (previewSize == null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(child: CameraPreview(cameraController)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewAspect = constraints.maxWidth / constraints.maxHeight;
        double previewAspect = previewSize.width / previewSize.height;
        if (viewAspect > 1 && previewAspect < 1) {
          previewAspect = 1 / previewAspect;
        } else if (viewAspect < 1 && previewAspect > 1) {
          previewAspect = 1 / previewAspect;
        }

        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: previewAspect,
              child: CameraPreview(cameraController),
            ),
          ),
        );
      },
    );
  }
}

class _CameraDimOverlay extends StatelessWidget {
  const _CameraDimOverlay({required this.phase});

  final _VideoSetupPhase phase;

  @override
  Widget build(BuildContext context) {
    final bool shouldDim = phase == _VideoSetupPhase.intro ||
        phase == _VideoSetupPhase.detecting ||
        phase == _VideoSetupPhase.failed ||
        phase == _VideoSetupPhase.judging;

    if (!shouldDim) return const SizedBox.shrink();

    return IgnorePointer(
      child: ColoredBox(
        color: Colors.black.withOpacity(0.18),
      ),
    );
  }
}

class _JudgeButton extends StatelessWidget {
  const _JudgeButton({
    required this.scale,
    required this.enabled,
    required this.onPressed,
  });

  final double scale;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.42,
        child: Container(
          width: 60 * scale,
          height: 60 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF24642),
            border: Border.all(
              color: const Color(0xFF31513E),
              width: 5 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF24642).withOpacity(0.42),
                blurRadius: 18 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.scale,
    required this.icon,
    required this.onPressed,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38 * scale,
        height: 38 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.62),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18 * scale,
        ),
      ),
    );
  }
}

class _CenteredGlassPopup extends StatelessWidget {
  const _CenteredGlassPopup({
    required this.scale,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.showProgress = false,
    this.compact = false,
    this.lottieAsset,
  });

  final double scale;
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final bool showProgress;
  final bool compact;
  final String? lottieAsset;

  @override
  Widget build(BuildContext context) {
    final double width = compact ? 280 * scale : 330 * scale;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28 * scale),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: width,
            padding: EdgeInsets.fromLTRB(
              28 * scale,
              compact ? 22 * scale : 26 * scale,
              28 * scale,
              compact ? 22 * scale : 24 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28 * scale),
              color: Colors.white.withOpacity(0.68),
              border: Border.all(color: Colors.white.withOpacity(0.74)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 30 * scale,
                  offset: Offset(0, 14 * scale),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lottieAsset != null)
                  SizedBox(
                    width: compact ? 74 * scale : 82 * scale,
                    height: compact ? 74 * scale : 82 * scale,
                    child: Lottie.asset(
                      lottieAsset!,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: AppColors.mainTextDark,
                    size: compact ? 32 * scale : 38 * scale,
                  ),
                SizedBox(height: lottieAsset != null ? 10 * scale : 14 * scale),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mainTextDark,
                    fontSize: compact ? 18 * scale : 20 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mainTextDark.withOpacity(0.82),
                    fontSize: 12.5 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                if (showProgress) ...[
                  SizedBox(height: 18 * scale),
                  SizedBox(
                    width: 22 * scale,
                    height: 22 * scale,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4 * scale,
                      color: AppColors.mainTextDark,
                    ),
                  ),
                ],
                if (actionText != null) ...[
                  SizedBox(height: 22 * scale),
                  GestureDetector(
                    onTap: onAction,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: double.infinity,
                          height: 44 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.40),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.62),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              actionText!,
                              style: TextStyle(
                                color: AppColors.mainTextDark,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallGlassMessage extends StatelessWidget {
  const _SmallGlassMessage({
    required this.scale,
    required this.message,
  });

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18 * scale,
            vertical: 12 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.50),
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(color: Colors.white.withOpacity(0.54)),
          ),
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.mainTextDark,
              fontSize: 11 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
