import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../player/application/player_controller.dart';

/// Grants lesson rewards. This is the seam between Local mode and a
/// server-authoritative backend: in Local mode the client applies the reward
/// directly; in remote mode the server decides the XP and refuses duplicates.
abstract interface class RewardService {
  /// Grants the reward for completing [lessonId]. Returns the XP awarded
  /// (0 if already completed / rejected).
  Future<int> claimLessonReward({
    required String lessonId,
    required bool isBoss,
    required String trackId,
    required int fallbackXp,
  });
}

/// Local implementation — applies the reward on-device via [PlayerController].
class LocalRewardService implements RewardService {
  LocalRewardService(this._ref);
  final Ref _ref;

  @override
  Future<int> claimLessonReward({
    required String lessonId,
    required bool isBoss,
    required String trackId,
    required int fallbackXp,
  }) async {
    return _ref
        .read(playerControllerProvider.notifier)
        .completeLesson(lessonId, xp: fallbackXp);
  }
}

/// Remote implementation — STUB. When Firebase is enabled, replace the body
/// with a Cloud Functions callable (`claimLessonReward`). Until then it falls
/// back to the local grant so the app keeps working.
class RemoteRewardService implements RewardService {
  RemoteRewardService(this._ref);
  final Ref _ref;

  @override
  Future<int> claimLessonReward({
    required String lessonId,
    required bool isBoss,
    required String trackId,
    required int fallbackXp,
  }) async {
    // TODO(firebase): call the server instead of granting locally:
    //   final callable =
    //       FirebaseFunctions.instance.httpsCallable('claimLessonReward');
    //   final res = await callable.call({
    //     'lessonId': lessonId, 'isBoss': isBoss, 'trackId': trackId,
    //   });
    //   final awarded = (res.data['awarded'] as num).toInt();
    //   // then refresh the player profile from Firestore and return awarded.
    debugPrint(
        '[RemoteRewardService] stub: would call claimLessonReward($lessonId); '
        'falling back to local grant.');
    return _ref
        .read(playerControllerProvider.notifier)
        .completeLesson(lessonId, xp: fallbackXp);
  }
}

/// Selects the reward service based on [AppConfig.useRemoteBackend].
final rewardServiceProvider = Provider<RewardService>((ref) {
  return AppConfig.useRemoteBackend
      ? RemoteRewardService(ref)
      : LocalRewardService(ref);
});
