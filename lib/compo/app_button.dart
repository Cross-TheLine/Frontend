import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

enum AppButtonVariant { green, white, gray, pillDark, lightgray }

class TextAppButton extends StatelessWidget {
  const TextAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.green,
    this.isExpanded = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isExpanded;

  static const double _defaultRadius = 30;

  @override
  Widget build(BuildContext context) {
    final bool isPillDark = variant == AppButtonVariant.pillDark;

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final Color disabledBackgroundColor;
    late final Color disabledForegroundColor;
    late final BorderSide side;
    late final EdgeInsetsGeometry padding;
    late final double borderRadius;
    late final TextStyle textStyle;

    switch (variant) {
      case AppButtonVariant.green:
        backgroundColor = AppColors.mainGreen;
        foregroundColor = Colors.white;
        disabledBackgroundColor = AppColors.mainGreen.withOpacity(0.45);
        disabledForegroundColor = Colors.white70;
        side = BorderSide.none;
        padding = EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 20),
          vertical: AppSizes.h(context, 25),
        );
        borderRadius = _defaultRadius;
        textStyle = AppTextStyles.button(
          context,
        ).copyWith(color: Colors.white, fontWeight: FontWeight.w600);
        break;

      case AppButtonVariant.white:
        backgroundColor = Colors.white;
        foregroundColor = AppColors.textPrimary;
        disabledBackgroundColor = Colors.white;
        disabledForegroundColor = AppColors.textPrimary.withOpacity(0.4);
        side = BorderSide(color: AppColors.border, width: 1);
        padding = EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 20),
          vertical: AppSizes.h(context, 25),
        );
        borderRadius = _defaultRadius;
        textStyle = AppTextStyles.button(
          context,
        ).copyWith(fontWeight: FontWeight.w600);
        break;

      case AppButtonVariant.gray:
        backgroundColor = AppColors.mainGray;
        foregroundColor = AppColors.textPrimary;
        disabledBackgroundColor = AppColors.border;
        disabledForegroundColor = AppColors.textPrimary.withOpacity(0.4);
        side = BorderSide.none;
        padding = EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 20),
          vertical: AppSizes.h(context, 25),
        );
        borderRadius = _defaultRadius;
        textStyle = AppTextStyles.button(
          context,
        ).copyWith(fontWeight: FontWeight.w600);
        break;

      case AppButtonVariant.pillDark:
        backgroundColor = const Color(0xFF1F1F1F);
        foregroundColor = Colors.white;
        disabledBackgroundColor = AppColors.border;
        disabledForegroundColor = Colors.white70;
        side = BorderSide.none;
        padding = EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 35),
          vertical: AppSizes.h(context, 14),
        );
        borderRadius = _defaultRadius;
        textStyle = AppTextStyles.body(
          context,
        ).copyWith(color: Colors.white, fontWeight: FontWeight.w600);
        break;

      case AppButtonVariant.lightgray:
        backgroundColor = AppColors.lightgray;
        foregroundColor = AppColors.textPrimary;
        disabledBackgroundColor = AppColors.border;
        disabledForegroundColor = AppColors.textPrimary;
        side = BorderSide.none;
        padding = EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 20),
          vertical: AppSizes.h(context, 25),
        );
        borderRadius = _defaultRadius;
        textStyle = AppTextStyles.buttonB(
          context,
        ).copyWith(fontWeight: FontWeight.w600);
        break;
    }

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        disabledForegroundColor: disabledForegroundColor,
        padding: padding,
        tapTargetSize: isPillDark
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        minimumSize: isPillDark ? Size.zero : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: side,
        ),
      ),
      child: Text(text, style: textStyle),
    );

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: isPillDark ? null : (isExpanded ? AppSizes.h(context, 56) : null),
      child: button,
    );
  }
}
