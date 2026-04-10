import 'package:flutter/material.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class ResultSkipScreen extends StatefulWidget {
  const ResultSkipScreen({super.key});

  @override
  State<ResultSkipScreen> createState() => _ResultSkipScreenState();
}

class _ResultSkipScreenState extends State<ResultSkipScreen>
    with ScreenOrientationMixin<ResultSkipScreen> {
  bool _isMoving = false;
  bool _isReturningToStart = false;

  @override
  AppScreenOrientation get screenOrientation =>
      _isReturningToStart
          ? AppScreenOrientation.portrait
          : AppScreenOrientation.landscape;

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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSizes.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NO FIGHT !!', style: AppTextStyles.title(context)),
                SizedBox(height: AppSizes.h(context, 12)),
                Text(
                  '판별을 건너뛰었습니다. 잠시 후 시작 화면으로 돌아갑니다.',
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
