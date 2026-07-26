/// A craftable cosmetic (profile skin or avatar) bought with parts that
/// drop from completing lessons.
class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.name,
    required this.kind,
    required this.cost,
    required this.emoji,
  });

  final String id;
  final String name;
  final String kind; // skin | avatar
  final int cost; // in parts
  final String emoji;

  /// Static catalog. In a live build this could come from Remote Config.
  static const catalog = <Cosmetic>[
    Cosmetic(id: 'avatar_owl', name: 'Night Owl', kind: 'avatar', cost: 6, emoji: '🦉'),
    Cosmetic(id: 'avatar_fox', name: 'Clever Fox', kind: 'avatar', cost: 6, emoji: '🦊'),
    Cosmetic(id: 'skin_neon', name: 'Neon Frame', kind: 'skin', cost: 10, emoji: '🟣'),
    Cosmetic(id: 'skin_gold', name: 'Gold Frame', kind: 'skin', cost: 16, emoji: '🟡'),
    Cosmetic(id: 'avatar_robot', name: 'Code Bot', kind: 'avatar', cost: 12, emoji: '🤖'),
    Cosmetic(id: 'skin_matrix', name: 'Matrix Frame', kind: 'skin', cost: 20, emoji: '🟢'),
  ];
}
