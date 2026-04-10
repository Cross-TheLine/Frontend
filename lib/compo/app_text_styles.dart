import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle title(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 30),
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle heading(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 22),
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle body(
    BuildContext context, {
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 16),
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle button(
    BuildContext context, {
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 16),
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle buttonB(
    BuildContext context, {
    Color color = AppColors.mainGray,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 16),
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle caption(
    BuildContext context, {
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 13),
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  //white small, italic
  static TextStyle whiteSi(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 18),
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: AppColors.startSubtitle,
      height: 1.1,
    );
  }

  static TextStyle watermark(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 62),
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: AppColors.startWatermark,
      height: 0.95,
      letterSpacing: -1.0,
    );
  }

  //white 큰거
  static TextStyle whiteL(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 25),
      fontWeight: FontWeight.w800,
      color: AppColors.white,
      height: 1.1,
    );
  }

  //white 큰거
  static TextStyle whiteL2(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 34),
      fontWeight: FontWeight.w800,
      color: AppColors.white,
      height: 1.05,
    );
  }

  static TextStyle whiteL3(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 80),
      fontWeight: FontWeight.w800,
      color: AppColors.white,
      height: 1.1,
    );
  }

  //제일 작은 white (bold)
  static TextStyle whiteS(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 14),
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    );
  }

  //제일 작은 white + not bold
  static TextStyle whiteSs(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 14),
      fontWeight: FontWeight.normal,
      color: AppColors.white,
    );
  }

  static TextStyle whiteM(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 20),
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    );
  }

  //black 중간
  static TextStyle blackM(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 23),
      fontWeight: FontWeight.w800,
      color: AppColors.black,
      height: 1.5,
    );
  }

  //black 중간
  static TextStyle blackMs(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 20),
      fontWeight: FontWeight.w600,
      color: AppColors.black,
      height: 1.0,
    );
  }



  //black 중간
  static TextStyle greys(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 14),
      fontWeight: FontWeight.w400,
      color: AppColors.mainGray,
      height: 1.0,
    );
  }

    static TextStyle blackSi(BuildContext context) {
    return TextStyle(
      fontSize: AppSizes.sp(context, 18),
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: AppColors.pureWhite,
      height: 1.1,
    );
  }
}
