import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SavedVideoStorageService {
  static const String _savedVideosKey = 'saved_videos';

  Future<List<SavedVideoRecord>> loadVideos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawItems = prefs.getStringList(_savedVideosKey) ?? const <String>[];

    final List<SavedVideoRecord> videos = <SavedVideoRecord>[];
    for (final String raw in rawItems) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          videos.add(SavedVideoRecord.fromJson(decoded));
        } else if (decoded is Map) {
          videos.add(SavedVideoRecord.fromJson(
            decoded.map((dynamic key, dynamic value) => MapEntry(key.toString(), value)),
          ));
        }
      } catch (_) {}
    }

    videos.sort((SavedVideoRecord a, SavedVideoRecord b) {
      return b.recordedAt.compareTo(a.recordedAt);
    });
    return videos;
  }

  Future<void> saveVideo(SavedVideoRecord video) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<SavedVideoRecord> current = await loadVideos();
    final List<SavedVideoRecord> next = <SavedVideoRecord>[
      video,
      ...current.where((SavedVideoRecord item) {
        if (item.id == video.id) return false;
        if (video.videoUrl != null && video.videoUrl!.trim().isNotEmpty) {
          return item.videoUrl != video.videoUrl;
        }
        return true;
      }),
    ];

    await prefs.setStringList(
      _savedVideosKey,
      next.map((SavedVideoRecord item) => jsonEncode(item.toJson())).toList(growable: false),
    );
  }
}

class SavedVideoRecord {
  const SavedVideoRecord({
    required this.id,
    required this.recordedAt,
    required this.result,
    this.videoPath,
    this.thumbnailUrl,
    this.thumbnailAssetPath,
    this.videoUrl,
  });

  final String id;
  final DateTime recordedAt;
  final String result;
  final String? videoPath;
  final String? thumbnailUrl;
  final String? thumbnailAssetPath;
  final String? videoUrl;

  factory SavedVideoRecord.fromJson(Map<String, dynamic> json) {
    return SavedVideoRecord(
      id: json['id']?.toString() ?? '',
      recordedAt: DateTime.tryParse(json['recordedAt']?.toString() ?? '') ?? DateTime.now(),
      result: json['result']?.toString() ?? '',
      videoPath: json['videoPath']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      thumbnailAssetPath: json['thumbnailAssetPath']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'recordedAt': recordedAt.toIso8601String(),
      'result': result,
      'videoPath': videoPath,
      'thumbnailUrl': thumbnailUrl,
      'thumbnailAssetPath': thumbnailAssetPath,
      'videoUrl': videoUrl,
    };
  }
}
