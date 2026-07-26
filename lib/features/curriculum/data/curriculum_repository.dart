import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/track.dart';

/// Loads curriculum content from bundled JSON assets.
///
/// Because the content ships inside the app bundle, lessons work fully
/// **offline** (per the product requirement). Results are cached in memory.
class CurriculumRepository {
  final Map<String, Track> _cache = {};

  static const _assetPaths = {
    'python': 'assets/curriculum/python.json',
    'cpp': 'assets/curriculum/cpp.json',
  };

  Future<Track> loadTrack(String trackId) async {
    final cached = _cache[trackId];
    if (cached != null) return cached;

    final path = _assetPaths[trackId] ?? _assetPaths['python']!;
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final track = Track.fromJson(json);
    _cache[trackId] = track;
    return track;
  }

  /// Finds a lesson by id within a track (loading the track if needed).
  Future<Lesson?> findLesson(String trackId, String lessonId) async {
    final track = await loadTrack(trackId);
    for (final module in track.modules) {
      for (final lesson in module.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
