import 'package:flutter/material.dart';

import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/api_service.dart';
import '../../services/screen_orientation.dart';

class VideoPickScreen extends StatefulWidget {
  const VideoPickScreen({super.key});

  @override
  State<VideoPickScreen> createState() => _VideoPickScreenState();
}

class _VideoPickScreenState extends State<VideoPickScreen>
    with ScreenOrientationMixin<VideoPickScreen> {
  @override
  AppScreenOrientation get screenOrientation => AppScreenOrientation.landscape;

  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  int _selectedIndex = 0;
  List<String> _candidateVideos = <String>[];

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    final candidateVideos = await _apiService.fetchCandidateVideos();

    if (!mounted) {
      return;
    }

    setState(() {
      _candidateVideos = candidateVideos;
      _isLoading = false;
    });
  }

  void _onStartJudge() {
    Navigator.pushNamed(
      context,
      AppRoutes.loadingResult,
      arguments: LoadingResultArgs(selectedIndex: _selectedIndex),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판별할 영상을 선택해주세요 :)'),
        titleTextStyle: TextStyle(
          color: AppColors.mainWhite,
          fontSize: AppSizes.w(context, 7),
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _candidateVideos.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: AppSizes.h(context, 12)),
                        itemBuilder: (context, index) {
                          final bool isSelected = _selectedIndex == index;

                          return InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSizes.w(context, 20),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(AppSizes.w(context, 16)),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.w(context, 20),
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.mainGreen
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: AppSizes.w(context, 90),
                                    height: AppSizes.h(context, 70),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.w(context, 12),
                                      ),
                                    ),
                                    child: const Icon(Icons.play_arrow),
                                  ),
                                  SizedBox(width: AppSizes.w(context, 16)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _candidateVideos[index],
                                          style: AppTextStyles.whiteS(context),
                                        ),
                                        SizedBox(
                                          height: AppSizes.h(context, 8),
                                        ),
                                        Text(
                                          '썸네일, 재생 길이, 하이라이트 정보 여기에 붙이기',
                                          style: AppTextStyles.caption(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<int>(
                                    value: index,
                                    groupValue: _selectedIndex,
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() {
                                        _selectedIndex = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: AppSizes.h(context, 10)),
              TextAppButton(
                text: '판별 시작하기',
                onPressed: _isLoading ? null : _onStartJudge,
                variant: AppButtonVariant.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
