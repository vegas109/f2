import 'package:codehero/features/curriculum/domain/lesson_step.dart';
import 'package:codehero/features/curriculum/domain/track.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Curriculum parsing', () {
    test('LessonStep.fromJson picks the right subtype by kind', () {
      expect(LessonStep.fromJson({'kind': 'theory'}), isA<TheoryStep>());
      expect(LessonStep.fromJson({'kind': 'fill_blank'}), isA<FillBlankStep>());
      expect(LessonStep.fromJson({'kind': 'sandbox'}), isA<SandboxStep>());
      expect(
          LessonStep.fromJson({'kind': 'constructor'}), isA<ConstructorStep>());
      // Unknown/missing kind defaults to theory.
      expect(LessonStep.fromJson({}), isA<TheoryStep>());
    });

    test('FillBlankStep splits its template into segments', () {
      final step = FillBlankStep.fromJson({
        'prompt': 'p',
        'template': 'a = ___',
        'answers': ['1'],
      });
      expect(step.segments, ['a = ', '']);
      expect(step.answers, ['1']);
    });

    test('Track.fromJson builds modules, lessons and boss flags', () {
      final track = Track.fromJson({
        'track': 'python',
        'title': 'Python',
        'modules': [
          {
            'id': 'm1',
            'title': 'Basics',
            'level': 'Junior',
            'lessons': [
              {
                'id': 'l1',
                'type': 'theory',
                'title': 'Hello',
                'steps': [
                  {'kind': 'theory', 'heading': 'h', 'body': 'b'}
                ]
              },
              {
                'id': 'boss1',
                'type': 'sandbox',
                'title': 'Boss',
                'isBoss': true,
                'timeLimitSeconds': 120,
                'steps': [
                  {'kind': 'sandbox', 'expectedStdout': '1'}
                ]
              }
            ]
          }
        ]
      });

      expect(track.id, 'python');
      expect(track.modules, hasLength(1));
      expect(track.allLessons, hasLength(2));

      final boss = track.allLessons.firstWhere((l) => l.id == 'boss1');
      expect(boss.isBoss, isTrue);
      expect(boss.timeLimitSeconds, 120);
      expect(boss.format, LessonFormat.sandbox);
    });
  });
}
