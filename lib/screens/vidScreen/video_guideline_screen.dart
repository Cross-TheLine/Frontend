import 'package:flutter/material.dart';
import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';



class VideoGuidelineScreen extends StatelessWidget {
  const VideoGuidelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('촬영 가이드'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.screen_rotation_alt,
                size: AppSizes.w(context, 110),
                color: AppColors.textPrimary,
              ),
              SizedBox(height: AppSizes.h(context, 24)),
              Text(
                '촬영을 위해 휴대폰을 가로로 돌려주세요',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteS(context),
              ),
              SizedBox(height: AppSizes.h(context, 12)),
              Text(
                '현재는 skeleton 단계이므로 실제 회전 감지 대신 버튼으로 다음 단계로 이동합니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(context),
              ),
              const Spacer(),
              WhiteTextAppButton(
                text: '다음으로',
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
