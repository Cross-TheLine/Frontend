class AppRoutes {
  const AppRoutes._();

  static const String start = '/';
  static const String intro = '/intro';
  static const String videoGuideline = '/video-guideline';
  static const String videoTake = '/video-take';
  static const String videoPick = '/video-pick';
  static const String loadingResult = '/loading-result';
  static const String resultSkip = '/result-skip';
  static const String result = '/result';
}

class LoadingResultArgs {
  const LoadingResultArgs({required this.selectedIndex});

  final int selectedIndex;
}

class ResultScreenArgs {
  const ResultScreenArgs({required this.isIn});

  final bool isIn;
}