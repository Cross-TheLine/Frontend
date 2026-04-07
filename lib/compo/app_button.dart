import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

enum AppButtonVariant {
  primary,
  secondary,
  pillDark,
}

class WhiteTextAppButton extends StatelessWidget {
  const WhiteTextAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isExpanded = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;
    final bool isSecondary = variant == AppButtonVariant.secondary;
    final bool isPillDark = variant == AppButtonVariant.pillDark;

    final Color backgroundColor = isPillDark
        ? const Color(0xFF1F1F1F)
        : isPrimary
            ? AppColors.primary
            : AppColors.surface;

    final Color foregroundColor = isPillDark
        ? Colors.white
        : AppColors.textPrimary;

    final BorderSide side = BorderSide(
      color: isSecondary ? AppColors.border : Colors.transparent,
    );

    final EdgeInsetsGeometry padding = isPillDark
        ? EdgeInsets.symmetric(
            horizontal: AppSizes.w(context, 35),
            vertical: AppSizes.h(context, 14),
          )
        : EdgeInsets.symmetric(
            horizontal: AppSizes.w(context, 16),
            vertical: AppSizes.h(context, 14),
          );

    final double borderRadius = isPillDark
        ? AppSizes.w(context, 30)
        : AppSizes.w(context, 16);

    final TextStyle textStyle = isPillDark
        ? AppTextStyles.body(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          )
        : AppTextStyles.button(context);

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: AppColors.border,
        disabledForegroundColor: isPillDark
            ? Colors.white70
            : AppColors.textPrimary.withOpacity(0.6),
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
      child: Text(
        text,
        style: textStyle,
      ),
    );

    return SizedBox(
      width: isExpanded ? double.infinity : null,
      height: isPillDark ? null : AppSizes.h(context, 56),
      child: button,
    );
  }
}