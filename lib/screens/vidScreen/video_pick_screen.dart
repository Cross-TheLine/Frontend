import 'package:flutter/material.dart';

import '../../compo/app_button.dart';
import '../../compo/app_colors.dart';
import '../../compo/app_sizes.dart';
import '../../compo/app_text_styles.dart';
import '../../routes.dart';
import '../../services/api_service.dart';

class VideoPickScreen extends StatefulWidget {
  const VideoPickScreen({super.key});

  @override
  State<VideoPickScreen> createState() => _VideoPickScreenState();
}

class _VideoPickScreenState extends State<VideoPickScreen> {
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
        title: const Text('판별 영상 선택'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '서버에서 받은 후보 영상 중 하나를 선택하세요.',
                style: AppTextStyles.body(context),
              ),
              SizedBox(height: AppSizes.h(context, 16)),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: _candidateVideos.length,
                        separatorBuilder: (_, _) => SizedBox(
                          height: AppSizes.h(context, 12),
                        ),
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
                                      ? AppColors.primary
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _candidateVideos[index],
                                          style: AppTextStyles.whiteS(context),
                                        ),
                                        SizedBox(height: AppSizes.h(context, 8)),
                                        Text(
                                          '현재는 placeholder 카드입니다. 썸네일, 재생 길이, 하이라이트 정보를 여기에 붙이면 됩니다.',
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
              SizedBox(height: AppSizes.h(context, 16)),
              WhiteTextAppButton(
                text: '판별 시작하기',
                onPressed: _isLoading ? null : _onStartJudge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
