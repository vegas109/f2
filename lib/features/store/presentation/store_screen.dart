import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../player/application/player_controller.dart';
import '../application/rewarded_ad_service.dart';
import '../application/store_controller.dart';
import '../domain/store_products.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeControllerProvider);
    final crystals =
        ref.watch(playerControllerProvider.select((p) => p.crystals));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: AppColors.crystal, size: 18),
                const SizedBox(width: 4),
                Text('$crystals',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (store.message != null) _Banner(text: store.message!),
          const _SectionTitle('Free crystals'),
          _RewardedAdCard(),
          const SizedBox(height: 20),
          const _SectionTitle('Crystal packs'),
          for (final pack in StoreProducts.crystalPacks)
            _CrystalPackTile(pack: pack, store: store),
          const SizedBox(height: 20),
          const _SectionTitle('Subscriptions'),
          for (final sub in StoreProducts.subscriptions)
            _SubscriptionCard(sub: sub, store: store),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                ref.read(storeControllerProvider.notifier).restorePurchases(),
            child: const Text('Restore purchases'),
          ),
        ],
      ),
    );
  }
}

class _RewardedAdCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x223ED598),
          child: Icon(Icons.play_circle_fill, color: AppColors.success),
        ),
        title: Text('Watch an ad → +${AppConstants.crystalsPerRewardedAd}'),
        subtitle: const Text('Free crystals, anytime'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final messenger = ScaffoldMessenger.of(context);
          ref.read(rewardedAdServiceProvider).show(
            onReward: (_) {
              ref
                  .read(playerControllerProvider.notifier)
                  .addCrystals(AppConstants.crystalsPerRewardedAd);
              messenger.showSnackBar(SnackBar(
                content: Text(
                    '+${AppConstants.crystalsPerRewardedAd} crystals!'),
              ));
            },
            onUnavailable: (reason) => messenger.showSnackBar(
              SnackBar(content: Text(reason)),
            ),
          );
        },
      ),
    );
  }
}

class _CrystalPackTile extends ConsumerWidget {
  const _CrystalPackTile({required this.pack, required this.store});
  final CrystalPack pack;
  final StoreState store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = store.products[pack.id];
    final price = product?.price ?? '—';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x224FD1FF),
          child: Icon(Icons.diamond, color: AppColors.crystal),
        ),
        title: Text('${pack.crystals} crystals',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(pack.label),
        trailing: FilledButton(
          onPressed: () =>
              ref.read(storeControllerProvider.notifier).buy(pack.id),
          child: Text(price),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  const _SubscriptionCard({required this.sub, required this.store});
  final SubscriptionTier sub;
  final StoreState store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = store.products[sub.id];
    final price = product?.price;
    final active = store.activeTier == sub.tier;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? AppColors.success : AppColors.outline,
          width: active ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(sub.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              const Spacer(),
              if (active)
                const Chip(
                  label: Text('Active'),
                  backgroundColor: Color(0x223ED598),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final perk in sub.perks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(perk,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: active
                  ? null
                  : () =>
                      ref.read(storeControllerProvider.notifier).buy(sub.id),
              child: Text(active
                  ? 'Subscribed'
                  : (price == null ? 'Subscribe' : 'Subscribe · $price')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline,
                color: AppColors.warning, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13))),
          ],
        ),
      );
}
