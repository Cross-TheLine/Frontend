import 'dart:ui';

import 'package:flutter/material.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/glass_button.dart';
import 'marker_download_service.dart';

class MarkerDownload {
  static Future<void> run(BuildContext context) async {
    final path = await MarkerDownloadService.saveMarkerImage();

    if (!context.mounted) return;

    final bool isSuccess = path != null;
    final bool savedToDownloadFolder =
        path?.toLowerCase().contains('/download') ?? false;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'marker_download_result',
      barrierColor: Colors.black.withOpacity(0.08),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _MarkerDownloadGlassDialog(
          isSuccess: isSuccess,
          savedToDownloadFolder: savedToDownloadFolder,
          path: path,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _MarkerDownloadGlassDialog extends StatelessWidget {
  const _MarkerDownloadGlassDialog({
    required this.isSuccess,
    required this.savedToDownloadFolder,
    required this.path,
  });

  final bool isSuccess;
  final bool savedToDownloadFolder;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppSizes.w(context, 28));

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.w(context, 28)),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: AppSizes.w(context, 330)),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.76),
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.76),
                      width: 1.2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.84),
                        Colors.white.withOpacity(0.58),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.w(context, 24),
                      AppSizes.h(context, 26),
                      AppSizes.w(context, 24),
                      AppSizes.h(context, 22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                       
                        SizedBox(height: AppSizes.h(context, 18)),
                        Text(
                          isSuccess ? '다운로드 완료' : '저장 실패',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mainTextDark,
                            fontSize: AppSizes.sp(context, 22),
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: AppSizes.h(context, 10)),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mutedTextDark,
                            fontSize: AppSizes.sp(context, 14),
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                        if (isSuccess && path != null) ...[
                          SizedBox(height: AppSizes.h(context, 16)),
                        ],
                        SizedBox(height: AppSizes.h(context, 22)),
                        GlassButton(
                          width: AppSizes.w(context, 126),
                          height: AppSizes.h(context, 48),
                          borderRadius: 999,
                          backgroundColor: isSuccess
                              ? AppColors.accentGreen.withOpacity(0.95)
                              : Colors.white.withOpacity(0.68),
                          borderColor: isSuccess
                              ? Colors.white.withOpacity(0.26)
                              : Colors.white.withOpacity(0.92),
                          shadowColor: isSuccess
                              ? AppColors.accentGreen.withOpacity(0.28)
                              : Colors.black.withOpacity(0.08),
                          shadowBlurRadius: 28,
                          shadowOffset: const Offset(0, 14),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              color: isSuccess
                                  ? Colors.white
                                  : AppColors.mainTextDark,
                              fontSize: AppSizes.sp(context, 15),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _message {
    if (!isSuccess) {
      return '마커 이미지를 저장하지 못했습니다.\n파일 경로와 저장 권한을 확인해주세요.';
    }

    if (savedToDownloadFolder) {
      return '마커 이미지가 다운로드 폴더에 저장되었습니다.';
    }

    return '마커 이미지가 저장되었습니다.';
  }
}



