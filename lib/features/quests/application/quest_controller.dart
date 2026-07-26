import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';
import '../../player/application/player_controller.dart';
import '../domain/daily_quest.dart';

/// Generates and tracks the day's quests, awarding crystals on completion.
///
/// Quests reset each local day. Progress is fed from lesson completions via
/// [recordLessonCompleted].
class QuestController extends StateNotifier<List<DailyQuest>> {
  QuestController(this._ref, this._prefs, this._userId) : super(const []) {
    _load();
  }

  final Ref _ref;
  final SharedPreferences _prefs;
  final String _userId;

  String get _key => 'quests_$_userId';

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  List<DailyQuest> _freshQuests() => const [
        DailyQuest(
            id: 'lessons2',
            title: 'Complete 2 lessons',
            goal: 2,
            rewardCrystals: 20),
        DailyQuest(
            id: 'flawless',
            title: 'Finish a lesson with no mistakes',
            goal: 1,
            rewardCrystals: 15),
        DailyQuest(
            id: 'cpp1',
            title: 'Complete a C++ lesson',
            goal: 1,
            rewardCrystals: 15),
      ];

  void _load() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        if (json['date'] == _todayKey()) {
          state = (json['quests'] as List)
              .map((e) => DailyQuest.fromJson(e as Map<String, dynamic>))
              .toList();
          return;
        }
      } catch (_) {/* fall through to regenerate */}
    }
    state = _freshQuests();
    _save();
  }

  void _save() {
    _prefs.setString(
      _key,
      jsonEncode({
        'date': _todayKey(),
        'quests': state.map((q) => q.toJson()).toList(),
      }),
    );
  }

  void _bump(String id, int by) {
    state = [
      for (final q in state)
        if (q.id == id && !q.claimed)
          q.copyWith(progress: q.progress + by)
        else
          q,
    ];
    _claimCompleted();
    _save();
  }

  /// Auto-grants rewards for any newly completed quest.
  void _claimCompleted() {
    final player = _ref.read(playerControllerProvider.notifier);
    state = [
      for (final q in state)
        if (q.isComplete && !q.claimed)
          () {
            player.addCrystals(q.rewardCrystals);
            return q.copyWith(claimed: true);
          }()
        else
          q,
    ];
  }

  /// Call when a lesson is completed.
  void recordLessonCompleted({
    required String trackId,
    required int mistakes,
  }) {
    _bump('lessons2', 1);
    if (mistakes == 0) _bump('flawless', 1);
    if (trackId == 'cpp') _bump('cpp1', 1);
  }
}

final questControllerProvider =
    StateNotifierProvider<QuestController, List<DailyQuest>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final userId = ref.watch(authControllerProvider).user?.id ?? 'anonymous';
  return QuestController(ref, prefs, userId);
});
