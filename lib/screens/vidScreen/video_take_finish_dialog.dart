import 'package:flutter/material.dart';

import '../../compo/app_button.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';

enum VideoTakeFinishAction {
  judge, //판별
  skip, //건너뛰기
}

class VideoTakeFinish extends StatelessWidget {
  const VideoTakeFinish({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'IN / OUT을 판별할까요?',
        style: AppTextStyles.whiteM(context),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '방금 촬영한 영상이 IN인지 OUT인지 판별할까요?',
            style: AppTextStyles.body(context),
          ),
          SizedBox(height: AppSizes.h(context, 10)),
          WhiteTextAppButton(
            text: '판별',
            onPressed: () {
              Navigator.of(context).pop(VideoTakeFinishAction.judge);
            },
          ),
          SizedBox(height: AppSizes.h(context, 8)),
          WhiteTextAppButton(
            text: '건너뛰기',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              Navigator.of(context).pop(VideoTakeFinishAction.skip);
            },
          ),
        ],
      ),
    );
  }
}
