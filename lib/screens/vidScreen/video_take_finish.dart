import 'package:flutter/material.dart';

import '../../compo/app_button.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';

enum VideoTakeFinishAction {
  judge,
  skip,
}

class VideoTakeFinish extends StatelessWidget {
  const VideoTakeFinish({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'IN / OUT을 판별할까요?',
        style: AppTextStyles.whiteS(context),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '촬영한 영상을 판별할지, 아니면 건너뛸지 선택하는 단계입니다.',
            style: AppTextStyles.body(context),
          ),
          SizedBox(height: AppSizes.h(context, 20)),
          WhiteTextAppButton(
            text: '판별',
            onPressed: () {
              Navigator.of(context).pop(VideoTakeFinishAction.judge);
            },
          ),
          SizedBox(height: AppSizes.h(context, 12)),
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
