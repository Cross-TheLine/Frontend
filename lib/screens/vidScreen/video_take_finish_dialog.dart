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
      
      backgroundColor: const Color.fromARGB(255, 234, 234, 234),
      title: Text('IN / OUT을 판별할까요?',
      style: AppTextStyles.blackMs(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '두구두구 과연!!!',
            style: AppTextStyles.greys(context),
          ),
          SizedBox(height: AppSizes.h(context, 50)),
          TextAppButton(
            text: '판별',
            variant: AppButtonVariant.green,
            
            onPressed: () {
              Navigator.of(context).pop(VideoTakeFinishAction.judge);
            },
          ),
          TextAppButton(
            text: '건너뛰기',
            variant: AppButtonVariant.lightgray,
            onPressed: () {
              Navigator.of(context).pop(VideoTakeFinishAction.skip);
            },
          ),
        ],
      ),
    );
  }
}
