class CameraService {
  bool _isInitialized = false;
  bool _isRecording = false;

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _isInitialized = true;
  }

  Future<void> startRecording() async {
    if (!_isInitialized) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));
    _isRecording = true;
  }

  Future<String> stopRecording() async {
    if (!_isInitialized) {
      return '';
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    _isRecording = false;
    return 'mock_recorded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  Future<void> dispose() async {
    _isInitialized = false;
    _isRecording = false;
  }
}
