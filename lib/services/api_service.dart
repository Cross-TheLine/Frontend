import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

class ApiService {
  factory ApiService() => _instance;

  ApiService._();

  static final ApiService _instance = ApiService._();

  static const String baseUrl = String.fromEnvironment(
    'CTL_API_BASE_URL',
    defaultValue: 'https://superpowered-giselle-lacerant.ngrok-free.dev',
  );

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 12);

  SessionInfo? _session;
  Future<SessionInfo>? _sessionFuture;
  String? _recordingPath;
  String? _courtConfigPath;
  String? _configImage;
  String? _lastJudgeClipPath;
  String? _lastJudgeClipUrl;
  int _configIndex = 0;

  String? get currentSessionId => _session?.sessionId;
  String? get currentRecordingPath => _recordingPath;
  String? get currentJudgeClipPath => _lastJudgeClipPath;
  String? get currentJudgeClipUrl => _lastJudgeClipUrl;

  void _log(String message) {
    if (const bool.fromEnvironment('dart.vm.product')) return;
    // ignore: avoid_print
    print('[CTL API] $message');
  }

  Future<SessionInfo> ensureSession({String cameraLabel = 'flutter_camera'}) async {
    final SessionInfo? current = _session;
    if (current != null) return current;

    final Future<SessionInfo>? pending = _sessionFuture;
    if (pending != null) return pending;

    final Future<SessionInfo> future = startSession(cameraLabel: cameraLabel);
    _sessionFuture = future;

    try {
      return await future;
    } finally {
      _sessionFuture = null;
    }
  }

  Future<SessionInfo> startSession({String cameraLabel = 'flutter_camera'}) async {
    _log('start session camera_label=$cameraLabel');
    final dynamic response = await _postJson(
      '/sessions/start',
      body: <String, dynamic>{
        'camera_label': cameraLabel,
      },
    );

    final Map<String, dynamic> map = _asMap(response);
    final String sessionId = _findString(map, const <String>[
      'session_id',
      'sessionId',
      'id',
    ]) ?? '';

    if (sessionId.isEmpty) {
      throw const ApiServiceException('세션 ID를 받지 못했습니다.');
    }

    final SessionInfo session = SessionInfo(
      sessionId: sessionId,
      status: _findString(map, const <String>['status']) ?? '',
      cameraLabel: _findString(map, const <String>['camera_label', 'cameraLabel']) ?? cameraLabel,
      recordingPath: _findString(map, const <String>['recording_path', 'recordingPath']),
    );

    _session = session;
    _recordingPath = session.recordingPath;
    _lastJudgeClipPath = null;
    _lastJudgeClipUrl = null;
    _log('session_id=${session.sessionId}, status=${session.status}');
    return session;
  }

  Future<LineDetectionResult> requestLineDetection({required String imagePath}) async {
    final SessionInfo session = await ensureSession();
    _log('line detection frame=$imagePath');

    final dynamic response = await _postMultipart(
      '/sessions/${_encodePath(session.sessionId)}/court-config/detect',
      query: const <String, String>{
        'family': 'tag36h11',
        'min_side_px': '0',
      },
      files: <String, String>{
        'frame': imagePath,
      },
    );

    final Map<String, dynamic> map = _asMap(response);
    final bool hasConfig = (_findString(map, const <String>[
              'court_config_path',
              'courtConfigPath',
              'config_path',
              'configPath',
              'path',
            ])
            ?.isNotEmpty ??
        false) ||
        (_findString(map, const <String>[
              'config_image',
              'configImage',
              'image',
            ])
            ?.isNotEmpty ??
        false);

    _applyCourtConfigFromMap(map);

    final bool detected = _extractDetectionState(map) ?? hasConfig;
    final String message = _findString(map, const <String>[
      'message',
      'msg',
      'detail',
      'status',
    ]) ?? (detected ? '마커와 라인을 인식했습니다.' : '아직 마커와 라인을 인식하지 못했습니다.');

    _log('line detection detected=$detected, message=$message');
    return LineDetectionResult(
      detected: detected,
      message: message,
    );
  }

  Future<void> startRecordingSession() async {
    final SessionInfo session = await ensureSession();
    _log('record/start session_id=${session.sessionId}');
    await _postJson('/sessions/${_encodePath(session.sessionId)}/record/start');
  }

  Future<void> stopRecordingSession() async {
    final SessionInfo? session = _session;
    if (session == null) return;
    _log('record/stop session_id=${session.sessionId}');
    await _postJson('/sessions/${_encodePath(session.sessionId)}/record/stop');
  }

  Future<JudgeResult> requestJudgeByMarkerEvent({
    required String videoPath,
    DateTime? pressedAt,
    DateTime? recordStartedAt,
    double? pressedAtSec,
    double lookbackSec = 5,
  }) async {
    final SessionInfo session = await ensureSession();
    final double effectivePressedAtSec = pressedAtSec ??
        _pressedSeconds(
          pressedAt: pressedAt ?? DateTime.now(),
          recordStartedAt: recordStartedAt,
        );
    final double safeLookbackSec = math.max(0, lookbackSec).toDouble();
    final double segmentStartSec = math.max(0, effectivePressedAtSec - safeLookbackSec).toDouble();
    _lastJudgeClipPath = null;
    _lastJudgeClipUrl = null;

    _log(
      'judge window session_id=${session.sessionId}, '
      'pressed_at_sec=${effectivePressedAtSec.toStringAsFixed(3)}, '
      'segment=${segmentStartSec.toStringAsFixed(3)}~${effectivePressedAtSec.toStringAsFixed(3)}, '
      'lookback_sec=${safeLookbackSec.toStringAsFixed(3)}',
    );

    String? serverRecordingPath;
    if (videoPath.isNotEmpty) {
      serverRecordingPath = await _uploadRecording(
        sessionId: session.sessionId,
        videoPath: videoPath,
      );
    }

    serverRecordingPath ??= await _fetchSessionRecordingPath(session.sessionId);
    final String? preprocessRecordingPath =
        _usableServerRecordingPath(serverRecordingPath ?? _recordingPath);

    final Map<String, dynamic> judgeBody = <String, dynamic>{
      'pressed_at_sec': effectivePressedAtSec,
      'use_video_end': false,
      'end_offset_sec': 0,
      'lookback_sec': safeLookbackSec,
      'render_video': true,
      'court_config_path': _courtConfigPath ?? '',
      'config_image': _configImage ?? '',
      'config_index': _configIndex,
      'render_inout_video': true,
    };

    try {
      final dynamic judgeResponse = await _postJson(
        '/sessions/${_encodePath(session.sessionId)}/judge',
        body: judgeBody,
      );
      return await _resolveJudgeResponse(judgeResponse);
    } on ApiServiceException catch (error) {
      if (preprocessRecordingPath == null) {
        _log('judge failed and no server-side recording path is available. original_error=$error');
        rethrow;
      }

      final dynamic preprocessResponse = await _postJson(
        '/judge-preprocess',
        body: <String, dynamic>{
          'recording_path': preprocessRecordingPath,
          'pressed_at_sec': effectivePressedAtSec,
          'use_video_end': false,
          'end_offset_sec': 0,
          'lookback_sec': safeLookbackSec,
          'render_video': true,
          'session_id': session.sessionId,
          'court_config_path': _courtConfigPath ?? '',
          'config_image': _configImage ?? '',
          'config_index': _configIndex,
          'render_inout_video': true,
        },
      );
      return await _resolveJudgeResponse(preprocessResponse);
    }
  }

  Future<List<String>> fetchCandidateVideos() async {
    return const <String>[];
  }

  Future<void> saveCurrentSession({String? videoPath}) async {
    final SessionInfo session = await ensureSession();

    if (videoPath != null && videoPath.isNotEmpty && _recordingPath == null) {
      _recordingPath = await _uploadRecording(
        sessionId: session.sessionId,
        videoPath: videoPath,
      );
    }

    await _postJson('/sessions/${_encodePath(session.sessionId)}/save');
  }

  Future<void> finishCurrentSession() async {
    final SessionInfo? session = _session;
    if (session == null) return;

    try {
      await _postJson('/sessions/${_encodePath(session.sessionId)}/finish');
    } finally {
      _session = null;
      _recordingPath = null;
      _courtConfigPath = null;
      _configImage = null;
      _lastJudgeClipPath = null;
      _lastJudgeClipUrl = null;
      _configIndex = 0;
    }
  }

  @Deprecated('loading_result_screen 제거 후 requestJudgeByMarkerEvent를 사용하세요.')
  Future<bool> requestJudgeResult({required int selectedIndex}) async {
    return selectedIndex.isEven;
  }

  Future<String?> _uploadRecording({
    required String sessionId,
    required String videoPath,
  }) async {
    final File videoFile = File(videoPath);
    final bool exists = await videoFile.exists();
    final int size = exists ? await videoFile.length() : 0;
    _log('record/upload local_path=$videoPath, exists=$exists, size=$size bytes');

    if (!exists || size <= 0) {
      throw ApiServiceException('업로드할 영상 파일이 없습니다: $videoPath');
    }

    final dynamic uploadResponse = await _postMultipart(
      '/sessions/${_encodePath(sessionId)}/record/upload',
      files: <String, String>{
        'video': videoPath,
      },
    );

    String? uploadedPath = _candidateRecordingPath(uploadResponse);
    uploadedPath ??= await _fetchSessionRecordingPath(sessionId);

    if (uploadedPath != null) {
      _log('record/upload server_path=$uploadedPath');
      _recordingPath = uploadedPath;
      await _syncRecordingPathToSession(
        sessionId: sessionId,
        recordingPath: uploadedPath,
      );
      return uploadedPath;
    }

    _log('record/upload finished, but no server-side recording path was returned. local path will not be sent as recording_path.');
    return null;
  }

  Future<String?> _fetchSessionRecordingPath(String sessionId) async {
    try {
      final dynamic response = await _getJson('/sessions/${_encodePath(sessionId)}');
      final Map<String, dynamic> map = _asMap(response);
      final String? recordingPath = _candidateRecordingPath(map);

      if (recordingPath == null) return null;

      _recordingPath = recordingPath;
      final SessionInfo? current = _session;
      if (current != null && current.sessionId == sessionId) {
        _session = SessionInfo(
          sessionId: current.sessionId,
          status: current.status,
          cameraLabel: current.cameraLabel,
          recordingPath: recordingPath,
        );
      }
      _log('session recording_path=$recordingPath');
      return recordingPath;
    } catch (error) {
      _log('GET session recording_path skipped: $error');
      return null;
    }
  }

  Future<void> _syncRecordingPathToSession({
    required String sessionId,
    required String recordingPath,
  }) async {
    final String? usablePath = _usableServerRecordingPath(recordingPath);
    if (usablePath == null) {
      _log('record/path skipped because path looks like a device-local path: $recordingPath');
      return;
    }

    try {
      await _postJson(
        '/sessions/${_encodePath(sessionId)}/record/path',
        body: <String, dynamic>{'path': usablePath},
      );
    } catch (error) {
      _log('record/path sync failed but judge will continue with session state: $error');
    }
  }

  String? _candidateRecordingPath(dynamic response) {
    final String? path = _findString(_asMap(response), const <String>[
      'recording_path',
      'recordingPath',
      'server_recording_path',
      'serverRecordingPath',
      'uploaded_path',
      'uploadedPath',
      'video_path',
      'videoPath',
      'path',
      'file_path',
      'filePath',
    ]);

    return _usableServerRecordingPath(path);
  }

  String? _usableServerRecordingPath(String? path) {
    if (path == null) return null;
    final String trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    final String normalized = trimmed.replaceAll('\\', '/');
    if (_looksLikeDeviceLocalPath(normalized)) {
      return null;
    }

    return trimmed;
  }

  bool _looksLikeDeviceLocalPath(String path) {
    final String normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/data/user/0/') ||
        normalized.contains('/com.example.frontend/cache/') ||
        normalized.contains('/cache/rec') ||
        normalized.startsWith('/storage/emulated/') ||
        normalized.startsWith('/sdcard/');
  }

  Future<JudgeResult> _resolveJudgeResponse(dynamic response) async {
    final JudgeResult? immediate = _judgeResultFromResponse(response);
    if (immediate != null && immediate.isFinal) return _rememberJudgeResult(immediate);

    final String? jobId = _findString(_asMap(response), const <String>[
      'job_id',
      'jobId',
      'id',
    ]);

    if (jobId == null || jobId.isEmpty) {
      if (immediate != null) return _rememberJudgeResult(immediate);
      throw const ApiServiceException('판정 작업 ID를 받지 못했습니다.');
    }

    _log('judge job_id=$jobId');

    for (int attempt = 0; attempt < 45; attempt++) {
      await Future<void>.delayed(const Duration(seconds: 1));

      dynamic resultResponse;
      try {
        resultResponse = await _getJson('/jobs/${_encodePath(jobId)}/result');
      } on ApiServiceException {
        resultResponse = await _getJson('/jobs/${_encodePath(jobId)}');
      }

      final JudgeResult? result = _judgeResultFromResponse(
        resultResponse,
        fallbackJobId: jobId,
      );

      if (result != null && result.isFinal) {
        _log('judge result=${result.resultLabel}');
        return _rememberJudgeResult(result);
      }

      final String? status = _findString(_asMap(resultResponse), const <String>[
        'status',
        'state',
      ])?.toLowerCase();

      if (status != null &&
          (status.contains('fail') || status.contains('error') || status.contains('cancel'))) {
        throw ApiServiceException('판정 작업이 실패했습니다. status=$status');
      }
    }

    throw const ApiServiceException('판정 결과 대기 시간이 초과되었습니다.');
  }

  JudgeResult _rememberJudgeResult(JudgeResult result) {
    _lastJudgeClipPath = result.clipPath;
    _lastJudgeClipUrl = result.clipUrl;
    return result;
  }

  JudgeResult? _judgeResultFromResponse(
    dynamic response, {
    String? fallbackJobId,
  }) {
    final Map<String, dynamic> map = _asMap(response);
    if (map.isEmpty) return null;

    final String? jobId = _findString(map, const <String>[
      'job_id',
      'jobId',
      'id',
    ]) ?? fallbackJobId;
    final String? status = _findString(map, const <String>[
      'status',
      'state',
    ]);
    final JudgeDecision? decision = _extractJudgeDecision(map);
    final String? clipPath = _extractClipPath(map);
    final String? clipUrl = _absoluteServerUrl(clipPath);
    final double? confidence = _findDouble(map, const <String>['confidence', 'score']);

    if (decision == null && !_isFinalStatus(status)) {
      return null;
    }

    return JudgeResult(
      decision: decision ?? JudgeDecision.unknown,
      jobId: jobId,
      status: status,
      clipPath: clipPath,
      clipUrl: clipUrl,
      confidence: confidence,
    );
  }

  bool _isFinalStatus(String? status) {
    if (status == null) return false;
    final String normalized = status.trim().toLowerCase();
    return normalized == 'done' ||
        normalized == 'completed' ||
        normalized == 'complete' ||
        normalized == 'success' ||
        normalized == 'succeeded';
  }

  JudgeDecision? _extractJudgeDecision(dynamic value) {
    final Object? boolLike = _findByKeys(value, const <String>[
      'is_in',
      'isIn',
      'in',
      'inside',
      'line_in',
      'lineIn',
    ]);

    if (boolLike is bool) return boolLike ? JudgeDecision.inCall : JudgeDecision.outCall;
    if (boolLike is num) return boolLike != 0 ? JudgeDecision.inCall : JudgeDecision.outCall;
    if (boolLike is String) {
      final JudgeDecision? parsed = _parseJudgeDecisionString(boolLike);
      if (parsed != null) return parsed;
    }

    final Object? stringLike = _findByKeys(value, const <String>[
      'result',
      'label',
      'decision',
      'call',
      'inout',
      'line_call',
      'lineCall',
    ]);

    if (stringLike is bool) return stringLike ? JudgeDecision.inCall : JudgeDecision.outCall;
    if (stringLike is num) return stringLike != 0 ? JudgeDecision.inCall : JudgeDecision.outCall;
    if (stringLike is String) return _parseJudgeDecisionString(stringLike);

    return null;
  }

  JudgeDecision? _parseJudgeDecisionString(String value) {
    final String normalized = value.trim().toLowerCase();
    if (normalized == 'in' || normalized == 'inside' || normalized == 'true' || normalized == '1') {
      return JudgeDecision.inCall;
    }
    if (normalized == 'out' || normalized == 'outside' || normalized == 'false' || normalized == '0') {
      return JudgeDecision.outCall;
    }
    if (normalized == 'unknown' || normalized == 'none' || normalized == 'undetermined' || normalized == 'uncertain') {
      return JudgeDecision.unknown;
    }
    return null;
  }

  String? _extractClipPath(dynamic value) {
    final Object? artifacts = _findByKeys(value, const <String>['artifacts']);
    if (artifacts is Map) {
      final Map<String, dynamic> map = artifacts.map(
        (dynamic key, dynamic val) => MapEntry(key.toString(), val),
      );
      final String? clip = _findString(map, const <String>[
        'clip',
        'clip_url',
        'clipUrl',
        'inout_video',
        'inoutVideo',
        'result_video',
        'resultVideo',
        'video',
        'video_url',
        'videoUrl',
      ]);
      if (clip != null && clip.trim().isNotEmpty) return clip.trim();
    }

    final String? direct = _findString(_asMap(value), const <String>[
      'clip',
      'clip_url',
      'clipUrl',
      'inout_video',
      'inoutVideo',
      'result_video',
      'resultVideo',
      'video',
      'video_url',
      'videoUrl',
    ]);
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();
    return null;
  }

  String? _absoluteServerUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final String trimmed = path.trim();
    final Uri? parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) return trimmed;

    final Uri base = Uri.parse(baseUrl);
    final String normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return base.replace(
      path: '${base.path}$normalizedPath'.replaceAll('//', '/'),
      queryParameters: null,
    ).toString();
  }

  Future<dynamic> _getJson(String path) async {
    _log('GET $path');
    final HttpClientRequest request = await _client.getUrl(_uri(path));
    _applyDefaultHeaders(request);
    return _readResponse(await request.close().timeout(const Duration(seconds: 20)));
  }

  Future<dynamic> _postJson(String path, {Map<String, dynamic>? body}) async {
    _log('POST $path${body == null ? '' : ' body=${jsonEncode(body)}'}');
    final HttpClientRequest request = await _client.postUrl(_uri(path));
    _applyDefaultHeaders(request);

    if (body != null) {
      final String encoded = jsonEncode(body);
      request.headers.contentType = ContentType.json;
      request.add(utf8.encode(encoded));
    } else {
      request.headers.contentLength = 0;
    }

    return _readResponse(await request.close().timeout(const Duration(seconds: 25)));
  }

  Future<dynamic> _postMultipart(
    String path, {
    Map<String, String> query = const <String, String>{},
    Map<String, String> fields = const <String, String>{},
    Map<String, String> files = const <String, String>{},
  }) async {
    _log('POST $path multipart files=${files.keys.join(',')} query=$query');
    final String boundary = '----cross-the-line-${DateTime.now().microsecondsSinceEpoch}';
    final HttpClientRequest request = await _client.postUrl(_uri(path, query: query));
    _applyDefaultHeaders(request);
    request.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');

    void writeText(String value) {
      request.add(utf8.encode(value));
    }

    for (final MapEntry<String, String> entry in fields.entries) {
      writeText('--$boundary\r\n');
      writeText('Content-Disposition: form-data; name="${_escapeHeader(entry.key)}"\r\n\r\n');
      writeText('${entry.value}\r\n');
    }

    for (final MapEntry<String, String> entry in files.entries) {
      final File file = File(entry.value);
      if (!await file.exists()) {
        throw ApiServiceException('파일을 찾을 수 없습니다: ${entry.value}');
      }

      final int length = await file.length();
      _log('multipart file field=${entry.key}, path=${entry.value}, size=$length bytes');
      final String filename = _basename(entry.value);
      writeText('--$boundary\r\n');
      writeText(
        'Content-Disposition: form-data; name="${_escapeHeader(entry.key)}"; filename="${_escapeHeader(filename)}"\r\n',
      );
      writeText('Content-Type: ${_contentTypeForPath(entry.value)}\r\n\r\n');
      await request.addStream(file.openRead());
      writeText('\r\n');
    }

    writeText('--$boundary--\r\n');
    return _readResponse(await request.close().timeout(const Duration(minutes: 2)));
  }

  Future<dynamic> _readResponse(HttpClientResponse response) async {
    final String body = await response.transform(utf8.decoder).join();
    final String preview = body.length > 600 ? '${body.substring(0, 600)}...' : body;
    _log('HTTP ${response.statusCode} ${response.reasonPhrase}: $preview');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiServiceException(
        '서버 요청 실패 (${response.statusCode})${body.trim().isEmpty ? '' : ': $body'}',
      );
    }

    final String trimmed = body.trim();
    if (trimmed.isEmpty) return <String, dynamic>{};

    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return trimmed;
    }
  }

  void _applyDefaultHeaders(HttpClientRequest request) {
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set('ngrok-skip-browser-warning', 'true');
  }

  Uri _uri(String path, {Map<String, String> query = const <String, String>{}}) {
    final Uri base = Uri.parse(baseUrl);
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: '${base.path}${normalizedPath}'.replaceAll('//', '/'),
      queryParameters: query.isEmpty ? null : query,
    );
  }

  void _applyCourtConfigFromMap(Map<String, dynamic> map) {
    _courtConfigPath = _findString(map, const <String>[
          'court_config_path',
          'courtConfigPath',
          'config_path',
          'configPath',
          'path',
        ]) ??
        _courtConfigPath;

    _configImage = _findString(map, const <String>[
          'config_image',
          'configImage',
          'image',
        ]) ??
        _configImage;

    _configIndex = _findInt(map, const <String>[
          'config_index',
          'configIndex',
          'index',
        ]) ??
        _configIndex;
  }

  bool? _extractDetectionState(dynamic value) {
    final Object? found = _findByKeys(value, const <String>[
      'detected',
      'success',
      'ok',
      'ready',
      'line_detected',
      'lineDetected',
      'marker_detected',
      'markerDetected',
    ]);

    if (found is bool) return found;
    if (found is num) return found != 0;
    if (found is String) {
      final String normalized = found.toLowerCase();
      if (normalized == 'true' || normalized == 'success' || normalized == 'ok' || normalized == 'ready') {
        return true;
      }
      if (normalized == 'false' || normalized == 'failed' || normalized == 'fail' || normalized == 'error') {
        return false;
      }
    }

    final String? status = _findString(_asMap(value), const <String>['status', 'state'])?.toLowerCase();
    if (status != null) {
      if (status.contains('fail') || status.contains('error')) return false;
      if (status.contains('success') || status.contains('ready') || status.contains('done')) return true;
    }

    return null;
  }

  bool? _extractInOut(dynamic value) {
    final JudgeDecision? decision = _extractJudgeDecision(value);
    if (decision == JudgeDecision.inCall) return true;
    if (decision == JudgeDecision.outCall) return false;
    return null;
  }

  Object? _findByKeys(dynamic value, List<String> keys) {
    if (value is Map) {
      for (final String key in keys) {
        if (value.containsKey(key)) return value[key];
      }
      for (final Object? child in value.values) {
        final Object? found = _findByKeys(child, keys);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final Object? child in value) {
        final Object? found = _findByKeys(child, keys);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((dynamic key, dynamic val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String? _findString(Map<String, dynamic> map, List<String> keys) {
    final Object? value = _findByKeys(map, keys);
    if (value == null) return null;
    return value.toString();
  }

  int? _findInt(Map<String, dynamic> map, List<String> keys) {
    final Object? value = _findByKeys(map, keys);
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _findDouble(Map<String, dynamic> map, List<String> keys) {
    final Object? value = _findByKeys(map, keys);
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double _pressedSeconds({
    required DateTime pressedAt,
    DateTime? recordStartedAt,
  }) {
    if (recordStartedAt == null) return 0;
    final int milliseconds = pressedAt.difference(recordStartedAt).inMilliseconds;
    return math.max(0, milliseconds) / 1000.0;
  }

  String _encodePath(String value) => Uri.encodeComponent(value);

  String _basename(String path) {
    final List<String> parts = path.split(RegExp(r'[/\\]'));
    return parts.isEmpty ? path : parts.last;
  }

  String _escapeHeader(String value) => value.replaceAll('"', '\\"');

  String _contentTypeForPath(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    return 'application/octet-stream';
  }
}

class SessionInfo {
  const SessionInfo({
    required this.sessionId,
    required this.status,
    required this.cameraLabel,
    this.recordingPath,
  });

  final String sessionId;
  final String status;
  final String cameraLabel;
  final String? recordingPath;
}

class LineDetectionResult {
  const LineDetectionResult({
    required this.detected,
    required this.message,
  });

  final bool detected;
  final String message;
}



enum JudgeDecision {
  inCall,
  outCall,
  unknown,
}

extension JudgeDecisionText on JudgeDecision {
  String get resultText {
    switch (this) {
      case JudgeDecision.inCall:
        return 'IN !!!';
      case JudgeDecision.outCall:
        return 'OUT !!!';
      case JudgeDecision.unknown:
        return 'UNKNOWN';
    }
  }

  String get resultLabel {
    switch (this) {
      case JudgeDecision.inCall:
        return 'IN';
      case JudgeDecision.outCall:
        return 'OUT';
      case JudgeDecision.unknown:
        return 'UNKNOWN';
    }
  }
}

class JudgeResult {
  const JudgeResult({
    required this.decision,
    this.jobId,
    this.status,
    this.clipPath,
    this.clipUrl,
    this.confidence,
  });

  final JudgeDecision decision;
  final String? jobId;
  final String? status;
  final String? clipPath;
  final String? clipUrl;
  final double? confidence;

  bool get isFinal {
    if (decision == JudgeDecision.inCall ||
        decision == JudgeDecision.outCall ||
        decision == JudgeDecision.unknown) {
      return true;
    }
    return false;
  }

  String get resultLabel => decision.resultLabel;
}

class ApiServiceException implements Exception {
  const ApiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
