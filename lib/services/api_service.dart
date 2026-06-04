class ApiService {
  /// 라인/마커 검출 :  1회 프레임 캡처 → 백엔드 요청
  ///

  /// 추후 : 이미지 경로 -> multipart/form-data로 업로드하고 서버의 detected 값을 그대로 매핑
  Future<LineDetectionResult> requestLineDetection({
    required String imagePath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 950));

    // 백엔드랑 연결하고 mock 제거
    return const LineDetectionResult(
      detected: true,
      message: '마커와 라인을 인식했습니다.',
    );
  }

  Future<bool> requestJudgeByMarkerEvent({
    required String videoPath,
    required DateTime pressedAt,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    // 여기에 백엔드 응답으로 교체하기
    return pressedAt.second.isEven;
  }

  Future<List<String>> fetchCandidateVideos() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return List<String>.generate(
      4,
      (index) => '후보 영상 ${index + 1}',
    );
  }
  @Deprecated('loading_result_screen 제거 후 requestJudgeByMarkerEvent를 사용하세요.')
  Future<bool> requestJudgeResult({required int selectedIndex}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return selectedIndex.isEven;
  }
}

class LineDetectionResult {
  const LineDetectionResult({
    required this.detected,
    required this.message,
  });

  final bool detected;
  final String message;
}
