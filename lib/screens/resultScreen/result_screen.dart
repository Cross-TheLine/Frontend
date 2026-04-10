import 'package:flutter/material.dart';
import '../../compo/app_button.dart';
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
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.landscape;

  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _moveToStart();
  }

  Future<void> _moveToStart() async {
    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) {
      return;
    }

    _goToStart();
  }

  void _goToStart() async {
    if (_isMoving) return;
    _isMoving = true;

    await applyAppScreenOrientation(AppScreenOrientation.portrait);
    await waitForAppliedOrientation(context, AppScreenOrientation.portrait);

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
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            children: [
              const Spacer(),
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: AppTextStyles.title(context),
              ),
              SizedBox(height: AppSizes.h(context, 16)),
              Text(
                '3초 후 시작 화면으로 돌아갑니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context),
              ),
              const Spacer(),
              WhiteTextAppButton(
                text: '처음으로',
                variant: AppButtonVariant.secondary,
                onPressed: _goToStart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
