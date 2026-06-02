import 'package:flutter/material.dart';
import '../../compo/app_button.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/local_storage_service.dart';
import '../../services/screen_orientation.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with ScreenOrientationMixin<IntroScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.portrait;

  final PageController _pageController = PageController();
  final LocalStorageService _localStorageService = LocalStorageService();

  int _currentIndex = 0;

  final List<_IntroPageData> _introItems = const [
    _IntroPageData(
      title: '스마트폰을 ⭐️ 위치에 \n배치해주세요',
      imagePath: 'assets/images/intro1.png',
    ),
    _IntroPageData(
      title: '카메라가 코트의 절반을\n비추도록 “높은곳”에 배치해주세요',
      imagePath: 'assets/images/intro2.png',
    ),
    _IntroPageData(
      title: '카메라 해상도를\n30~60fps로 맞춰주세요',
      imagePath: 'assets/images/intro2.png',
    ),
  ];

  Future<void> _goToVideoGuideline() async {
    await _localStorageService.completeOnboarding();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.videoGuideline);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.w(context, 12)),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _introItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _introItems[index];
                    return Column(
                      children: [
                        SizedBox(height: AppSizes.h(context, 70)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.w(context, 8),
                          ),
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.blackM(context),
                          ),
                        ),
                        SizedBox(height: AppSizes.h(context, 24)),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.contain,
                              width: AppSizes.w(context, 345),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.h(context, 10)),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _introItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSizes.w(context, 4),
                    ),
                    width: _currentIndex == index
                        ? AppSizes.w(context, 14)
                        : AppSizes.w(context, 8),
                    height: AppSizes.w(context, 8),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? const Color(0xFF4A4A4A)
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h(context, 18)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _currentIndex == _introItems.length - 1
                    ? Center(
                        child: TextAppButton(
                          key: const ValueKey('guide_button'),
                          text: '매치 시작하기',
                          variant: AppButtonVariant.pillDark,
                          isExpanded: false,
                          onPressed: _goToVideoGuideline,
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('empty_space'),
                        height: AppSizes.h(context, 52),
                      ),
              ),
              SizedBox(height: AppSizes.h(context, 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPageData {
  const _IntroPageData({required this.title, required this.imagePath});

  final String title;
  final String imagePath;
}
