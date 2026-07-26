import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';

/// Grants crystals in exchange for watching a rewarded ad.
///
/// This is a **demo implementation** so the earn-via-ad flow is testable out
/// of the box (no native ad SDK, no crash risk). It grants the reward
/// immediately.
///
/// For production, add `google_mobile_ads` to pubspec, put your AdMob App ID
/// in AndroidManifest.xml / Info.plist, and replace this class with a real
/// `RewardedAd.load(...).show(...)` implementation that calls [onReward] from
/// the `onUserEarnedReward` callback. The rest of the app depends only on this
/// interface, so nothing else changes.
class RewardedAdService {
  /// "Shows" a rewarded ad. Calls [onReward] with the crystal amount, or
  /// [onUnavailable] with a reason if it cannot be shown.
  Future<void> show({
    required void Function(int amount) onReward,
    required void Function(String reason) onUnavailable,
  }) async {
    // Simulate the short load/watch delay of a real rewarded ad.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    onReward(AppConstants.crystalsPerRewardedAd);
  }
}

final rewardedAdServiceProvider =
    Provider<RewardedAdService>((ref) => RewardedAdService());
