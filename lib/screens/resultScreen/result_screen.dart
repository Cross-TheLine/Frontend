import 'package:flutter/material.dart';
import 'package:frontend/compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.isIn});
  final bool isIn;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with ScreenOrientationMixin<ResultScreen> {
  bool _isMoving = false;
  bool _isReturningToStart = false;

  @override
  AppScreenOrientation get screenOrientation => _isReturningToStart
      ? AppScreenOrientation.portrait
      : AppScreenOrientation.landscape;

  @override
  void initState() {
    super.initState();
    _moveToStart();
  }

  Future<void> _moveToStart() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    //3초 후에  _gotoStart 함수 실행

    if (!mounted) {
      return;
    }
    _goToStart();
  }

  Future<void> _goToStart() async {
    if (_isMoving) return;

    setState(() {
      _isMoving = true;
      _isReturningToStart = true;
    });

    await applyAppScreenOrientation(screenOrientation);
    await waitForAppliedOrientation(context, screenOrientation);

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.start,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.isIn
        ? AppColors.inResult
        : AppColors.outResult;
    final String resultText = widget.isIn ? 'IN !!!' : 'OUT !!!';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteL3(context),
              ),
              SizedBox(height: AppSizes.h(context, 50)),
              Text(
                '3초 후 시작 화면으로 돌아갑니다 :)',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteSs(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
