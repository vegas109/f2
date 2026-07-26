import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';

/// The player's gameplay progression and economy state.
///
/// In local mode this is persisted to SharedPreferences. When Firebase is
/// enabled this maps 1:1 to the `users/{uid}` Firestore document (see
/// docs/firestore_schema.md), keeping reads to a single document.
class PlayerProfile extends Equatable {
  const PlayerProfile({
    this.xp = 0,
    this.crystals = 50,
    this.energy = AppConstants.maxEnergy,
    this.streak = 0,
    this.selectedTrack = 'python',
    this.lastEnergyRefillMs = 0,
    this.completedLessonIds = const <String>{},
    this.lastActiveDay = '',
  });

  final int xp;
  final int crystals;
  final int energy;
  final int streak;
  final String selectedTrack;

  /// Epoch millis of the last time energy started refilling.
  final int lastEnergyRefillMs;

  /// Ids of lessons the player has completed (for progress + skill tree).
  final Set<String> completedLessonIds;

  /// Last day (yyyy-mm-dd) the player completed activity, for streak logic.
  final String lastActiveDay;

  /// Simple level curve: every 100 XP is a level.
  int get level => (xp ~/ 100) + 1;

  /// XP progress within the current level, 0.0–1.0.
  double get levelProgress => (xp % 100) / 100.0;

  bool get hasEnergy => energy > 0;

  PlayerProfile copyWith({
    int? xp,
    int? crystals,
    int? energy,
    int? streak,
    String? selectedTrack,
    int? lastEnergyRefillMs,
    Set<String>? completedLessonIds,
    String? lastActiveDay,
  }) {
    return PlayerProfile(
      xp: xp ?? this.xp,
      crystals: crystals ?? this.crystals,
      energy: energy ?? this.energy,
      streak: streak ?? this.streak,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      lastEnergyRefillMs: lastEnergyRefillMs ?? this.lastEnergyRefillMs,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'crystals': crystals,
        'energy': energy,
        'streak': streak,
        'selectedTrack': selectedTrack,
        'lastEnergyRefillMs': lastEnergyRefillMs,
        'completedLessonIds': completedLessonIds.toList(),
        'lastActiveDay': lastActiveDay,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        crystals: (json['crystals'] as num?)?.toInt() ?? 50,
        energy: (json['energy'] as num?)?.toInt() ?? AppConstants.maxEnergy,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        selectedTrack: json['selectedTrack'] as String? ?? 'python',
        lastEnergyRefillMs: (json['lastEnergyRefillMs'] as num?)?.toInt() ?? 0,
        completedLessonIds:
            ((json['completedLessonIds'] as List?)?.cast<String>() ??
                    const <String>[])
                .toSet(),
        lastActiveDay: json['lastActiveDay'] as String? ?? '',
      );

  @override
  List<Object?> get props => [
        xp,
        crystals,
        energy,
        streak,
        selectedTrack,
        lastEnergyRefillMs,
        completedLessonIds,
        lastActiveDay,
      ];
}
