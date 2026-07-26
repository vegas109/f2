import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';

/// Validates a purchase before entitlements are granted. In Local mode the
/// client trusts the store result; in remote mode the server verifies the
/// receipt (Google Play / App Store) before anything is granted.
abstract interface class PurchaseValidator {
  /// Returns true if the purchase is valid and delivery may proceed.
  Future<bool> validate({required String productId, String? purchaseToken});
}

/// Local implementation — trusts the on-device store result.
class LocalPurchaseValidator implements PurchaseValidator {
  const LocalPurchaseValidator();

  @override
  Future<bool> validate({
    required String productId,
    String? purchaseToken,
  }) async =>
      true;
}

/// Remote implementation — STUB. Replace with a Cloud Functions callable
/// (`validatePurchase`) that verifies the receipt server-side. Until Firebase
/// is enabled it returns true so purchases still deliver in testing.
class RemotePurchaseValidator implements PurchaseValidator {
  const RemotePurchaseValidator();

  @override
  Future<bool> validate({
    required String productId,
    String? purchaseToken,
  }) async {
    // TODO(firebase): verify server-side before granting:
    //   final callable =
    //       FirebaseFunctions.instance.httpsCallable('validatePurchase');
    //   final res = await callable.call({
    //     'productId': productId, 'purchaseToken': purchaseToken,
    //   });
    //   return res.data['ok'] == true;
    debugPrint(
        '[RemotePurchaseValidator] stub: would validate $productId server-side; '
        'returning true.');
    return true;
  }
}

final purchaseValidatorProvider = Provider<PurchaseValidator>((ref) {
  return AppConfig.useRemoteBackend
      ? const RemotePurchaseValidator()
      : const LocalPurchaseValidator();
});
