import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;

  void _log(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) return;
    // ignore: avoid_print
    print('[CTL CAMERA] $message');
  }

  Future<void> initialize() async {
    if (_isInitialized && _controller?.value.isInitialized == true) {
      return;
    }

    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw const CameraServiceException('사용 가능한 카메라가 없습니다.');
    }

    final CameraDescription selectedCamera = _selectCamera(cameras);
    _log('selected camera name=${selectedCamera.name}, lens=${selectedCamera.lensDirection}');

    final CameraController controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();
    _log('controller initialized, previewSize=${controller.value.previewSize}');
    await controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);

    _controller = controller;
    _isInitialized = true;
  }

  CameraDescription _selectCamera(List<CameraDescription> cameras) {
    const String preferredLens = String.fromEnvironment(
      'CTL_CAMERA_LENS',
      defaultValue: 'back',
    );

    final String normalized = preferredLens.toLowerCase().trim();
    if (normalized == 'first') return cameras.first;

    CameraLensDirection? direction;
    if (normalized == 'front') {
      direction = CameraLensDirection.front;
    } else if (normalized == 'external') {
      direction = CameraLensDirection.external;
    } else {
      direction = CameraLensDirection.back;
    }

    return cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == direction,
      orElse: () => cameras.first,
    );
  }

  Future<XFile> captureFrame() async {
    final CameraController controller = _requireController();

    if (_isRecording || controller.value.isRecordingVideo) {
      throw const CameraServiceException('녹화 중에는 라인 검출용 프레임을 캡처할 수 없습니다.');
    }

    final XFile frame = await controller.takePicture();
    _log('capture frame path=${frame.path}');
    return frame;
  }

  Future<void> startRecording() async {
    final CameraController controller = _requireController();

    if (_isRecording || controller.value.isRecordingVideo) {
      return;
    }

    await controller.startVideoRecording();
    _isRecording = true;
    _log('video recording started');
  }

  Future<String> stopRecording() async {
    final CameraController controller = _requireController();

    if (!_isRecording && !controller.value.isRecordingVideo) {
      return '';
    }

    final XFile video = await controller.stopVideoRecording();
    _isRecording = false;
    _log('video recording stopped path=${video.path}');
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
    _log('controller disposed');
  }
}

class CameraServiceException implements Exception {
  const CameraServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
