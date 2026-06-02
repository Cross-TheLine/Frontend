import 'dart:io';
import 'package:flutter/services.dart';




class MarkerDownloadService {
  static Future<String?> saveMarkerImage() async {

    // 1. asset 이미지 로드
    try {
      final byteData =
          await rootBundle.load('assets/markers/aruco_marker_0.png');
      final bytes = byteData.buffer.asUint8List();

      final List<String> possiblePaths = [
        '/storage/emulated/0/Download',
        '/sdcard/Download',
      ];
      // 2. 가능한 경로 탐색 및 저장

      for (final path in possiblePaths) {
        final dir = Directory(path);

        if (await dir.exists()) {
          final file = File('${dir.path}/aruco_marker_0.png');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      }
      // 3. 모든 경로가 실패한 경우

      // fallback (앱 내부)
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/aruco_marker_0.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}