import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/saved_video_preview.dart';
import '../../services/saved_video_storage_service.dart';
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
  final SavedVideoStorageService _savedVideoStorageService = SavedVideoStorageService();

  late final DateTime _today;
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  List<_SavedVideoData> _savedVideos = const <_SavedVideoData>[];

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _selectedDate = _today;
    _visibleMonth = DateTime(_today.year, _today.month, 1);
    _loadSavedVideos();
  }

  Future<void> _loadSavedVideos() async {
    final List<SavedVideoRecord> videos = await _savedVideoStorageService.loadVideos();
    if (!mounted) return;

    setState(() {
      _savedVideos = videos
          .where((SavedVideoRecord video) => _hasText(video.videoUrl))
          .map((SavedVideoRecord video) {
        return _SavedVideoData(
          id: video.id,
          recordedAt: video.recordedAt,
          result: video.result,
          thumbnailUrl: video.thumbnailUrl,
          thumbnailAssetPath: video.thumbnailAssetPath,
          videoUrl: video.videoUrl,
        );
      }).toList(growable: false);
    });
  }


  bool _hasText(String? value) {
    final String? trimmed = value?.trim();
    return trimmed != null && trimmed.isNotEmpty;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_SavedVideoData> get _selectedDateVideos {
    return _savedVideos
        .where((video) => _isSameDate(video.recordedAt, _selectedDate))
        .toList(growable: false);
  }

  Set<String> get _videoDateKeys {
    return _savedVideos.map((video) => _dateKey(video.recordedAt)).toSet();
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.screenWhite,
            const Color(0xFFF1F5F3).withOpacity(0.92),
            AppColors.screenWhite,
          ],
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
              color: AppColors.softWatermark.withOpacity(0.28),
              fontSize: AppSizes.sp(context, 64),
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

  static const List<String> _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> cells = _calendarCells(visibleMonth);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.w(context, 18)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSizes.w(context, 18),
            AppSizes.h(context, 18),
            AppSizes.w(context, 18),
            AppSizes.h(context, 18),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(AppSizes.w(context, 18)),
            border: Border.all(color: Colors.white.withOpacity(0.82)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
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
                      fontSize: AppSizes.sp(context, 17),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: AppSizes.w(context, 3)),
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
                      padding: EdgeInsets.zero,
                      minimumSize: Size(AppSizes.w(context, 34), AppSizes.w(context, 34)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: AppSizes.w(context, 8)),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.accentGreen,
                      size: AppSizes.sp(context, 25),
                    ),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(AppSizes.w(context, 34), AppSizes.w(context, 34)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.h(context, 10)),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double cellWidth = constraints.maxWidth / 7;
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
                        children: cells.map((date) {
                          return SizedBox(
                            width: cellWidth,
                            height: AppSizes.h(context, 46),
                            child: Center(
                              child: date == null
                                  ? const SizedBox.shrink()
                                  : _CalendarDay(
                                      date: date,
                                      selected: _isSameDate(date, selectedDate),
                                      hasVideo: videoDateKeys.contains(_dateKey(date)),
                                      isToday: _isSameDate(date, today),
                                      onTap: () => onDateSelected(date),
                                    ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selected,
    required this.hasVideo,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final bool hasVideo;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color selectedBackground = hasVideo
        ? AppColors.accentGreen.withOpacity(0.18)
        : const Color(0xFFE8E8E8);
    final Color textColor = hasVideo
        ? AppColors.accentGreen
        : selected
            ? const Color(0xFF808080)
            : isToday
                ? AppColors.mainTextDark
                : AppColors.mainTextDark;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: selected ? AppSizes.w(context, 40) : AppSizes.w(context, 38),
        height: selected ? AppSizes.w(context, 40) : AppSizes.w(context, 38),
        decoration: selected
            ? BoxDecoration(
                color: selectedBackground,
                shape: BoxShape.circle,
              )
            : null,
        child: Center(
          child: Text(
            '${date.day}',
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
        Container(
          height: AppSizes.h(context, 176),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.w(context, 9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.w(context, 9)),
            child: SavedVideoPreview(
              videoUrl: video.videoUrl,
                  thumbnailUrl: video.thumbnailUrl,
              thumbnailAssetPath: video.thumbnailAssetPath,
            ),
          ),
        ),
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

List<DateTime?> _calendarCells(DateTime month) {
  final DateTime firstDay = DateTime(month.year, month.month, 1);
  final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final int leadingEmptyCells = firstDay.weekday % 7;
  final List<DateTime?> cells = <DateTime?>[
    ...List<DateTime?>.filled(leadingEmptyCells, null),
    ...List<DateTime>.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    ),
  ];

  while (cells.length % 7 != 0) {
    cells.add(null);
  }

  return cells;
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
