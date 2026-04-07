class ApiService {
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
