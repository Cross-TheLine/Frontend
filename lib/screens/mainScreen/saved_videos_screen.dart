import 'dart:ui';

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

  late final DateTime _today;
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  late final List<_SavedVideoData> _sampleVideos;

  @override
  void initState() {
    super.initState();

    _today = _dateOnly(DateTime.now());
    _selectedDate = _today;
    _visibleMonth = DateTime(_today.year, _today.month, 1);

    // TODO: 백엔드 연동 후 이 리스트를 API 응답으로 교체하세요.
    // 현재는 오늘 날짜에 예시 영상 1개가 있다고 가정합니다.
    _sampleVideos = <_SavedVideoData>[
      _SavedVideoData(
        id: 'sample-video-01',
        recordedAt: DateTime(
          _today.year,
          _today.month,
          _today.day,
          20,
          43,
        ),
        result: 'OUT',
        thumbnailUrl: null,
        thumbnailAssetPath: null,
        videoUrl: null,
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_SavedVideoData> get _selectedDateVideos {
    return _sampleVideos
        .where((video) => _isSameDate(video.recordedAt, _selectedDate))
        .toList(growable: false);
  }

  Set<String> get _videoDateKeys {
    return _sampleVideos.map((video) => _dateKey(video.recordedAt)).toSet();
  }

  void _goPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateOnly(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_SavedVideoData> selectedVideos = _selectedDateVideos;

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
              const Positioned.fill(child: _SavedVideosSoftBackground()),
              const Positioned.fill(child: _SavedVideosWatermark()),
              Scrollbar(
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
                      _CalendarCard(
                        visibleMonth: _visibleMonth,
                        selectedDate: _selectedDate,
                        today: _today,
                        videoDateKeys: _videoDateKeys,
                        onPreviousMonth: _goPreviousMonth,
                        onNextMonth: _goNextMonth,
                        onDateSelected: _selectDate,
                      ),
                      if (selectedVideos.isNotEmpty) ...[
                        SizedBox(height: AppSizes.h(context, 26)),
                        ...List.generate(selectedVideos.length, (index) {
                          final _SavedVideoData video = selectedVideos[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == selectedVideos.length - 1
                                  ? 0
                                  : AppSizes.h(context, 24),
                            ),
                            child: _SavedVideoItem(video: video),
                          );
                        }),
                      ],
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


class _SavedVideosSoftBackground extends StatelessWidget {
  const _SavedVideosSoftBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.screenWhite,
              Colors.white.withOpacity(0.96),
              const Color(0xFFEAF7F0).withOpacity(0.42),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedVideosWatermark extends StatelessWidget {
  const _SavedVideosWatermark();

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
              color: AppColors.softWatermark.withOpacity(0.32), // ← 더 연하게
              fontSize: AppSizes.sp(context, 72), // ← 크게
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
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.today,
    required this.videoDateKeys,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime today;
  final Set<String> videoDateKeys;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  static const List<String> _weekdays = <String>[
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppSizes.w(context, 18));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: Colors.white.withOpacity(0.72)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.66),
                  Colors.white.withOpacity(0.38),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.w(context, 16),
                AppSizes.h(context, 16),
                AppSizes.w(context, 16),
                AppSizes.h(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${visibleMonth.year}년 ${visibleMonth.month}월',
                        style: TextStyle(
                          color: AppColors.mainTextDark,
                          fontSize: AppSizes.sp(context, 16),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: AppSizes.w(context, 2)),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accentGreen,
                        size: AppSizes.sp(context, 24),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onPreviousMonth,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.accentGreen,
                          size: AppSizes.sp(context, 25),
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size(
                            AppSizes.w(context, 34),
                            AppSizes.w(context, 34),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.w(context, 10)),
                      IconButton(
                        onPressed: onNextMonth,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.accentGreen,
                          size: AppSizes.sp(context, 25),
                        ),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          minimumSize: Size(
                            AppSizes.w(context, 34),
                            AppSizes.w(context, 34),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h(context, 10)),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double cellWidth = constraints.maxWidth / 7;
                      final DateTime firstDay = DateTime(
                        visibleMonth.year,
                        visibleMonth.month,
                        1,
                      );
                      final int leadingEmptyCellCount = firstDay.weekday % 7;
                      final int daysInMonth = DateTime(
                        visibleMonth.year,
                        visibleMonth.month + 1,
                        0,
                      ).day;
                      final int totalCellCount =
                          ((leadingEmptyCellCount + daysInMonth) / 7).ceil() * 7;

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
                            children: List.generate(totalCellCount, (index) {
                              final int day = index - leadingEmptyCellCount + 1;

                              if (day < 1 || day > daysInMonth) {
                                return SizedBox(
                                  width: cellWidth,
                                  height: AppSizes.h(context, 48),
                                );
                              }

                              final DateTime date = DateTime(
                                visibleMonth.year,
                                visibleMonth.month,
                                day,
                              );
                              final bool selected = _isSameDate(date, selectedDate);
                              final bool isToday = _isSameDate(date, today);
                              final bool hasVideo =
                                  videoDateKeys.contains(_dateKey(date));

                              return SizedBox(
                                width: cellWidth,
                                height: AppSizes.h(context, 48),
                                child: Center(
                                  child: _CalendarDay(
                                    day: day,
                                    selected: selected,
                                    isToday: isToday,
                                    hasVideo: hasVideo,
                                    onTap: () => onDateSelected(date),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
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

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.hasVideo,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isToday;
  final bool hasVideo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedBackground = hasVideo
        ? AppColors.accentGreen.withOpacity(0.16)
        : const Color(0xFFE9E9E9).withOpacity(0.92);
    final Color textColor = hasVideo
        ? AppColors.accentGreen
        : selected
            ? const Color(0xFF8A8A8A)
            : AppColors.mainTextDark;
    final Color? todayBorderColor = isToday && !selected
        ? (hasVideo
            ? AppColors.accentGreen.withOpacity(0.34)
            : const Color(0xFFBDBDBD).withOpacity(0.48))
        : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: selected ? AppSizes.w(context, 40) : AppSizes.w(context, 36),
        height: selected ? AppSizes.w(context, 40) : AppSizes.w(context, 36),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : Colors.transparent,
          shape: BoxShape.circle,
          border: todayBorderColor == null
              ? null
              : Border.all(color: todayBorderColor),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: textColor,
              fontSize: AppSizes.sp(context, 20),
              fontWeight: hasVideo || selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedVideoItem extends StatelessWidget {
  const _SavedVideoItem({required this.video});

  final _SavedVideoData video;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SavedVideoThumbnail(video: video),
        SizedBox(height: AppSizes.h(context, 9)),
        Text(
          _formatKoreanDateTime(video.recordedAt),
          style: TextStyle(
            color: Colors.black,
            fontSize: AppSizes.sp(context, 12),
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        Text(
          '결과 : ${video.result}',
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

class _SavedVideoThumbnail extends StatelessWidget {
  const _SavedVideoThumbnail({required this.video});

  final _SavedVideoData video;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Positioned.fill(child: _ThumbnailImage(video: video)),
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
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.video});

  final _SavedVideoData video;

  @override
  Widget build(BuildContext context) {
    final String? thumbnailUrl = video.thumbnailUrl;
    final String? thumbnailAssetPath = video.thumbnailAssetPath;

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ExampleVideoPreview(),
      );
    }

    if (thumbnailAssetPath != null && thumbnailAssetPath.isNotEmpty) {
      return Image.asset(
        thumbnailAssetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ExampleVideoPreview(),
      );
    }

    return const _ExampleVideoPreview();
  }
}

class _ExampleVideoPreview extends StatelessWidget {
  const _ExampleVideoPreview();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F2933),
            const Color(0xFF52616B).withOpacity(0.92),
            const Color(0xFF2C7A5B).withOpacity(0.86),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_rounded,
              color: Colors.white.withOpacity(0.86),
              size: AppSizes.sp(context, 34),
            ),
            SizedBox(height: AppSizes.h(context, 8)),
            Text(
              '예시 영상',
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontSize: AppSizes.sp(context, 13),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedVideoData {
  const _SavedVideoData({
    required this.id,
    required this.recordedAt,
    required this.result,
    this.thumbnailUrl,
    this.thumbnailAssetPath,
    this.videoUrl,
  });

  final String id;
  final DateTime recordedAt;
  final String result;
  final String? thumbnailUrl;
  final String? thumbnailAssetPath;
  final String? videoUrl;
}




DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateKey(DateTime date) {
  final DateTime normalized = _dateOnly(date);
  final String month = normalized.month.toString().padLeft(2, '0');
  final String day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

String _formatKoreanDateTime(DateTime dateTime) {
  return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
      '${dateTime.hour}시 ${dateTime.minute.toString().padLeft(2, '0')}분';
}
