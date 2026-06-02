import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../services/screen_orientation.dart';

class SavedVideosScreen extends StatefulWidget {
  const SavedVideosScreen({super.key});

  @override
  State<SavedVideosScreen> createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen>
    with ScreenOrientationMixin<SavedVideosScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.screenWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenWhite,
        body: SafeArea(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            radius: const Radius.circular(99),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSizes.w(context, 24),
                AppSizes.h(context, 22),
                AppSizes.w(context, 28),
                AppSizes.h(context, 28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.mainTextDark,
                      size: AppSizes.sp(context, 24),
                    ),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(
                        AppSizes.w(context, 44),
                        AppSizes.w(context, 44),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  SizedBox(height: AppSizes.h(context, 26)),
                  const _CalendarCard(),
                  SizedBox(height: AppSizes.h(context, 26)),
                  const _SavedVideoItem(
                    title: '2026년 3월 15일 8시 43분',
                    result: 'OUT',
                    variant: 0,
                  ),
                  SizedBox(height: AppSizes.h(context, 24)),
                  const _SavedVideoItem(
                    title: '2026년 3월 12일 7시 18분',
                    result: 'IN',
                    variant: 1,
                  ),
                  SizedBox(height: AppSizes.h(context, 24)),
                  const _SavedVideoItem(
                    title: '2026년 3월 9일 6시 55분',
                    result: 'OUT',
                    variant: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  static const List<String> _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.w(context, 16),
        AppSizes.h(context, 16),
        AppSizes.w(context, 16),
        AppSizes.h(context, 14),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(AppSizes.w(context, 13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'April 2025',
                style: TextStyle(
                  color: AppColors.mainTextDark,
                  fontSize: AppSizes.sp(context, 16),
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: AppSizes.w(context, 2)),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.vividBlue,
                size: AppSizes.sp(context, 24),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.vividBlue,
                size: AppSizes.sp(context, 25),
              ),
              SizedBox(width: AppSizes.w(context, 16)),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.vividBlue,
                size: AppSizes.sp(context, 25),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h(context, 10)),
          LayoutBuilder(
            builder: (context, constraints) {
              final double cellWidth = constraints.maxWidth / 7;
              final List<int?> cells = [
                null,
                null,
                ...List<int>.generate(30, (index) => index + 1),
                null,
                null,
                null,
              ];

              return Column(
                children: [
                  Row(
                    children: _weekdays.map((day) {
                      return SizedBox(
                        width: cellWidth,
                        height: AppSizes.h(context, 26),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              color: const Color(0xFFC5C5C5),
                              fontSize: AppSizes.sp(context, 12),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Wrap(
                    children: cells.map((day) {
                      return SizedBox(
                        width: cellWidth,
                        height: AppSizes.h(context, 48),
                        child: Center(
                          child: day == null
                              ? const SizedBox.shrink()
                              : _CalendarDay(day: day, selected: day == 20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          Divider(
            height: AppSizes.h(context, 18),
            color: const Color(0xFFEDEDED),
          ),
          Row(
            children: [
              Text(
                'Time',
                style: TextStyle(
                  color: AppColors.mainTextDark,
                  fontSize: AppSizes.sp(context, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w(context, 12),
                  vertical: AppSizes.h(context, 7),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '9:41 AM',
                  style: TextStyle(
                    color: AppColors.mainTextDark,
                    fontSize: AppSizes.sp(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({required this.day, required this.selected});

  final int day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color textColor = day == 1 || selected
        ? AppColors.vividBlue
        : AppColors.mainTextDark;

    return Container(
      width: selected ? AppSizes.w(context, 40) : null,
      height: selected ? AppSizes.w(context, 40) : null,
      decoration: selected
          ? const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            )
          : null,
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontSize: AppSizes.sp(context, 20),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SavedVideoItem extends StatelessWidget {
  const _SavedVideoItem({
    required this.title,
    required this.result,
    required this.variant,
  });

  final String title;
  final String result;
  final int variant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: AppSizes.h(context, 176),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.w(context, 7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.w(context, 7)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VideoThumbnailPainter(variant: variant),
                  ),
                ),
                Container(
                  width: AppSizes.w(context, 62),
                  height: AppSizes.w(context, 62),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.58),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: AppSizes.sp(context, 43),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSizes.h(context, 9)),
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: AppSizes.sp(context, 12),
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        Text(
          '결과 : $result',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppSizes.sp(context, 12),
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
      ],
    );
  }
}

class _VideoThumbnailPainter extends CustomPainter {
  const _VideoThumbnailPainter({required this.variant});

  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: variant.isEven
            ? [
                const Color(0xFFE7BE8C),
                const Color(0xFFD49D71),
                const Color(0xFF87AF9B),
              ]
            : [
                const Color(0xFFADB8C8),
                const Color(0xFF8999AE),
                const Color(0xFF82AA8B),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    final Paint crowdPaint = Paint()..color = Colors.white.withOpacity(0.32);
    for (int i = 0; i < 44; i++) {
      final double x = size.width * (i / 44);
      final double y = size.height * (0.18 + (i % 3) * 0.025);
      canvas.drawCircle(Offset(x, y), 3.0, crowdPaint);
    }

    final Paint wallPaint = Paint()..color = const Color(0xFF2F8C78).withOpacity(0.82);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.27, size.width, size.height * 0.16),
      wallPaint,
    );

    final Paint courtFill = Paint()..color = const Color(0xFF4E6DB2).withOpacity(0.88);
    final Path court = Path()
      ..moveTo(0, size.height * 0.50)
      ..lineTo(size.width, size.height * 0.43)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(court, courtFill);

    final Paint outerCourt = Paint()..color = const Color(0xFF74A770).withOpacity(0.84);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.76, size.width, size.height * 0.24),
      outerCourt,
    );

    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.82)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.77),
      Offset(size.width, size.height * 0.69),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height),
      Offset(size.width * 0.50, size.height * 0.46),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height),
      Offset(size.width * 0.42, size.height * 0.47),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.48),
      Offset(size.width * 0.48, size.height),
      linePaint,
    );

    final Paint net = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.50),
      Offset(size.width, size.height * 0.42),
      net,
    );

    _drawPlayer(canvas, size);
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final Paint player = Paint()..color = const Color(0xFF1D2E31).withOpacity(0.92);
    final Offset bodyCenter = Offset(size.width * 0.52, size.height * 0.56);
    canvas.drawCircle(Offset(bodyCenter.dx, bodyCenter.dy - 28), 10, player);
    canvas.drawLine(bodyCenter, Offset(bodyCenter.dx, bodyCenter.dy + 42), player..strokeWidth = 7);
    canvas.drawLine(bodyCenter, Offset(bodyCenter.dx - 34, bodyCenter.dy + 5), player..strokeWidth = 5);
    canvas.drawLine(bodyCenter, Offset(bodyCenter.dx + 34, bodyCenter.dy + 4), player..strokeWidth = 5);
    canvas.drawLine(
      Offset(bodyCenter.dx, bodyCenter.dy + 42),
      Offset(bodyCenter.dx - 20, bodyCenter.dy + 78),
      player..strokeWidth = 6,
    );
    canvas.drawLine(
      Offset(bodyCenter.dx, bodyCenter.dy + 42),
      Offset(bodyCenter.dx + 24, bodyCenter.dy + 76),
      player..strokeWidth = 6,
    );

    final Paint racket = Paint()
      ..color = Colors.white.withOpacity(0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(bodyCenter.dx + 33, bodyCenter.dy + 4),
      Offset(bodyCenter.dx + 58, bodyCenter.dy - 18),
      racket,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bodyCenter.dx + 66, bodyCenter.dy - 26),
        width: 24,
        height: 34,
      ),
      racket,
    );
  }

  @override
  bool shouldRepaint(covariant _VideoThumbnailPainter oldDelegate) {
    return oldDelegate.variant != variant;
  }
}
