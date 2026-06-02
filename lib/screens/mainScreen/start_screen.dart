import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/screen_orientation.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with ScreenOrientationMixin<StartScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  void _goToMain() {
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.startBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.startBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;
              final double horizontalPadding = AppSizes.w(context, 48);
              final double ballSize =
                  (screenWidth * 0.64).clamp(214.0, 320.0).toDouble();

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: _StartWatermarkBackground()),
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: screenHeight * 0.13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '선넘네 ?',
                          style: AppTextStyles.whiteL2(context),
                        ),
                        SizedBox(height: AppSizes.h(context, 8)),
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppSizes.w(context, 33),
                          ),
                          child: Text(
                            'no fights anymore',
                            style: AppTextStyles.whiteSi(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: screenHeight * 0.36,
                    child: Center(
                      child: _TennisBallStartButton(
                        size: ballSize,
                        onTap: _goToMain,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StartWatermarkBackground extends StatelessWidget {
  const _StartWatermarkBackground();

  @override
  Widget build(BuildContext context) {
    final List<String> lines = List.generate(
      7,
      (_) => 'DO NOT CROSS THE LINE',
    );

    return IgnorePointer(
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.only(top: AppSizes.h(context, 236)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lines.length, (index) {
              final double leftOffset = index.isEven
                  ? -AppSizes.w(context, 94)
                  : -AppSizes.w(context, 20);

              return Transform.translate(
                offset: Offset(leftOffset, 0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.h(context, 16)),
                  child: Text(
                    lines[index],
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: AppTextStyles.watermark(context),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TennisBallStartButton extends StatelessWidget {
  const _TennisBallStartButton({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/tennis_ball.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const _FallbackTennisBall(),
              ),
            ),
            Text(
              'START\nMATCH',
              textAlign: TextAlign.center,
              style: AppTextStyles.whiteL2(context).copyWith(
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackTennisBall extends StatelessWidget {
  const _FallbackTennisBall();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TennisBallPainter(),
    );
  }
}

class _TennisBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint ballPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: [
          const Color(0xFFFFFF71),
          const Color(0xFFD9F132),
          const Color(0xFF95B900),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.96, ballPaint);

    final Paint seamPaint = Paint()
      ..color = Colors.white.withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.055
      ..strokeCap = StrokeCap.round;

    final Path leftSeam = Path()
      ..moveTo(center.dx - radius * 0.9, center.dy - radius * 0.2)
      ..cubicTo(
        center.dx - radius * 0.35,
        center.dy - radius * 0.55,
        center.dx - radius * 0.2,
        center.dy - radius * 0.15,
        center.dx - radius * 0.08,
        center.dy + radius * 0.35,
      );
    final Path rightSeam = Path()
      ..moveTo(center.dx + radius * 0.88, center.dy + radius * 0.22)
      ..cubicTo(
        center.dx + radius * 0.35,
        center.dy + radius * 0.55,
        center.dx + radius * 0.22,
        center.dy + radius * 0.15,
        center.dx + radius * 0.08,
        center.dy - radius * 0.35,
      );

    canvas.drawPath(leftSeam, seamPaint);
    canvas.drawPath(rightSeam, seamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
