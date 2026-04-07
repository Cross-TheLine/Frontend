import 'dart:math' as math;
import 'package:flutter/material.dart';
// 어플 반응형
class AppSizes {
  const AppSizes._();

  static const double _designWidth = 393;
  static const double _designHeight = 852;

  static double _widthScale(BuildContext context) {
    return MediaQuery.sizeOf(context).width / _designWidth;
  }

  static double _heightScale(BuildContext context) {
    return MediaQuery.sizeOf(context).height / _designHeight;
  }

  static double w(BuildContext context, double size) {
    return size * _widthScale(context);
  }

  static double h(BuildContext context, double size) {
    return size * _heightScale(context);
  }

  static double sp(BuildContext context, double size) {
    final scale = math.min(_widthScale(context), _heightScale(context));
    final clampedScale = scale < 0.85
        ? 0.85
        : (scale > 1.25 ? 1.25 : scale);
    return size * clampedScale;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: w(context, 25),
      vertical: h(context, 20),
    );
  }
}
