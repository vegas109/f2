import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../application/crafting_controller.dart';
import '../domain/cosmetic.dart';

class CraftingScreen extends ConsumerWidget {
  const CraftingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(craftingControllerProvider);
    final controller = ref.read(craftingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crafting'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.hexagon_outlined,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: 4),
                Text('${state.parts} parts',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: Cosmetic.catalog.length,
        itemBuilder: (context, i) {
          final item = Cosmetic.catalog[i];
          final owned = state.unlocked.contains(item.id);
          final affordable = state.parts >= item.cost;
          return _CosmeticCard(
            item: item,
            owned: owned,
            affordable: affordable,
            onCraft: () {
              final ok = controller.craft(item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Crafted ${item.name}!'
                      : 'Not enough parts.'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({
    required this.item,
    required this.owned,
    required this.affordable,
    required this.onCraft,
  });

  final Cosmetic item;
  final bool owned;
  final bool affordable;
  final VoidCallback onCraft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: owned ? AppColors.success : AppColors.outline),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 44)),
            ),
          ),
          Text(item.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(item.kind,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: owned
                ? const OutlinedButton(
                    onPressed: null, child: Text('Owned'))
                : ElevatedButton(
                    onPressed: affordable ? onCraft : null,
                    child: Text('${item.cost} parts'),
                  ),
          ),
        ],
      ),
    );
  }
}
