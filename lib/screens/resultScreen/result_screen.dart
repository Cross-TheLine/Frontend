import 'dart:math' as math;
import 'dart:ui';

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

      await _showSaveStatusPopup(
        title: '저장 완료',
        message: '판정 영상이 저장되었습니다.',
        icon: Icons.check_rounded,
        iconColor: AppColors.accentGreen,
      );
    } catch (error) {
      if (!mounted) return;

      await _showSaveStatusPopup(
        title: '저장 실패',
        message: error.toString().replaceFirst('Exception: ', ''),
        icon: Icons.priority_high_rounded,
        iconColor: const Color(0xFFF24642),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMoving = false;
        });
      }
    }
  }

  Future<void> _showSaveStatusPopup({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'save-status-popup',
      barrierColor: Colors.black.withOpacity(0.34),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: _SaveStatusGlassPopup(
            title: title,
            message: message,
            icon: icon,
            iconColor: iconColor,
            onConfirm: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final CurvedAnimation curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
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

class _SaveStatusGlassPopup extends StatelessWidget {
  const _SaveStatusGlassPopup({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final double scale = _resultLandscapeScale(context);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28 * scale),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 34 * scale,
                offset: Offset(0, 16 * scale),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30 * scale),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                width: 340 * scale,
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  24 * scale,
                  24 * scale,
                  22 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.74),
                  borderRadius: BorderRadius.circular(30 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.78)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58 * scale,
                      height: 58 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.44),
                        border: Border.all(color: Colors.white.withOpacity(0.72)),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 34 * scale,
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mainTextDark,
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.mutedTextDark,
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 22 * scale),
                    GlassButton(
                      width: 220 * scale,
                      height: 48 * scale,
                      borderRadius: 999,
                      blur: 24,
                      backgroundColor: Colors.white.withOpacity(0.62),
                      borderColor: Colors.white.withOpacity(0.86),
                      shadowColor: Colors.black.withOpacity(0.08),
                      shadowBlurRadius: 22 * scale,
                      shadowOffset: Offset(0, 10 * scale),
                      onPressed: onConfirm,
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: AppColors.mainTextDark,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
