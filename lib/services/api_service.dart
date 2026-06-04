class ApiService {
  /// 백엔드 라인/마커 검출 API  - 확인용 mock 응답 반환함

  /// imagePath 파일 -> multipart/form-data로 전송하고, 서버가 반환한 정규화 좌표 -> 아래 LineDetectionResult 형태로 매핑하기
  Future<LineDetectionResult> requestLineDetection({
    required String imagePath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 950));

    return const LineDetectionResult(
      detected: true,
      message: '마커와 라인을 인식했습니다.',
      redLine: NormalizedLineSegment(
        startX: 0.27,
        startY: 0.58,
        endX: 0.50,
        endY: 0.73,
      ),
      blueLine: NormalizedLineSegment(
        startX: 0.50,
        startY: 0.73,
        endX: 0.70,
        endY: 0.55,
      ),
    );
  }

  /// 판정 버튼을 누른 순간의 영상/타임스탬프를 서버로 보내기
  Future<bool> requestJudgeByMarkerEvent({
    required String videoPath,
    required DateTime pressedAt,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return pressedAt.second.isEven;
  }

  Future<List<String>> fetchCandidateVideos() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return List<String>.generate(
      4,
      (index) => '후보 영상 ${index + 1}',
    );
  }

  Future<bool> requestJudgeResult({required int selectedIndex}) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return selectedIndex.isEven;
  }
}

class LineDetectionResult {
  const LineDetectionResult({
    required this.detected,
    required this.message,
    this.redLine,
    this.blueLine,
  });

  final bool detected;
  final String message;
  final NormalizedLineSegment? redLine;
  final NormalizedLineSegment? blueLine;

  bool get hasOverlay => detected && redLine != null && blueLine != null;
}

class NormalizedLineSegment {
  const NormalizedLineSegment({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });

  final double startX;
  final double startY;
  final double endX;
  final double endY;
}
