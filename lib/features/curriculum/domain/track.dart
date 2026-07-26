import '../../../core/constants/app_constants.dart';
import 'lesson_step.dart';

/// Primary format of a lesson — drives its list icon. A lesson may still mix
/// step kinds internally; this is just the headline format.
enum LessonFormat {
  theory,
  fillBlank,
  sandbox,
  constructor;

  static LessonFormat fromString(String? value) => switch (value) {
        'fill_blank' => LessonFormat.fillBlank,
        'sandbox' => LessonFormat.sandbox,
        'constructor' => LessonFormat.constructor,
        _ => LessonFormat.theory,
      };
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.format,
    required this.steps,
    this.xpReward = AppConstants.xpPerLesson,
    this.isBoss = false,
    this.timeLimitSeconds,
  });

  final String id;
  final String title;
  final LessonFormat format;
  final List<LessonStep> steps;
  final int xpReward;

  /// Boss lessons are timed and hide hints.
  final bool isBoss;
  final int? timeLimitSeconds;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Lesson',
        format: LessonFormat.fromString(json['type'] as String?),
        isBoss: json['isBoss'] as bool? ?? false,
        timeLimitSeconds: (json['timeLimitSeconds'] as num?)?.toInt(),
        xpReward: (json['xpReward'] as num?)?.toInt() ??
            (json['isBoss'] as bool? ?? false
                ? AppConstants.xpPerBossFight
                : AppConstants.xpPerLesson),
        steps: ((json['steps'] as List?) ?? const [])
            .map((e) => LessonStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Module {
  const Module({
    required this.id,
    required this.title,
    required this.level,
    required this.lessons,
  });

  final String id;
  final String title;
  final String level; // Junior / Middle / Middle+
  final List<Lesson> lessons;

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Module',
        level: json['level'] as String? ?? 'Junior',
        lessons: ((json['lessons'] as List?) ?? const [])
            .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Track {
  const Track({
    required this.id,
    required this.title,
    required this.modules,
  });

  final String id; // python / cpp
  final String title;
  final List<Module> modules;

  List<Lesson> get allLessons =>
      [for (final m in modules) ...m.lessons];

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['track'] as String? ?? 'python',
        title: json['title'] as String? ?? 'Track',
        modules: ((json['modules'] as List?) ?? const [])
            .map((e) => Module.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
