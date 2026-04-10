import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/screen_orientation.dart';

class LoadingResultScreen extends StatefulWidget {
  const LoadingResultScreen({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  State<LoadingResultScreen> createState() => _LoadingResultScreenState();
}

class _LoadingResultScreenState extends State<LoadingResultScreen>
    with ScreenOrientationMixin<LoadingResultScreen>, TickerProviderStateMixin {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.landscape;

  final ApiService _apiService = ApiService();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _requestJudgeResult();
  }

  Future<void> _requestJudgeResult() async {
    final bool isIn = await _apiService.requestJudgeResult(
      selectedIndex: widget.selectedIndex,
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.result,
      arguments: ResultScreenArgs(isIn: isIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            
            padding: AppSizes.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Center(
                  child: SizedBox(
                    height: AppSizes.w(context, 100),
                    child: Lottie.asset(
                      'assets/lottie/tennis_ball.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration * 1.6;
                        _controller.forward();
                      },
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h(context, 20)),
                Text('판별 중입니다...', style: AppTextStyles.whiteS(context)),
                SizedBox(height: AppSizes.h(context, 12)),
                Text(
                  '테니스 관련 꿀팁',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
