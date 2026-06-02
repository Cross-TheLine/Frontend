import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../compo/app_colors.dart';
import '../compo/app_sizes.dart';
import '../compo/glass_button.dart';
import '../routes.dart';
import '../services/screen_orientation.dart';


class IntroSelectPlayScreen extends StatefulWidget {
  const IntroSelectPlayScreen({super.key});

  @override
  State<IntroSelectPlayScreen> createState() => _IntroSelectPlayScreenState();
}

class _IntroSelectPlayScreenState extends State<IntroSelectPlayScreen>
    with ScreenOrientationMixin<IntroSelectPlayScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  _MatchType? _selectedType;

  void _selectType(_MatchType type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _goNext() {
    if (_selectedType == null) return;
    Navigator.pushNamed(context, AppRoutes.videoGuideline); //이후 intro_guid1로 이동되게 변경
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
          child: Stack(
            children: [
              const Positioned.fill(child: _SelectWatermark()),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.w(context, 24),
                  AppSizes.h(context, 18),
                  AppSizes.w(context, 24),
                  AppSizes.h(context, 32),
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
                    SizedBox(height: AppSizes.h(context, 10)),
                    Text(
                      '경기 방식을\n선택해주세요',
                      style: TextStyle(
                        color: AppColors.mainTextDark,
                        fontSize: AppSizes.sp(context, 30),
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: AppSizes.h(context, 12)),
                    Text(
                      '단식/복식에 따라 판정해야 하는 라인이 달라집니다.',
                      style: TextStyle(
                        color: AppColors.mutedTextDark,
                        fontSize: AppSizes.sp(context, 15),
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: AppSizes.h(context, 38)),
                    _MatchTypeCard(
                      type: _MatchType.singles,
                      selected: _selectedType == _MatchType.singles,
                      onTap: () => _selectType(_MatchType.singles),
                    ),
                    SizedBox(height: AppSizes.h(context, 18)),
                    _MatchTypeCard(
                      type: _MatchType.doubles,
                      selected: _selectedType == _MatchType.doubles,
                      onTap: () => _selectType(_MatchType.doubles),
                    ),
                    const Spacer(),
                    Center(
                      child: GlassButton(
                        width: AppSizes.w(context, 214),
                        height: AppSizes.h(context, 64),
                        backgroundColor: AppColors.accentGreen.withOpacity(0.95),
                        borderColor: Colors.white.withOpacity(0.16),
                        shadowColor: AppColors.accentGreen.withOpacity(0.27),
                        shadowBlurRadius: 34,
                        shadowOffset: const Offset(0, 18),
                        onPressed: _selectedType == null ? null : _goNext,
                        child: Text(
                          '다음',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.sp(context, 16),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MatchType {
  singles(
    korean: '단식',
    english: 'SINGLES',
    description: '사이드라인 안쪽 단식 라인 기준으로 판정합니다.',
    icon: Icons.person_rounded,
  ),
  doubles(
    korean: '복식',
    english: 'DOUBLES',
    description: '바깥쪽 복식 라인까지 포함해서 판정합니다.',
    icon: Icons.people_alt_rounded,
  );

  const _MatchType({
    required this.korean,
    required this.english,
    required this.description,
    required this.icon,
  });

  final String korean;
  final String english;
  final String description;
  final IconData icon;
}

class _MatchTypeCard extends StatelessWidget {
  const _MatchTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final _MatchType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? AppColors.accentGreen.withOpacity(0.74)
        : Colors.white.withOpacity(0.95);
    final Color iconBackground = selected
        ? AppColors.accentGreen.withOpacity(0.12)
        : AppColors.lightBlue;
    final Color iconColor = selected ? AppColors.accentGreen : AppColors.vividBlue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: AppSizes.h(context, 142),
        padding: EdgeInsets.all(AppSizes.w(context, 18)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.96 : 0.86),
          borderRadius: BorderRadius.circular(AppSizes.w(context, 26)),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.accentGreen.withOpacity(0.18)
                  : Colors.black.withOpacity(0.07),
              blurRadius: selected ? 26 : 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.w(context, 66),
              height: AppSizes.w(context, 66),
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                color: iconColor,
                size: AppSizes.sp(context, 34),
              ),
            ),
            SizedBox(width: AppSizes.w(context, 18)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        type.korean,
                        style: TextStyle(
                          color: AppColors.mainTextDark,
                          fontSize: AppSizes.sp(context, 23),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: AppSizes.w(context, 9)),
                      Text(
                        type.english,
                        style: TextStyle(
                          color: AppColors.mutedTextDark,
                          fontSize: AppSizes.sp(context, 12),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h(context, 8)),
                  Text(
                    type.description,
                    style: TextStyle(
                      color: AppColors.mutedTextDark,
                      fontSize: AppSizes.sp(context, 13),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentGreen,
                size: AppSizes.sp(context, 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectWatermark extends StatelessWidget {
  const _SelectWatermark();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Transform.rotate(
          angle: -math.pi / 32,
          child: Padding(
            padding: EdgeInsets.only(bottom: AppSizes.h(context, 142)),
            child: Text(
              'DO NOT CROSS\nTHE LINE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.softWatermark.withOpacity(0.52),
                fontSize: AppSizes.sp(context, 58),
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 0.95,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
