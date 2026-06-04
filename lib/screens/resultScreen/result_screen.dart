import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/glass_button.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.isIn,
    this.videoPath,
  });

  final bool isIn;
  final String? videoPath;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with ScreenOrientationMixin<ResultScreen> {
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

    // 결과 확인 후 경기를 이어가면 안내 화면을 다시 타지 않고 촬영/라인 판정 화면으로 복귀
    Navigator.pushReplacementNamed(context, AppRoutes.videoTake);
  }

  void _saveVideoForLater() {
    final String? path = widget.videoPath;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          path == null || path.isEmpty
              ? '영상 저장 기능 여기에 연결'
              : '영상저장기능 여기에 연결 \n임시 영상 경로: $path',
        ),
      ),
    );
  }

  Future<void> _goToMain() async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _isMovingToMain = true;
    });
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
    final Color backgroundColor = widget.isIn
        ? AppColors.inResult
        : AppColors.outResult;
    final String resultText = widget.isIn ? 'IN !!!' : 'OUT !!!';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(child: _ResultSoftLight()),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 78 * scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1.2,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      '경기를 계속 플레이할까요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.88),
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 34 * scale),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ResultActionButton(
                          scale: scale,
                          label: '계속 플레이',
                          backgroundColor: Colors.white.withOpacity(0.78),
                          textColor: AppColors.mainTextDark,
                          onPressed: _isMoving ? null : _continuePlay,
                        ),
                        SizedBox(width: 14 * scale),
                        _ResultActionButton(
                          scale: scale,
                          label: '영상 저장하기',
                          backgroundColor: Colors.white.withOpacity(0.58),
                          textColor: AppColors.mainTextDark,
                          onPressed: _isMoving ? null : _saveVideoForLater,
                        ),
                        SizedBox(width: 14 * scale),
                        _ResultActionButton(
                          scale: scale,
                          label: '메인으로',
                          backgroundColor: Colors.black.withOpacity(0.24),
                          borderColor: Colors.white.withOpacity(0.32),
                          textColor: Colors.white,
                          onPressed: _isMoving ? null : _goToMain,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultActionButton extends StatelessWidget {
  const _ResultActionButton({
    required this.scale,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.borderColor,
  });

  final double scale;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      width: 132 * scale,
      height: 48 * scale,
      borderRadius: 999,
      blur: 22,
      backgroundColor: backgroundColor,
      borderColor: borderColor ?? Colors.white.withOpacity(0.62),
      shadowColor: Colors.black.withOpacity(0.12),
      shadowBlurRadius: 26 * scale,
      shadowOffset: Offset(0, 12 * scale),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13.5 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _ResultSoftLight extends StatelessWidget {
  const _ResultSoftLight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.22),
            radius: 0.82,
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0.03),
              Colors.black.withOpacity(0.06),
            ],
          ),
        ),
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
