class AppRoutes {
  const AppRoutes._();

  static const String start = '/';
  static const String main = '/main';
  static const String howToUse = '/how-to-use';
  static const String introSelectPlay = '/intro-select-play';
  static const String introGuid1 = '/intro-guid1';
  static const String introGuid2 = '/intro-guid2';
  static const String savedVideos = '/saved-videos';

  // 기존 촬영/결과 플로우는 신규 intro_guid 흐름 이후 연결용으로 유지합니다.
  static const String intro = '/intro';
  static const String videoGuideline = '/video-guideline';
  static const String videoTake = '/video-take';
  static const String videoPick = '/video-pick';
  static const String loadingResult = '/loading-result';
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

class LoadingResultArgs {
  const LoadingResultArgs({required this.selectedIndex});

  final int selectedIndex;
}

class ResultScreenArgs {
  const ResultScreenArgs({required this.isIn});

  final bool isIn;
}
