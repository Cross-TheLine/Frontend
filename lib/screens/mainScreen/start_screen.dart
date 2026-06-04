import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with ScreenOrientationMixin<StartScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(seconds: 3), _goToMain);
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.startBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.startBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;
              final double horizontalPadding = AppSizes.w(context, 48);
              (screenWidth * 0.64).clamp(214.0, 320.0).toDouble();

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: _StartWatermarkBackground()),
                  
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: screenHeight * 0.13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선넘네 ?',
                          style: AppTextStyles.whiteL2(context),
                        ),
                        SizedBox(height: AppSizes.h(context, 8)),
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppSizes.w(context, 33),
                          ),
                          child: Text(
                            'no fights anymore',
                            style: AppTextStyles.whiteSi(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StartWatermarkBackground extends StatelessWidget {
  const _StartWatermarkBackground();

  @override
  Widget build(BuildContext context) {
    final List<String> lines = List.generate(
      5,
      (_) => 'DO NOT CROSS THE LINE',
    );

    return IgnorePointer(
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.only(top: AppSizes.h(context, 236)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lines.length, (index) {
              final double leftOffset = index.isEven
                  ? -AppSizes.w(context, 94)
                  : -AppSizes.w(context, 20);

              return Transform.translate(
                offset: Offset(leftOffset, 0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.h(context, 16)),
                  child: Text(
                    lines[index],
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: AppTextStyles.watermark(context),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

