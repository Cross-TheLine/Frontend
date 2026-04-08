import 'package:flutter/material.dart';
import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import 'package:lottie/lottie.dart';

class VideoGuidelineScreen extends StatelessWidget {
  const VideoGuidelineScreen({super.key});

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
                '녹화를 위해 휴대폰을\n가로로 돌려주세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteM(context),
              ),
              SizedBox(height: AppSizes.h(context, 50)),

              Center( // 회전 애니메이션
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

              // 테스트용 넘어가기 버튼
              WhiteTextAppButton(
                text: '넘어가기(테스트용)',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.videoTake);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
