import 'package:flutter/material.dart';

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
    with ScreenOrientationMixin<LoadingResultScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.landscape;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSizes.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: AppSizes.h(context, 24)),
                Text('판별 중입니다...', style: AppTextStyles.whiteS(context)),
                SizedBox(height: AppSizes.h(context, 12)),
                Text(
                  '서버 분석이 끝나면 결과 화면으로 이동합니다.',
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
