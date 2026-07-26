/// A snapshot of the player's progress used to evaluate achievements.
class AchievementStats {
  const AchievementStats({
    required this.lessonsCompleted,
    required this.bossesDefeated,
    required this.streak,
    required this.cosmeticsOwned,
  });

  final int lessonsCompleted;
  final int bossesDefeated;
  final int streak;
  final int cosmeticsOwned;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;

  /// Predicate over a [AchievementStats] snapshot.
  final bool Function(AchievementStats s) isUnlocked;

  /// Static catalog. Ordering is display order.
  static const List<Achievement> catalog = [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first lesson',
      emoji: '🌱',
      isUnlocked: _firstSteps,
    ),
    Achievement(
      id: 'getting_serious',
      title: 'Getting Serious',
      description: 'Complete 5 lessons',
      emoji: '📚',
      isUnlocked: _fiveLessons,
    ),
    Achievement(
      id: 'scholar',
      title: 'Scholar',
      description: 'Complete 15 lessons',
      emoji: '🎓',
      isUnlocked: _fifteenLessons,
    ),
    Achievement(
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Defeat your first boss',
      emoji: '⚔️',
      isUnlocked: _firstBoss,
    ),
    Achievement(
      id: 'on_fire',
      title: 'On Fire',
      description: 'Reach a 3-day streak',
      emoji: '🔥',
      isUnlocked: _streak3,
    ),
    Achievement(
      id: 'stylish',
      title: 'Stylish',
      description: 'Craft your first cosmetic',
      emoji: '✨',
      isUnlocked: _firstCosmetic,
    ),
  ];

  static bool _firstSteps(AchievementStats s) => s.lessonsCompleted >= 1;
  static bool _fiveLessons(AchievementStats s) => s.lessonsCompleted >= 5;
  static bool _fifteenLessons(AchievementStats s) => s.lessonsCompleted >= 15;
  static bool _firstBoss(AchievementStats s) => s.bossesDefeated >= 1;
  static bool _streak3(AchievementStats s) => s.streak >= 3;
  static bool _firstCosmetic(AchievementStats s) => s.cosmeticsOwned >= 1;
}
