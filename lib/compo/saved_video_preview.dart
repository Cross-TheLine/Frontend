import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class SavedVideoPreview extends StatefulWidget {
  const SavedVideoPreview({
    super.key,
    this.videoUrl,
    this.videoPath,
    this.thumbnailUrl,
    this.thumbnailAssetPath,
    this.fit = BoxFit.cover,
    this.showPlayButton = true,
  });

  final String? videoUrl;
  final String? videoPath;
  final String? thumbnailUrl;
  final String? thumbnailAssetPath;
  final BoxFit fit;
  final bool showPlayButton;

  @override
  State<SavedVideoPreview> createState() => _SavedVideoPreviewState();
}

class _SavedVideoPreviewState extends State<SavedVideoPreview> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _hasError = false;

  String? get _source {
    final String? url = _clean(widget.videoUrl);
    if (url != null) return url;
    return _clean(widget.videoPath);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant SavedVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? oldSource = _clean(oldWidget.videoUrl) ?? _clean(oldWidget.videoPath);
    if (oldSource != _source) {
      _disposeController();
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final String? source = _source;
    if (source == null) return;

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final Uri? uri = Uri.tryParse(source);
      final VideoPlayerController controller;

      if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
        controller = VideoPlayerController.networkUrl(uri);
      } else {
        controller = VideoPlayerController.file(File(source));
      }

      _controller = controller;
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      _disposeController();
      setState(() {
        _isInitializing = false;
        _hasError = true;
      });
    }
  }

  Future<void> _togglePlay() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (!mounted) return;
    setState(() {});
  }

  void _disposeController() {
    final VideoPlayerController? controller = _controller;
    _controller = null;
    controller?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;
    final bool canShowVideo = controller != null && controller.value.isInitialized && !_hasError;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (canShowVideo)
            _VideoSurface(
              controller: controller,
              fit: widget.fit,
            )
          else
            _ThumbnailFallback(
              thumbnailUrl: widget.thumbnailUrl,
              thumbnailAssetPath: widget.thumbnailAssetPath,
              isLoading: _isInitializing,
              hasError: _hasError,
            ),
          if (widget.showPlayButton)
            _PlayOverlay(
              isPlaying: controller?.value.isPlaying ?? false,
              isLoading: _isInitializing,
            ),
        ],
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.controller,
    required this.fit,
  });

  final VideoPlayerController controller;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Size videoSize = controller.value.size;
    final double width = videoSize.width <= 0 ? 16 : videoSize.width;
    final double height = videoSize.height <= 0 ? 9 : videoSize.height;

    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: width,
        height: height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({
    this.thumbnailUrl,
    this.thumbnailAssetPath,
    required this.isLoading,
    required this.hasError,
  });

  final String? thumbnailUrl;
  final String? thumbnailAssetPath;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final String? cleanThumbnailUrl = _clean(thumbnailUrl);
    final String? cleanThumbnailAssetPath = _clean(thumbnailAssetPath);

    if (cleanThumbnailUrl != null) {
      return Image.network(
        cleanThumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackBody(isLoading: isLoading, hasError: hasError),
      );
    }

    if (cleanThumbnailAssetPath != null) {
      return Image.asset(
        cleanThumbnailAssetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackBody(isLoading: isLoading, hasError: hasError),
      );
    }

    return _FallbackBody(isLoading: isLoading, hasError: hasError);
  }
}

class _FallbackBody extends StatelessWidget {
  const _FallbackBody({required this.isLoading, required this.hasError});

  final bool isLoading;
  final bool hasError;

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
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasError ? Icons.error_outline_rounded : Icons.videocam_rounded,
                    color: Colors.white.withOpacity(0.86),
                    size: AppSizes.sp(context, 34),
                  ),
                  SizedBox(height: AppSizes.h(context, 8)),
                  Text(
                    hasError ? '영상을 불러오지 못했습니다' : '저장된 영상',
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

class _PlayOverlay extends StatelessWidget {
  const _PlayOverlay({
    required this.isPlaying,
    required this.isLoading,
  });

  final bool isPlaying;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isPlaying ? 0.0 : 1.0,
        child: Container(
          width: AppSizes.w(context, 58),
          height: AppSizes.w(context, 58),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.62),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.62)),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.mainTextDark,
            size: AppSizes.sp(context, 42),
          ),
        ),
      ),
    );
  }
}

String? _clean(String? value) {
  final String? trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
