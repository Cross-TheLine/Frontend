import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  Future<void> initialize() async {
    if (_isInitialized && _controller?.value.isInitialized == true) {
      return;
    }

    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw const CameraServiceException('사용 가능한 카메라가 없습니다.');
    }

    final CameraDescription selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    await controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);

    _controller = controller;
    _isInitialized = true;
  }

  Future<XFile> captureFrame() async {
    final CameraController controller = _requireController();

    if (_isRecording || controller.value.isRecordingVideo) {
      throw const CameraServiceException('녹화 중에는 라인 검출용 프레임을 캡처할 수 없습니다.');
    }

    return controller.takePicture();
  }

  Future<void> startRecording() async {
    final CameraController controller = _requireController();

    if (_isRecording || controller.value.isRecordingVideo) {
      return;
    }

    await controller.startVideoRecording();
    _isRecording = true;
  }

  Future<String> stopRecording() async {
    final CameraController controller = _requireController();

    if (!_isRecording && !controller.value.isRecordingVideo) {
      return '';
    }

    final XFile video = await controller.stopVideoRecording();
    _isRecording = false;
    return video.path;
  }

  CameraController _requireController() {
    final CameraController? controller = _controller;
    if (!_isInitialized || controller == null || !controller.value.isInitialized) {
      throw const CameraServiceException('카메라가 아직 준비되지 않았습니다.');
    }
    return controller;
  }

  Future<void> dispose() async {
    final CameraController? controller = _controller;

    _controller = null;
    _isInitialized = false;
    _isRecording = false;

    await controller?.dispose();
  }
}

class CameraServiceException implements Exception {
  const CameraServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
