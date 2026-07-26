import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../code_execution/domain/programming_language.dart';
import '../../curriculum/domain/lesson_step.dart';
import '../../curriculum/domain/track.dart';
import '../../backend/application/reward_service.dart';
import '../../crafting/application/crafting_controller.dart';
import '../../player/application/player_controller.dart';
import '../../quests/application/quest_controller.dart';
import 'widgets/constructor_step_view.dart';
import 'widgets/fill_blank_step_view.dart';
import 'widgets/sandbox_step_view.dart';
import 'widgets/theory_step_view.dart';

/// Plays a lesson step-by-step. Handles hearts (energy) on mistakes, boss
/// timers, and awards XP on completion.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.trackId,
    required this.lesson,
  });

  final String trackId;
  final Lesson lesson;

  @override
  ConsumerState<LessonPlayerScreen> createState() =>
      _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  int _stepIndex = 0;
  int _mistakes = 0;
  Timer? _timer;
  int _remaining = 0;

  ProgrammingLanguage get _language =>
      ProgrammingLanguage.fromId(widget.trackId);

  List<LessonStep> get _steps => widget.lesson.steps;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.isBoss && widget.lesson.timeLimitSeconds != null) {
      _remaining = widget.lesson.timeLimitSeconds!;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _remaining--);
        if (_remaining <= 0) {
          t.cancel();
          _failBoss();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
    } else {
      _complete();
    }
  }

  void _onMistake() {
    _mistakes++;
    ref.read(playerControllerProvider.notifier).loseEnergy();
    final energy = ref.read(playerControllerProvider).energy;
    if (energy <= 0) {
      _outOfEnergy();
    }
  }

  Future<void> _complete() async {
    _timer?.cancel();
    // Reward goes through the RewardService seam: local grant now, or a
    // server-authoritative Cloud Functions callable when remote mode is on.
    final awarded = await ref.read(rewardServiceProvider).claimLessonReward(
          lessonId: widget.lesson.id,
          isBoss: widget.lesson.isBoss,
          trackId: widget.trackId,
          fallbackXp: widget.lesson.xpReward,
        );
    if (!mounted) return;
    ref.read(questControllerProvider.notifier).recordLessonCompleted(
          trackId: widget.trackId,
          mistakes: _mistakes,
        );
    // Parts drop from lessons, fueling crafting.
    ref
        .read(craftingControllerProvider.notifier)
        .addParts(widget.lesson.isBoss ? 4 : 2);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        success: true,
        title: widget.lesson.isBoss ? 'Boss defeated!' : 'Lesson complete!',
        xp: awarded,
        mistakes: _mistakes,
        onClose: () {
          Navigator.of(context).pop(); // dialog
          Navigator.of(context).pop(true); // screen
        },
      ),
    );
  }

  void _failBoss() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        success: false,
        title: "Time's up!",
        xp: 0,
        mistakes: _mistakes,
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(false);
        },
      ),
    );
  }

  void _outOfEnergy() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Out of energy'),
        content: const Text(
          'You ran out of hearts. Refill with crystals or wait for them to '
          'regenerate, then try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerControllerProvider);
    final step = _steps[_stepIndex];
    final progress = (_stepIndex + 1) / _steps.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceHigh,
            valueColor: AlwaysStoppedAnimation(
              AppColors.track(widget.trackId),
            ),
          ),
        ),
        actions: [
          if (widget.lesson.isBoss)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${_remaining}s',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.energy, size: 18),
                const SizedBox(width: 4),
                Text('${player.energy}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: _buildStep(step),
    );
  }

  Widget _buildStep(LessonStep step) {
    // Boss fights hide hints.
    final showHints = !widget.lesson.isBoss;
    return switch (step) {
      TheoryStep s => TheoryStepView(step: s, onContinue: _advance),
      FillBlankStep s => FillBlankStepView(
          step: s,
          showHints: showHints,
          onCorrect: _advance,
          onMistake: _onMistake,
        ),
      SandboxStep s => SandboxStepView(
          step: s,
          language: _language,
          onCorrect: _advance,
          onMistake: _onMistake,
        ),
      ConstructorStep s => ConstructorStepView(
          step: s,
          onCorrect: _advance,
          onMistake: _onMistake,
        ),
    };
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.success,
    required this.title,
    required this.xp,
    required this.mistakes,
    required this.onClose,
  });

  final bool success;
  final String title;
  final int xp;
  final int mistakes;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(
            success ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            color: success ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (success) Text('+$xp XP',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 6),
          Text('Mistakes: $mistakes',
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
      actions: [
        ElevatedButton(onPressed: onClose, child: const Text('Continue')),
      ],
    );
  }
}
