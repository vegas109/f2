/// Product catalog for monetization.
///
/// The `id`s below must match the product IDs you create in Google Play
/// Console and App Store Connect. Until then, the store shows the catalog but
/// purchases report "store not configured".
class StoreProducts {
  StoreProducts._();

  /// Consumable crystal packs → productId mapped to crystals granted.
  static const crystalPacks = <CrystalPack>[
    CrystalPack(id: 'crystals_small', crystals: 100, label: 'Pouch'),
    CrystalPack(id: 'crystals_medium', crystals: 550, label: 'Chest'),
    CrystalPack(id: 'crystals_large', crystals: 1200, label: 'Vault'),
  ];

  /// Auto-renewing subscription tiers.
  static const subscriptions = <SubscriptionTier>[
    SubscriptionTier(
      id: 'sub_plus',
      tier: 'plus',
      name: 'Plus',
      perks: ['Unlimited energy', 'No ads'],
    ),
    SubscriptionTier(
      id: 'sub_pro',
      tier: 'pro',
      name: 'Pro',
      perks: ['Everything in Plus', '2× XP', 'Monthly crystals'],
    ),
    SubscriptionTier(
      id: 'sub_ultimate',
      tier: 'ultimate',
      name: 'Ultimate',
      perks: ['Everything in Pro', 'Exclusive cosmetics', 'Priority support'],
    ),
  ];

  static Set<String> get allIds => {
        ...crystalPacks.map((e) => e.id),
        ...subscriptions.map((e) => e.id),
      };

  static int crystalsForProduct(String productId) {
    for (final p in crystalPacks) {
      if (p.id == productId) return p.crystals;
    }
    return 0;
  }

  static String? tierForProduct(String productId) {
    for (final s in subscriptions) {
      if (s.id == productId) return s.tier;
    }
    return null;
  }
}

class CrystalPack {
  const CrystalPack(
      {required this.id, required this.crystals, required this.label});
  final String id;
  final int crystals;
  final String label;
}

class SubscriptionTier {
  const SubscriptionTier({
    required this.id,
    required this.tier,
    required this.name,
    required this.perks,
  });
  final String id;
  final String tier;
  final String name;
  final List<String> perks;
}
