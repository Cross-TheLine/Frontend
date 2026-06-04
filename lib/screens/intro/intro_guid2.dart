import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class IntroGuid2Screen extends StatefulWidget {
  const IntroGuid2Screen({super.key});

  @override
  State<IntroGuid2Screen> createState() => _IntroGuid2ScreenState();
}

class _IntroGuid2ScreenState extends State<IntroGuid2Screen>
    with ScreenOrientationMixin<IntroGuid2Screen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  bool _didNavigate = false;
  bool _isLandscapeDetected = false;

  StreamSubscription<NativeDeviceOrientation>? _orientationSub;

  @override
  void initState() {
    super.initState();

    _orientationSub =
        NativeDeviceOrientationCommunicator()
            .onOrientationChanged(useSensor: true)
            .listen((orientation) {
      final bool isLandscape =
          orientation == NativeDeviceOrientation.landscapeLeft ||
          orientation == NativeDeviceOrientation.landscapeRight;

      if (!mounted || _didNavigate) return;

      if (isLandscape) {
        setState(() {
          _isLandscapeDetected = true;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _goNext();
        });
      } else {
        if (_isLandscapeDetected) {
          setState(() {
            _isLandscapeDetected = false;
          });
        }
      }
    });
  }

  void _goNext() {
    if (_didNavigate || !mounted) return;
    _didNavigate = true;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.cameraOrientationHandoff,
    );
  }

  @override
  void dispose() {
    _orientationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainGray,
      appBar: AppBar(
        backgroundColor: AppColors.mainGray,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                _isLandscapeDetected
                    ? '촬영으로 넘어갑니다'
                    : '녹화를 위해 휴대폰을\n가로로 돌려주세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteM(context),
              ),
              SizedBox(height: AppSizes.h(context, 16)),
              Text(
                _isLandscapeDetected
                    ? '촬영 화면으로 이동 중입니다.'
                    : '기기를 실제로 가로로 회전하면 자동으로 다음 화면으로 넘어갑니다 :)',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteSs(context),
              ),
              SizedBox(height: AppSizes.h(context, 50)),
              Center(
                child: SizedBox(
                  width: AppSizes.w(context, 320),
                  child: Lottie.asset(
                    'assets/lottie/rotate_guide.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}