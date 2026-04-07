import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/local_storage_service.dart';

class StartScreen extends StatefulWidget {

  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

// 시작 화면  (아래 위젯들 포함)
class _StartScreenState extends State<StartScreen> { 
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isChecking = false; 

  Future<void> _onStartMatch() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    final bool isFirstLaunch = await _localStorageService.isFirstLaunch(); // 첫 실행 여부 확인
    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    Navigator.pushNamed( // 첫 실행이면 IntroScreen, 아니면 VideoGuidelineScreen으로 이동
      context,
      isFirstLaunch ? AppRoutes.intro : AppRoutes.videoGuideline,
    );
  }

  void _onShowIntro() { // 사용 방법 안내 화면으로 이동
    Navigator.pushNamed(context, AppRoutes.intro);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.startBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;

              final double horizontalPadding = AppSizes.w(context, 28);
              final double ballSize =
                  (screenWidth * 0.62).clamp(220.0, 320.0).toDouble();

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: _StartWatermarkBackground(),
                  ),

                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: screenHeight * 0.11,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선넘네 ?',
                          style: AppTextStyles.whiteL2(context),
                        ),
                        SizedBox(height: AppSizes.h(context, 10)),
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppSizes.w(context, 54),
                          ),
                          child: Text(
                            'no fights anymore',
                            style: AppTextStyles.whiteSi(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    top: screenHeight * 0.34,
                    child: Center(
                      child: _TennisBallStartButton(
                        size: ballSize,
                        isLoading: _isChecking,
                        onTap: _isChecking ? null : _onStartMatch,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSizes.h(context, 28),
                    child: Center(
                      child: _UsageGuideButton(
                        onPressed: _onShowIntro,
                      ),
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

// (Do Not Cross The Line) 배경 텍스트 위젯
class _StartWatermarkBackground extends StatelessWidget {
  const _StartWatermarkBackground();
  @override 
  Widget build(BuildContext context) {
    final List<String> lines = List.generate(
      6,
      (_) => 'DO NOT CROSS THE LINE', //배경 텍스트
    );
    return IgnorePointer(// 배경 텍스트 (Do Not Cross The Line) 터치 이벤트 무시


      child: Padding(
        padding: EdgeInsets.only(top: AppSizes.h(context, 235)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(lines.length, (index) {
            final double leftOffset = index.isEven
                ? -AppSizes.w(context, 86)
                : -AppSizes.w(context, 18);

            return Transform.translate(
              offset: Offset(leftOffset, 0),
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSizes.h(context, 18)),
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
    );
  }
}

// START 버튼 위젯 (테니스공 버튼)
class _TennisBallStartButton extends StatelessWidget {
  final double size;
  final bool isLoading;
  final VoidCallback? onTap;

  const _TennisBallStartButton({
    required this.size,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/tennis_ball.png',
                fit: BoxFit.contain,
              ),
            ),
            if (isLoading)
              SizedBox(
                width: AppSizes.w(context, 30),
                height: AppSizes.w(context, 30),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            else
              Text(
                'START\nMATCH',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteL2(context),
              ),
          ],
        ),
      ),
    );
  }
}

// 사용 방법 안내 버튼 위젯
class _UsageGuideButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UsageGuideButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,

      icon: Icon(
        Icons.search_rounded,
        color: AppColors.mainWhite,
        size: AppSizes.sp(context, 20),
      ),
      label: Text(
        '사용방법  ',
        style: AppTextStyles.whiteS(context),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.helpButtonFill,
        
        side: const BorderSide(
          color: AppColors.helpButtonBorder,
          width: 1,
        ),

        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 10),
          vertical: AppSizes.h(context, 10),
        ),

        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}