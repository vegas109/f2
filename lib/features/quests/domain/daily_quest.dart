class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.title,
    required this.goal,
    required this.rewardCrystals,
    this.progress = 0,
    this.claimed = false,
  });

  final String id;
  final String title;
  final int goal;
  final int rewardCrystals;
  final int progress;

  /// True once the reward has been granted.
  final bool claimed;

  bool get isComplete => progress >= goal;
  double get ratio => goal == 0 ? 0 : (progress / goal).clamp(0.0, 1.0);

  DailyQuest copyWith({int? progress, bool? claimed}) => DailyQuest(
        id: id,
        title: title,
        goal: goal,
        rewardCrystals: rewardCrystals,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'goal': goal,
        'rewardCrystals': rewardCrystals,
        'progress': progress,
        'claimed': claimed,
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'] as String,
        title: json['title'] as String,
        goal: (json['goal'] as num).toInt(),
        rewardCrystals: (json['rewardCrystals'] as num).toInt(),
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        claimed: json['claimed'] as bool? ?? false,
      );
}
