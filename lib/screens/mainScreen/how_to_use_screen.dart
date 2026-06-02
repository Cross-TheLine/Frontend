import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/glass_button.dart';
import '../../routes.dart';
import '../../services/local_storage_service.dart';
import '../../services/screen_orientation.dart';
import '../marker/marker_download.dart';

class HowToUseScreen extends StatefulWidget {
  const HowToUseScreen({
    super.key,
    this.args = const HowToUseArgs(),
  });

  final HowToUseArgs args;

  @override
  State<HowToUseScreen> createState() => _HowToUseScreenState();
}



// 사용 방법 안내 화면
class _HowToUseScreenState extends State<HowToUseScreen>
    with ScreenOrientationMixin<HowToUseScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  final LocalStorageService _localStorageService = LocalStorageService();
  final Set<String> _checkedStepNumbers = <String>{};

  bool _isSaving = false;

  bool get _isEveryStepChecked {
    return _guideSteps.isNotEmpty &&
        _guideSteps.every(
          (step) => _checkedStepNumbers.contains(step.number),
        );
  }

  void _toggleStep(String stepNumber) {
    setState(() {
      if (_checkedStepNumbers.contains(stepNumber)) {
        _checkedStepNumbers.remove(stepNumber);
      } else {
        _checkedStepNumbers.add(stepNumber);
      }
    });
  }

  void _onMarkerDownload() {
    MarkerDownload.run(context);
  }

  Future<void> _onReady() async {
    if (_isSaving || !_isEveryStepChecked) return;

    setState(() {
      _isSaving = true;
    });

    await _localStorageService.completeOnboarding();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    final String? nextRouteName = widget.args.nextRouteName;
    if (nextRouteName != null) {
      if (widget.args.replaceWithNextRoute) {
        Navigator.pushReplacementNamed(context, nextRouteName);
      } else {
        Navigator.pushNamed(context, nextRouteName);
      }
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _isEveryStepChecked && !_isSaving;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.screenWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenWhite,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _HowToUseWatermark()),
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.w(context, 24),
                    AppSizes.h(context, 18),
                    AppSizes.w(context, 24),
                    AppSizes.h(context, 44),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBackButton(onPressed: () => Navigator.pop(context)),
                      Text(
                        '사용 방법',
                        style: TextStyle(
                          color: AppColors.mainTextDark,
                          fontSize: AppSizes.sp(context, 34),
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: AppSizes.h(context, 10)),
                      Text(
                        '딱 한번만 준비하면 돼요!! ',
                        style: TextStyle(
                          color: AppColors.mutedTextDark,
                          fontSize: AppSizes.sp(context, 15),
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: AppSizes.h(context, 26)),
                      // 가이드 리스트
                      ...List.generate(_guideSteps.length, (index) {
                        final _GuideStepData step = _guideSteps[index];
                        return _GuideStepSection(
                          step: step,
                          isChecked: _checkedStepNumbers.contains(step.number),
                          onCheckPressed: () => _toggleStep(step.number),
                          onMarkerDownloadPressed: _onMarkerDownload,
                        );
                      }),
                      SizedBox(height: AppSizes.h(context, 12)),

                      // 준비완료 버튼
                      Center(
                        child: GlassButton(
                          width: AppSizes.w(context, 218),
                          height: AppSizes.h(context, 60),
                          backgroundColor: _isEveryStepChecked
                              ? AppColors.accentGreen.withOpacity(0.96)
                              : Colors.white.withOpacity(0.70),
                          borderColor: _isEveryStepChecked
                              ? Colors.white.withOpacity(0.16)
                              : Colors.white.withOpacity(0.92),
                          shadowColor: _isEveryStepChecked
                              ? AppColors.accentGreen.withOpacity(0.28)
                              : Colors.black.withOpacity(0.08),
                          shadowBlurRadius: 30,
                          shadowOffset: const Offset(0, 16),
                          onPressed: canSubmit ? _onReady : null,
                          child: _isSaving
                              ? SizedBox(
                                  width: AppSizes.w(context, 22),
                                  height: AppSizes.w(context, 22),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  '준비 완료',
                                  style: TextStyle(
                                    color: _isEveryStepChecked
                                        ? Colors.white
                                        : AppColors.mutedTextDark,
                                    fontSize: AppSizes.sp(context, 16),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: AppSizes.h(context, 20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TopBackButton extends StatelessWidget {
  const _TopBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: AppColors.mainTextDark,
        size: AppSizes.sp(context, 24),
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: Size(AppSizes.w(context, 44), AppSizes.w(context, 44)),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}

class _HowToUseWatermark extends StatelessWidget {
  const _HowToUseWatermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: -0.04,
          child: Text(
            'DO NOT CROSS\nTHE LINE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.softWatermark.withOpacity(0.52),
              fontSize: AppSizes.sp(context, 56),
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 0.95,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
}

// 체크 관리
class _GuideStepSection extends StatelessWidget {
  const _GuideStepSection({
    required this.step,
    required this.isChecked,
    required this.onCheckPressed,
    required this.onMarkerDownloadPressed,
  });

  final _GuideStepData step;
  final bool isChecked;
  final VoidCallback onCheckPressed;
  final VoidCallback onMarkerDownloadPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.h(context, 100),top: AppSizes.h(context, 6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideStepTextPanel(
            number: step.number,
            title: step.title,
            body: step.body,
            isChecked: isChecked,
          ),
          SizedBox(height: AppSizes.h(context, 20)),
          const _MiniCourtGuide(),
          SizedBox(height: AppSizes.h(context, 18)),
          if (step.number == '03') ...[
            Center(
              child: _MarkerDownloadGlassButton(
                onPressed: onMarkerDownloadPressed,
              ),
            ),
            SizedBox(height: AppSizes.h(context, 20)),
          ],
          Center(
            child: _GlassCheckButton(
              isChecked: isChecked,
              onPressed: onCheckPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// 가이드 설명 카드
class _GuideStepTextPanel extends StatelessWidget {
  const _GuideStepTextPanel({
    required this.number,
    required this.title,
    required this.body,
    required this.isChecked,
  });

  final String number;
  final String title;
  final String body;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {

    // 체크 상태에서는 카드 배경색 변경
    final Color panelColor = isChecked
        ? const Color.fromARGB(255, 243, 249, 254).withOpacity(0.96)
        : Colors.white.withOpacity(0.88);
    final Color borderColor = Colors.white.withOpacity(0.94);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(AppSizes.w(context, 18)),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(AppSizes.w(context, 20)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.w(context, 42),
            height: AppSizes.w(context, 42),
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.vividBlue,
                  fontSize: AppSizes.sp(context, 13),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.w(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mainTextDark,
                    fontSize: AppSizes.sp(context, 17),
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: AppSizes.h(context, 8)),
                Text(
                  body,
                  style: TextStyle(
                    color: AppColors.mutedTextDark,
                    fontSize: AppSizes.sp(context, 13),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCourtGuide extends StatelessWidget {
  const _MiniCourtGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.h(context, 196),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.w(context, 22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.w(context, 22)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _GuideCourtPainter()),
            Positioned(
              left: AppSizes.w(context, 28),
              bottom: AppSizes.h(context, 18),
              child: const _CameraPlacementMarker(),
            ),
            Positioned(
              right: AppSizes.w(context, 28),
              bottom: AppSizes.h(context, 18),
              child: const _CameraPlacementMarker(mirrored: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPlacementMarker extends StatelessWidget {
  const _CameraPlacementMarker({this.mirrored = false});

  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final Widget marker = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        SizedBox(height: AppSizes.h(context, 2)),
        Container(
          width: AppSizes.w(context, 24),
          height: AppSizes.h(context, 36),
          decoration: BoxDecoration(
            color: const Color(0xFF111111).withOpacity(0.82),
            borderRadius: BorderRadius.circular(AppSizes.w(context, 6)),
            border: Border.all(color: Colors.white.withOpacity(0.34)),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: AppSizes.w(context, 7),
              height: AppSizes.h(context, 2),
              margin: EdgeInsets.only(top: AppSizes.h(context, 4)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );

    return Transform.rotate(
      angle: mirrored ? 0.08 : -0.08,
      child: marker,
    );
  }
}


//마커 다운 버튼
class _MarkerDownloadGlassButton extends StatelessWidget {
  const _MarkerDownloadGlassButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      width: AppSizes.w(context, 168),
      height: AppSizes.h(context, 44),
      borderRadius: 999,
      backgroundColor: const Color(0xFFE2E2E2).withOpacity(0.68),
      borderColor: Colors.white.withOpacity(0.86),
      shadowColor: Colors.black.withOpacity(0.08),
      shadowBlurRadius: 24,
      shadowOffset: const Offset(0, 12),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.file_download_outlined,
            color: AppColors.mainTextDark,
            size: AppSizes.sp(context, 18),
          ),
          SizedBox(width: AppSizes.w(context, 6)),
          Text(
            '마커 다운받기',
            style: TextStyle(
              color: AppColors.mainTextDark,
              fontSize: AppSizes.sp(context, 13),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// 체크버튼
class _GlassCheckButton extends StatelessWidget {
  const _GlassCheckButton({
    required this.isChecked,
    required this.onPressed,
  });

  final bool isChecked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      width: AppSizes.w(context, 30),
      height: AppSizes.w(context, 30),
      borderRadius: 999,
      backgroundColor: isChecked
          ? AppColors.vividBlue.withOpacity(0.94)
          : Colors.white.withOpacity(0.62),
      borderColor: isChecked
          ? Colors.white.withOpacity(0.34)
          : Colors.white.withOpacity(0.90),
      shadowColor: isChecked
          ? AppColors.vividBlue.withOpacity(0.26)
          : Colors.black.withOpacity(0.08),
      shadowBlurRadius: 34,
      shadowOffset: const Offset(0, 16),
      onPressed: onPressed,
      child: Icon(
        Icons.check_rounded,
        color: isChecked ? Colors.white : AppColors.vividBlue.withOpacity(0.62),
        size: AppSizes.sp(context, 20),
      ),
    );
  }
}

// 코트 페인터
class _GuideCourtPainter extends CustomPainter {
  const _GuideCourtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF95A7B4),
          Color(0xFFB7B1CC),
          Color(0xFF8FA36F),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final Paint lowerRunoff = Paint()
      ..color = const Color(0xFFFF8B8B).withOpacity(0.24);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.58, size.width, size.height * 0.42),
      lowerRunoff,
    );

    final Rect apron = Rect.fromLTWH(
      size.width * 0.12,
      size.height * 0.18,
      size.width * 0.76,
      size.height * 0.58,
    );
    final Paint apronPaint = Paint()
      ..color = const Color(0xFFA7D6A5).withOpacity(0.64);
    canvas.drawRect(apron, apronPaint);

    final Rect court = Rect.fromLTWH(
      size.width * 0.22,
      size.height * 0.18,
      size.width * 0.56,
      size.height * 0.42,
    );
    final Paint courtPaint = Paint()
      ..color = const Color(0xFFC97979).withOpacity(0.72);
    canvas.drawRect(court, courtPaint);

    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawRect(court, linePaint);

    final double leftSingleLine = court.left + court.width * 0.13;
    final double rightSingleLine = court.right - court.width * 0.13;
    final double netY = court.top + court.height * 0.58;
    final double serviceCenterX = court.center.dx;

    canvas.drawLine(
      Offset(leftSingleLine, court.top),
      Offset(leftSingleLine, court.bottom),
      linePaint,
    );
    canvas.drawLine(
      Offset(rightSingleLine, court.top),
      Offset(rightSingleLine, court.bottom),
      linePaint,
    );
    canvas.drawLine(
      Offset(court.left, netY),
      Offset(court.right, netY),
      linePaint,
    );
    canvas.drawLine(
      Offset(serviceCenterX, court.top),
      Offset(serviceCenterX, netY),
      linePaint,
    );

    final Paint centerShadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.00),
          Colors.white.withOpacity(0.32),
          Colors.white.withOpacity(0.00),
        ],
      ).createShader(Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.60,
        size.width * 0.04,
        size.height * 0.34,
      ));
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.48,
        size.height * 0.60,
        size.width * 0.04,
        size.height * 0.34,
      ),
      centerShadow,
    );

    final Paint hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.20),
          Colors.white.withOpacity(0.02),
          Colors.black.withOpacity(0.06),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, hazePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




// 각 가이드 설명데이터
class _GuideStepData {
  const _GuideStepData({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;
}
const List<_GuideStepData> _guideSteps = [
  _GuideStepData(
    number: '01',
    title: '스마트폰 배치',
    body: '아래 그림처럼 배치해주세요. 반쪽 코트의 절반이 화면에 들어오면 판정이 정확해집니다.',
  ),
  _GuideStepData(
    number: '02',
    title: '카메라 높이 조절',
    body: '160cm~180cm 정도의 높이에 배치하는 것을 권장드립니다.',
  ),
  _GuideStepData(
    number: '03',
    title: '마커 준비',
    body: '마커를 다운받고 인쇄해주세요. 마커를 사용하면 판정이 더 정확해집니다.',
  ),
  _GuideStepData(
    number: '04',
    title: '마커 부착',
    body: '마커를 아래 사진과같이 라인에 붙어주세요. 꼭짓점을 맞춰주는게 중요합니다.',
  ),
  _GuideStepData(
    number: '05',
    title: '최종 카메라 조정',
    body: '마커가 화면에 잘 보이는지,확인해주세요',
  ),
];
