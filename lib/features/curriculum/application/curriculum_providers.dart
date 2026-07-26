import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/curriculum_repository.dart';
import '../domain/track.dart';

final curriculumRepositoryProvider =
    Provider<CurriculumRepository>((ref) => CurriculumRepository());

/// Loads a full track (modules + lessons) by id. Cached by the repository.
final trackProvider =
    FutureProvider.family<Track, String>((ref, trackId) async {
  final repo = ref.watch(curriculumRepositoryProvider);
  return repo.loadTrack(trackId);
});
