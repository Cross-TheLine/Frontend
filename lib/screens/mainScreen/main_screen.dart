import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/glass_button.dart';
import '../../routes.dart';
import '../../services/local_storage_service.dart';
import '../../services/screen_orientation.dart';
import '../marker/marker_download.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with ScreenOrientationMixin<MainScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  final LocalStorageService _localStorageService = LocalStorageService();

  // 백엔드에서 받은 최근 영상 목록 리스트에 매핑
  List<_RecentVideoPreview> _recentVideos = const <_RecentVideoPreview>[];

  bool _isMenuOpen = false;
  bool _isCheckingStart = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _closeMenu() {
    if (!_isMenuOpen) return;
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _openHowToUse() {
    _closeMenu();
    Navigator.pushNamed(context, AppRoutes.howToUse);
  }

  Future<void> _onStartMatch() async {
    if (_isCheckingStart) return;

    setState(() {
      _isCheckingStart = true;
    });

    final bool isFirstLaunch = await _localStorageService.isFirstLaunch();

    if (!mounted) return;

    setState(() {
      _isCheckingStart = false;
    });

    if (isFirstLaunch) {
      Navigator.pushNamed(
        context,
        AppRoutes.howToUse,
        arguments: const HowToUseArgs(
          nextRouteName: AppRoutes.introSelectPlay,
          replaceWithNextRoute: true,
        ),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.introSelectPlay);
  }

  void _openSavedVideos() {
    _closeMenu();
    Navigator.pushNamed(context, AppRoutes.savedVideos);
  }


  void _onMarkerDownload() {
    _closeMenu();
    MarkerDownload.run(context);
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenHeight = constraints.maxHeight;
              final double titleTop = AppSizes.h(context, 52);
              final double menuTop = titleTop + AppSizes.h(context, 58);
              final double previewTop = screenHeight * 0.36;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: _MainWatermarkBackground()),
                  Positioned(
                    top: titleTop,
                    left: AppSizes.w(context, 24),
                    child: Text(
                      '선넘네 ?',
                      style: TextStyle(
                        color: AppColors.mainTextDark,
                        fontSize: AppSizes.sp(context, 38),
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Positioned(
                    top: menuTop,
                    left: AppSizes.w(context, 20),
                    child: _MainMenuButton(onPressed: _toggleMenu),
                  ),
                  
                  
                  // 최근 영상 프리뷰
                  Positioned(
                    top: previewTop, 
                    left: 0,
                    right: 0,
                    child: _VideoPreviewStrip(videos: _recentVideos),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSizes.h(context, 144),
                    child: Center(
                      child: GlassButton(
                        width: AppSizes.w(context, 132),
                        height: AppSizes.h(context, 48),
                        backgroundColor: Colors.white.withOpacity(0.67),
                        borderColor: Colors.white.withOpacity(0.9),
                        shadowColor: Colors.black.withOpacity(0.08),
                        shadowBlurRadius: 25,
                        onPressed: _openHowToUse,
                        child: Text(
                          '사용 방법',
                          style: TextStyle(
                            color: AppColors.mainTextDark,
                            fontSize: AppSizes.sp(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSizes.h(context, 64),
                    child: Center(
                      child: GlassButton(
                        width: AppSizes.w(context, 214),
                        height: AppSizes.h(context, 64),
                        backgroundColor: AppColors.accentGreen.withOpacity(0.95),
                        borderColor: Colors.white.withOpacity(0.16),
                        shadowColor: AppColors.accentGreen.withOpacity(0.28),
                        shadowBlurRadius: 40,
                        shadowOffset: const Offset(0, 18),
                        onPressed: _isCheckingStart ? null : _onStartMatch,
                        child: _isCheckingStart
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
                                'START MATCH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppSizes.sp(context, 16),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (_isMenuOpen)
                    _MenuOverlay(
                      onClose: _closeMenu,
                      onSavedVideos: _openSavedVideos,
                      onMarkerDownload: _onMarkerDownload,
                      onHowToUse: _openHowToUse,
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

class _MainMenuButton extends StatelessWidget {
  const _MainMenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.format_list_bulleted_rounded,
        color: AppColors.mainTextDark,
        size: AppSizes.sp(context, 31),
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: Size(AppSizes.w(context, 42), AppSizes.w(context, 42)),
      ),
    );
  }
}

class _MainWatermarkBackground extends StatelessWidget {
  const _MainWatermarkBackground();

  @override
  Widget build(BuildContext context) {
    final List<String> lines = List.generate(5, (_) => 'DO NOT CROSS THE LINE');

    return IgnorePointer(
      child: ClipRect(
        child: Padding(
          padding: EdgeInsets.only(top: AppSizes.h(context, 245)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lines.length, (index) {
              final double leftOffset = index.isEven
                  ? -AppSizes.w(context, 92)
                  : -AppSizes.w(context, 18);

              return Transform.translate(
                offset: Offset(leftOffset, 0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.h(context, 18)),
                  child: Text(
                    lines[index],
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: AppColors.softWatermark,
                      fontSize: AppSizes.sp(context, 60),
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      height: 0.95,
                      letterSpacing: -1,
                    ),
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

class _RecentVideoPreview {
  const _RecentVideoPreview({
    required this.id,
    this.thumbnailUrl,
    this.videoUrl,
  });

  final String id;
  final String? thumbnailUrl;
  final String? videoUrl;
}

class _VideoPreviewStrip extends StatelessWidget {
  const _VideoPreviewStrip({required this.videos});

  final List<_RecentVideoPreview> videos;

  @override
  Widget build(BuildContext context) {
    final List<_RecentVideoPreview> visibleVideos =
        videos.take(4).toList(growable: false);

    if (visibleVideos.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AppSizes.h(context, 222),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: AppSizes.w(context, 0),
          right: AppSizes.w(context, 28),
        ),
        itemCount: visibleVideos.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSizes.w(context, 22)),
        itemBuilder: (context, index) {
          return _VideoPreviewCard(video: visibleVideos[index]);
        },
      ),
    );
  }
}


// 영상 카드
class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({required this.video});

  final _RecentVideoPreview video;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.w(context, 300),
      height: AppSizes.h(context, 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.w(context, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.w(context, 14)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _VideoThumbnail(thumbnailUrl: video.thumbnailUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.18),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: AppSizes.w(context, 48),
                height: AppSizes.w(context, 48),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.58),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.mainTextDark,
                  size: AppSizes.sp(context, 34),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail({this.thumbnailUrl});

  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = thumbnailUrl;
    if (url == null || url.isEmpty) {
      return const _VideoThumbnailFallback();
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _VideoThumbnailFallback(),
    );
  }
}

class _VideoThumbnailFallback extends StatelessWidget {
  const _VideoThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE9ECEF),
            Color(0xFFD8DDE3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.videocam_outlined,
          color: AppColors.mainTextDark,
          size: AppSizes.sp(context, 34),
        ),
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  const _MenuOverlay({
    required this.onClose,
    required this.onSavedVideos,
    required this.onMarkerDownload,
    required this.onHowToUse,
  });

  final VoidCallback onClose;
  final VoidCallback onSavedVideos;
  final VoidCallback onMarkerDownload;
  final VoidCallback onHowToUse;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: AppSizes.h(context, 58),
            left: 0,
            child: _MenuPanel(
              onSavedVideos: onSavedVideos,
              onMarkerDownload: onMarkerDownload,
              onHowToUse: onHowToUse,
            ),
          ),
        ],
      ),
    );
  }
}


// 메뉴
class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.onSavedVideos,
    required this.onMarkerDownload,
    required this.onHowToUse,
  });

  final VoidCallback onSavedVideos;
  final VoidCallback onMarkerDownload;
  final VoidCallback onHowToUse;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.only(
      topRight: Radius.circular(AppSizes.w(context, 28)),
      bottomRight: Radius.circular(AppSizes.w(context, 28)),
      bottomLeft: Radius.circular(AppSizes.w(context, 16)),
    );

    return Container(
      width: AppSizes.w(context, 260),
      height: AppSizes.h(context, 304),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.78),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withOpacity(0.72)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.w(context, 24),
                AppSizes.h(context, 28),
                AppSizes.w(context, 16),
                AppSizes.h(context, 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_list_bulleted_rounded,
                    color: AppColors.mainTextDark,
                    size: AppSizes.sp(context, 31),
                  ),
                  SizedBox(height: AppSizes.h(context, 54)),
                  _MenuItem(
                    icon: Icons.image_outlined,
                    label: '저장한 영상 전체보기',
                    onTap: onSavedVideos,
                  ),
                  SizedBox(height: AppSizes.h(context, 22)),
                  _MenuItem(
                    icon: Icons.file_download_outlined,
                    label: '마커 다운받기',
                    onTap: onMarkerDownload,
                  ),
                  SizedBox(height: AppSizes.h(context, 22)),
                  _MenuItem(
                    icon: Icons.search_rounded,
                    label: '사용 방법',
                    onTap: onHowToUse,
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




class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w(context, 2),
          vertical: AppSizes.h(context, 4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.mainTextDark,
              size: AppSizes.sp(context, 22),
            ),
            SizedBox(width: AppSizes.w(context, 14)),
            Text(
              label,
              style: TextStyle(
                color: AppColors.mainTextDark,
                fontSize: AppSizes.sp(context, 15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
