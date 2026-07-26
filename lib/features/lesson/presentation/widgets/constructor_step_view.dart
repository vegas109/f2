import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../curriculum/domain/lesson_step.dart';

class _Block {
  _Block(this.id, this.text, {this.included = true});
  final int id;
  final String text;
  bool included;
}

/// Visual code constructor: drag blocks to reorder them into a working
/// program. Distractor blocks can be toggled out. Custom drag engine built on
/// [ReorderableListView].
class ConstructorStepView extends StatefulWidget {
  const ConstructorStepView({
    super.key,
    required this.step,
    required this.onCorrect,
    required this.onMistake,
  });

  final ConstructorStep step;
  final VoidCallback onCorrect;
  final VoidCallback onMistake;

  @override
  State<ConstructorStepView> createState() => _ConstructorStepViewState();
}

class _ConstructorStepViewState extends State<ConstructorStepView> {
  late List<_Block> _blocks;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    var id = 0;
    final all = <_Block>[
      for (final b in widget.step.blocks) _Block(id++, b),
      for (final d in widget.step.distractors)
        _Block(id++, d, included: true),
    ];
    // Shuffle so the correct order isn't given away.
    all.shuffle(Random(widget.step.instructions.length + all.length));
    _blocks = all;
  }

  void _check() {
    final assembled =
        _blocks.where((b) => b.included).map((b) => b.text).toList();
    final correct = _listEquals(assembled, widget.step.blocks);
    setState(() => _lastCorrect = correct);
    if (correct) {
      widget.onCorrect();
    } else {
      widget.onMistake();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            widget.step.instructions,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Text(
            'Drag to reorder. Toggle off any block that does not belong.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _blocks.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _blocks.removeAt(oldIndex);
                _blocks.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final block = _blocks[index];
              return _BlockTile(
                key: ValueKey(block.id),
                block: block,
                index: index,
                onToggle: () =>
                    setState(() => block.included = !block.included),
              );
            },
          ),
        ),
        if (_lastCorrect == false)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Not quite — check the order and included blocks.',
                style: TextStyle(color: AppColors.error)),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _check,
            child: const Text('Check'),
          ),
        ),
      ],
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    super.key,
    required this.block,
    required this.index,
    required this.onToggle,
  });

  final _Block block;
  final int index;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final active = block.included;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.surfaceHigh : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              active
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: active ? AppColors.success : AppColors.textMuted,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          Expanded(
            child: Text(
              block.text,
              style: AppTheme.codeStyle(
                color: active ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.drag_handle, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
