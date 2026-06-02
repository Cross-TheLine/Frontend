import 'package:flutter/material.dart';

import 'compo/app_colors.dart';
import 'routes.dart';
import 'screens/mainScreen/how_to_use_screen.dart';
import 'intro/intro_select_play.dart';
import 'screens/mainScreen/main_screen.dart';
import 'screens/mainScreen/saved_videos_screen.dart';
import 'screens/mainScreen/start_screen.dart';
import 'screens/resultScreen/loading_result_screen.dart';
import 'screens/resultScreen/result_screen.dart';
import 'screens/resultScreen/result_skip_screen.dart';
import 'intro/intro_guid2.dart';
import 'screens/vidScreen/video_pick_screen.dart';
import 'screens/vidScreen/video_take_screen.dart';
import 'services/screen_orientation.dart';

class CrossTheLine extends StatelessWidget {
  const CrossTheLine({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cross The Line',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.screenWhite,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentGreen,
          brightness: Brightness.light,
        ),
        fontFamily: null,
      ),
      navigatorObservers: [appRouteObserver],
      initialRoute: AppRoutes.start,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.start:
        return MaterialPageRoute(
          builder: (_) => const StartScreen(),
          settings: settings,
        );

      case AppRoutes.main:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case AppRoutes.howToUse:
        final HowToUseArgs args = settings.arguments is HowToUseArgs
            ? settings.arguments as HowToUseArgs
            : const HowToUseArgs();
        return MaterialPageRoute(
          builder: (_) => HowToUseScreen(args: args),
          settings: settings,
        );

      case AppRoutes.intro:
        return MaterialPageRoute(
          builder: (_) => const HowToUseScreen(
            args: HowToUseArgs(
              nextRouteName: AppRoutes.introSelectPlay,
              replaceWithNextRoute: true,
            ),
          ),
          settings: settings,
        );

      case AppRoutes.introSelectPlay:
        return MaterialPageRoute(
          builder: (_) => const IntroSelectPlayScreen(),
          settings: settings,
        );

      case AppRoutes.savedVideos:
        return MaterialPageRoute(
          builder: (_) => const SavedVideosScreen(),
          settings: settings,
        );

      case AppRoutes.videoGuideline:
        return MaterialPageRoute(
          builder: (_) => const VideoGuidelineScreen(),
          settings: settings,
        );

      case AppRoutes.videoTake:
        return MaterialPageRoute(
          builder: (_) => const VideoTakeScreen(),
          settings: settings,
        );

      case AppRoutes.videoPick:
        return MaterialPageRoute(
          builder: (_) => const VideoPickScreen(),
          settings: settings,
        );

      case AppRoutes.loadingResult:
        final LoadingResultArgs? args = settings.arguments is LoadingResultArgs
            ? settings.arguments as LoadingResultArgs
            : null;
        return MaterialPageRoute(
          builder: (_) => LoadingResultScreen(
            selectedIndex: args?.selectedIndex ?? 0,
          ),
          settings: settings,
        );

      case AppRoutes.resultSkip:
        return MaterialPageRoute(
          builder: (_) => const ResultSkipScreen(),
          settings: settings,
        );

      case AppRoutes.result:
        final ResultScreenArgs? args = settings.arguments is ResultScreenArgs
            ? settings.arguments as ResultScreenArgs
            : null;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(isIn: args?.isIn ?? true),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _UnknownRouteScreen(),
          settings: settings,
        );
    }
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Route not found'),
      ),
    );
  }
}
