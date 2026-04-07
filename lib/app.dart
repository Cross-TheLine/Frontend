import 'package:flutter/material.dart';
import 'compo/app_colors.dart';
import 'routes.dart';
import 'screens/mainScreen/intro_screen.dart';
import 'screens/resultScreen/loading_result_screen.dart';
import 'screens/resultScreen/result_screen.dart';
import 'screens/resultScreen/result_skip_screen.dart';
import 'screens/mainScreen/start_screen.dart';
import 'screens/vidScreen/video_guideline_screen.dart';
import 'screens/vidScreen/video_pick_screen.dart';
import 'screens/vidScreen/video_take_screen.dart';

class CrossTheLine extends StatelessWidget {
  const CrossTheLine({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cross The Line',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
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

      // 안내페이지 
      case AppRoutes.intro: 
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
          settings: settings,
        );

      // 회전 가이드
      case AppRoutes.videoGuideline:
        return MaterialPageRoute(
          builder: (_) => const VideoGuidelineScreen(),
          settings: settings,
        );

      //영상 촬영
      case AppRoutes.videoTake:
        return MaterialPageRoute(
          builder: (_) => const VideoTakeScreen(),
          settings: settings,
        );

      // 영상 선택
      case AppRoutes.videoPick:
        return MaterialPageRoute(
          builder: (_) => const VideoPickScreen(),
          settings: settings,
        );
      
      // 판별 중 화면
      case AppRoutes.loadingResult:
        final args = settings.arguments as LoadingResultArgs?;
        return MaterialPageRoute(
          builder: (_) => LoadingResultScreen(
            selectedIndex: args?.selectedIndex ?? 0,
          ),
          settings: settings,
        );
      
      // 판별 결과 화면 (판별 건너뛰기)
      case AppRoutes.resultSkip:
        return MaterialPageRoute(
          builder: (_) => const ResultSkipScreen(),
          settings: settings,
        );

      // 판별 결과 화면 -> in/out 결과에 따라 화면 다름
      case AppRoutes.result:
        final args = settings.arguments as ResultScreenArgs?;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            isIn: args?.isIn ?? true,
          ),
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

// 라우트 없는 경우
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
