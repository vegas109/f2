import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Loads and shows rewarded ads, granting crystals via [onReward].
///
/// Uses Google's TEST ad unit IDs so it works out of the box in development.
/// Replace them with your real AdMob unit IDs for production, and add your
/// AdMob App ID to AndroidManifest.xml / Info.plist. All calls are guarded so
/// a missing/невалидная конфигурация never crashes the app.
class RewardedAdService {
  bool _initialized = false;

  // Google test rewarded ad units.
  static const _androidTestUnit = 'ca-app-pub-3940256099942544/5224354917';
  static const _iosTestUnit = 'ca-app-pub-3940256099942544/1712485313';

  String get _adUnitId =>
      Platform.isAndroid ? _androidTestUnit : _iosTestUnit;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Loads and shows a rewarded ad.
  ///
  /// Calls [onReward] with the reward amount when earned, or [onUnavailable]
  /// with a reason if the ad can't be shown.
  Future<void> show({
    required void Function(int amount) onReward,
    required void Function(String reason) onUnavailable,
  }) async {
    try {
      await _ensureInit();
      RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) => ad.dispose(),
              onAdFailedToShowFullScreenContent: (ad, err) {
                ad.dispose();
                onUnavailable('Ad failed to show.');
              },
            );
            ad.show(
              onUserEarnedReward: (ad, reward) =>
                  onReward(reward.amount.toInt()),
            );
          },
          onAdFailedToLoad: (error) =>
              onUnavailable('No ad available right now.'),
        ),
      );
    } catch (e) {
      onUnavailable('Ads not configured yet.');
    }
  }
}

final rewardedAdServiceProvider =
    Provider<RewardedAdService>((ref) => RewardedAdService());
