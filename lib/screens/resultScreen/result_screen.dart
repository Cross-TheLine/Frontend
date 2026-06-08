import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/glass_button.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/saved_video_storage_service.dart';
import '../../services/screen_orientation.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.decision,
    this.videoPath,
    this.serverVideoPath,
    this.serverVideoUrl,
  });

  final JudgeDecision decision;
  final String? videoPath;
  final String? serverVideoPath;
  final String? serverVideoUrl;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with ScreenOrientationMixin<ResultScreen> {
  final ApiService _apiService = ApiService();
  final SavedVideoStorageService _savedVideoStorageService = SavedVideoStorageService();

  bool _isMoving = false;
  bool _isMovingToMain = false;

  @override
  AppScreenOrientation get screenOrientation => _isMovingToMain
      ? AppScreenOrientation.portrait
      : AppScreenOrientation.landscape;

  Future<void> _continuePlay() async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _isMovingToMain = false;
    });

    Navigator.pushReplacementNamed(context, AppRoutes.videoTake);
  }

  Future<void> _saveVideoForLater() async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
    });

    try {
      final DateTime now = DateTime.now();
      final String? serverVideoUrl = _nonEmptyString(
        widget.serverVideoUrl ?? _apiService.currentJudgeClipUrl,
      );
      final String? serverVideoPath = _nonEmptyString(
        widget.serverVideoPath ?? _apiService.currentJudgeClipPath,
      );

      if (serverVideoUrl == null) {
        throw const ApiServiceException('서버가 생성한 판정 영상 경로를 받지 못했습니다.');
      }

      await _savedVideoStorageService.saveVideo(
        SavedVideoRecord(
          id: serverVideoPath ?? serverVideoUrl,
          recordedAt: now,
          result: widget.decision.resultLabel,
          videoUrl: serverVideoUrl,
        ),
      );

      await _apiService.saveCurrentSession();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상 저장이 완료되었습니다.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMoving = false;
        });
      }
    }
  }

  Future<void> _goToMain() async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _isMovingToMain = true;
    });
    try {
      await _apiService.finishCurrentSession();
    } catch (_) {}

    await applyAppScreenOrientation(screenOrientation);
    await waitForAppliedOrientation(context, screenOrientation);

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _resultLandscapeScale(context);
    final Color backgroundColor = _backgroundColorForDecision(widget.decision);
    final String resultText = widget.decision.resultText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 25 * scale),
                Text(
                  resultText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.decision == JudgeDecision.unknown
                        ? 66 * scale
                        : 78 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: widget.decision == JudgeDecision.unknown ? 14 * scale : 0),
                if (widget.decision == JudgeDecision.unknown)
                  Text(
                    '판정 불가',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                SizedBox(height: widget.decision == JudgeDecision.unknown ? 26 * scale : 40 * scale),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ResultIconAction(
                      scale: scale * 0.6,
                      icon: Icons.save_alt_rounded,
                      onPressed: _isMoving ? null : _saveVideoForLater,
                    ),
                    SizedBox(width: 28 * scale),
                    _ResultIconAction(
                      scale: scale * 0.6,
                      icon: Icons.home_rounded,
                      onPressed: _isMoving ? null : _goToMain,
                    ),
                  ],
                ),
                SizedBox(height: 15 * scale),
                _ResultPrimaryButton(
                  scale: scale,
                  label: '계속 플레이',
                  onPressed: _isMoving ? null : _continuePlay,
                ),
                SizedBox(height: 18 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPrimaryButton extends StatelessWidget {
  const _ResultPrimaryButton({
    required this.scale,
    required this.label,
    required this.onPressed,
  });

  final double scale;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      width: 160 * scale,
      height: 50 * scale,
      borderRadius: 999,
      blur: 22,
      backgroundColor: Colors.white.withOpacity(0.78),
      borderColor: Colors.white.withOpacity(0.62),
      shadowColor: Colors.black.withOpacity(0.12),
      shadowBlurRadius: 26 * scale,
      shadowOffset: Offset(0, 12 * scale),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.mainTextDark,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _ResultIconAction extends StatelessWidget {
  const _ResultIconAction({
    required this.scale,
    required this.icon,
    required this.onPressed,
  });

  final double scale;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      width: 68 * scale,
      height: 68 * scale,
      borderRadius: 999,
      blur: 22,
      backgroundColor: Colors.white.withOpacity(0.40),
      borderColor: Colors.white.withOpacity(0.46),
      shadowColor: Colors.black.withOpacity(0.10),
      shadowBlurRadius: 22 * scale,
      shadowOffset: Offset(0, 10 * scale),
      onPressed: onPressed,
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.96),
        size: 34 * scale,
      ),
    );
  }
}

double _resultLandscapeScale(BuildContext context) {
  final Size size = MediaQuery.sizeOf(context);
  return math.min(size.width / 852, size.height / 393)
      .clamp(0.78, 1.25)
      .toDouble();
}

Color _backgroundColorForDecision(JudgeDecision decision) {
  switch (decision) {
    case JudgeDecision.inCall:
      return const Color(0xFF65C93D);
    case JudgeDecision.outCall:
      return const Color(0xFFF24642);
    case JudgeDecision.unknown:
      return const Color(0xFF8C8C8C);
  }
}

String? _nonEmptyString(String? value) {
  final String? trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
