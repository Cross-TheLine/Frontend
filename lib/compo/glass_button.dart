import 'dart:ui';

import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 30,
    this.backgroundColor = const Color(0x99FFFFFF),
    this.borderColor = const Color(0xCCFFFFFF),
    this.borderWidth = 1,
    this.blur = 18,
    this.shadowColor = const Color(0x1F000000),
    this.shadowBlurRadius = 28,
    this.shadowOffset = const Offset(0, 14),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double blur;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return Opacity(
      opacity: onPressed == null ? 0.48 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlurRadius,
              offset: shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              width: width,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: radius,
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: radius,
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
