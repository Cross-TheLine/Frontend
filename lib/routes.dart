class AppRoutes {
  const AppRoutes._();

  static const String start = '/';
  static const String main = '/main';
  static const String howToUse = '/how-to-use';
  static const String introSelectPlay = '/intro-select-play';
  static const String introGuid1 = '/intro-guid1';
  static const String introGuid2 = '/intro-guid2';
  static const String cameraOrientationHandoff = '/camera-orientation-handoff';
  static const String savedVideos = '/saved-videos';

  static const String intro = '/intro';
  static const String videoGuideline = '/video-guideline';
  static const String videoTake = '/video-take';
  static const String resultSkip = '/result-skip';
  static const String result = '/result';
}

class HowToUseArgs {
  const HowToUseArgs({
    this.nextRouteName,
    this.replaceWithNextRoute = false,
  });

  final String? nextRouteName;
  final bool replaceWithNextRoute;
}

class ResultScreenArgs {
  const ResultScreenArgs({
    required this.isIn,
    this.videoPath,
  });

  final bool isIn;
  final String? videoPath;
}
