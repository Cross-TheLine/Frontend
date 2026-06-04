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
                    fontSize: 78 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -1.2,
                  ),
                ),
                SizedBox(height: 40 * scale),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ResultIconAction(
                      scale: scale*0.6,
                      icon: Icons.save_alt_rounded,
   
                      onPressed: _isMoving ? null : _saveVideoForLater,
                    ),
                    SizedBox(width: 28 * scale),
                    _ResultIconAction(
                      scale: scale*0.6,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassButton(
          width: 46 * scale,
          height: 46 * scale,
          borderRadius: 999,
          blur: 22,
          backgroundColor: Colors.white.withOpacity(0.0),
          borderColor: Colors.white.withOpacity(0.46),
          shadowColor: Colors.black.withOpacity(0.10),
          shadowBlurRadius: 22 * scale,
          shadowOffset: Offset(0, 10 * scale),
          onPressed: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22 * scale,
          ),
        ),
      ],
    );
  }
}

double _resultLandscapeScale(BuildContext context) {
  final Size size = MediaQuery.sizeOf(context);
  return math.min(size.width / 852, size.height / 393)
      .clamp(0.78, 1.25)
      .toDouble();
}
