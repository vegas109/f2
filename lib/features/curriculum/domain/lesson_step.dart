/// A single interactive step inside a lesson. A lesson is a sequence of these.
///
/// Parsed from JSON by [LessonStep.fromJson] using the `kind` discriminator.
sealed class LessonStep {
  const LessonStep();

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String? ?? 'theory';
    switch (kind) {
      case 'fill_blank':
        return FillBlankStep.fromJson(json);
      case 'sandbox':
        return SandboxStep.fromJson(json);
      case 'constructor':
        return ConstructorStep.fromJson(json);
      case 'theory':
      default:
        return TheoryStep.fromJson(json);
    }
  }
}

/// Bite-sized theory shown as a swipe card.
class TheoryStep extends LessonStep {
  const TheoryStep({required this.heading, required this.body, this.code});

  final String heading;
  final String body;
  final String? code;

  factory TheoryStep.fromJson(Map<String, dynamic> json) => TheoryStep(
        heading: json['heading'] as String? ?? '',
        body: json['body'] as String? ?? '',
        code: json['code'] as String?,
      );
}

/// Fill-in-the-blank: [template] contains one or more `___` placeholders that
/// the learner completes; [answers] are the accepted values, in order.
class FillBlankStep extends LessonStep {
  const FillBlankStep({
    required this.prompt,
    required this.template,
    required this.answers,
    this.hint,
  });

  final String prompt;
  final String template;
  final List<String> answers;
  final String? hint;

  /// The template split around the `___` markers, for rendering inline inputs.
  List<String> get segments => template.split('___');

  factory FillBlankStep.fromJson(Map<String, dynamic> json) => FillBlankStep(
        prompt: json['prompt'] as String? ?? '',
        template: json['template'] as String? ?? '',
        answers: (json['answers'] as List?)?.cast<String>() ?? const [],
        hint: json['hint'] as String?,
      );
}

/// Full code execution: learner writes code that must produce [expectedStdout].
class SandboxStep extends LessonStep {
  const SandboxStep({
    required this.instructions,
    required this.starterCode,
    required this.expectedStdout,
    this.stdin = '',
  });

  final String instructions;
  final String starterCode;
  final String expectedStdout;
  final String stdin;

  factory SandboxStep.fromJson(Map<String, dynamic> json) => SandboxStep(
        instructions: json['instructions'] as String? ?? '',
        starterCode: json['starterCode'] as String? ?? '',
        expectedStdout: json['expectedStdout'] as String? ?? '',
        stdin: json['stdin'] as String? ?? '',
      );
}

/// Visual code constructor: learner drags [blocks] into the correct order.
/// The stored order in JSON is the CORRECT order; the UI shuffles them.
/// [distractors] are extra wrong blocks that must NOT be used.
class ConstructorStep extends LessonStep {
  const ConstructorStep({
    required this.instructions,
    required this.blocks,
    this.distractors = const [],
  });

  final String instructions;
  final List<String> blocks;
  final List<String> distractors;

  factory ConstructorStep.fromJson(Map<String, dynamic> json) =>
      ConstructorStep(
        instructions: json['instructions'] as String? ?? '',
        blocks: (json['blocks'] as List?)?.cast<String>() ?? const [],
        distractors:
            (json['distractors'] as List?)?.cast<String>() ?? const [],
      );
}
