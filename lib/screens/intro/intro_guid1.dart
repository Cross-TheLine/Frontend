import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/glass_button.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';



class IntroGuid1Screen extends StatefulWidget {
  const IntroGuid1Screen({super.key});

  @override
  State<IntroGuid1Screen> createState() => _IntroGuid1ScreenState();
}

class _IntroGuid1ScreenState extends State<IntroGuid1Screen>
    with ScreenOrientationMixin<IntroGuid1Screen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  void _goNext() {
    Navigator.pushNamed(context, AppRoutes.introGuid2);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.screenWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenWhite,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.w(context, 24),
                  AppSizes.h(context, 18),
                  AppSizes.w(context, 24),
                  AppSizes.h(context, 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.mainTextDark,
                        size: AppSizes.sp(context, 24),
                      ),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        minimumSize: Size(
                          AppSizes.w(context, 44),
                          AppSizes.w(context, 44),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    SizedBox(height: AppSizes.h(context, 26)),
                    Text(
                      '라인 판정',
                      style: TextStyle(
                        color: AppColors.mainTextDark,
                        fontSize: AppSizes.sp(context, 30),
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: AppSizes.h(context, 12)),
                    Text(
                      '플레이 중 판정이 필요한 순간에 버튼을 눌러주세요.',
                      style: TextStyle(
                        color: AppColors.mutedTextDark,
                        fontSize: AppSizes.sp(context, 15),
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: _JudgeButtonGuideCard(
                        message: '라인 판정을 받고싶을 때 플레이 중간에 버튼을 눌러주세요!',
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: GlassButton(
                        width: AppSizes.w(context, 214),
                        height: AppSizes.h(context, 64),
                        backgroundColor: AppColors.accentGreen.withOpacity(0.95),
                        borderColor: Colors.white.withOpacity(0.16),
                        shadowColor: AppColors.accentGreen.withOpacity(0.27),
                        shadowBlurRadius: 34,
                        shadowOffset: const Offset(0, 18),
                        onPressed: _goNext,
                        child: Text(
                          '다음',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.sp(context, 16),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
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


class _JudgeButtonGuideCard extends StatelessWidget {
  const _JudgeButtonGuideCard({
    required this.message,
    
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.w(context, 22),
        AppSizes.h(context, 28),
        AppSizes.w(context, 22),
        AppSizes.h(context, 30),
      ),
     
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 손까락 아이콘
          Container(
            width: AppSizes.w(context, 94),
            height: AppSizes.w(context, 94),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGreen.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.86)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: AppColors.accentGreen,
              size: AppSizes.sp(context, 48),
            ),
          ),
          SizedBox(height: AppSizes.h(context, 24)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mainTextDark,
              fontSize: AppSizes.sp(context, 22),
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: AppSizes.h(context, 10)),
          
          SizedBox(height: AppSizes.h(context, 16)),
          Text(
            '버튼을 누른 시점을 기준으로\n라인 판정 후보 구간을 저장합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.mutedTextDark,
              fontSize: AppSizes.sp(context, 13),
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
