import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/auth_controller.dart';
import '../../player/application/player_controller.dart';
import '../domain/store_products.dart';

class StoreState {
  const StoreState({
    this.available = false,
    this.loading = true,
    this.products = const {},
    this.activeTier = 'none',
    this.message,
  });

  final bool available;
  final bool loading;

  /// productId -> store ProductDetails (price, title from the store).
  final Map<String, ProductDetails> products;

  /// Current subscription tier: none | plus | pro | ultimate.
  final String activeTier;

  final String? message;

  StoreState copyWith({
    bool? available,
    bool? loading,
    Map<String, ProductDetails>? products,
    String? activeTier,
    String? message,
  }) {
    return StoreState(
      available: available ?? this.available,
      loading: loading ?? this.loading,
      products: products ?? this.products,
      activeTier: activeTier ?? this.activeTier,
      message: message,
    );
  }
}

/// Wraps [InAppPurchase] for crystal packs and subscriptions.
///
/// Purchases work once the product IDs in [StoreProducts] are configured in
/// the stores. Server-side receipt validation is intentionally deferred (it
/// requires Cloud Functions on the Blaze plan) — see docs/architecture.md.
class StoreController extends StateNotifier<StoreState> {
  StoreController(this._ref, this._prefs, this._userId)
      : super(const StoreState()) {
    _restoreTier();
    _init();
  }

  final Ref _ref;
  final SharedPreferences _prefs;
  final String _userId;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  String get _tierKey => 'sub_tier_$_userId';

  void _restoreTier() {
    final tier = _prefs.getString(_tierKey) ?? 'none';
    state = state.copyWith(activeTier: tier);
  }

  Future<void> _init() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(
          available: false,
          loading: false,
          message: 'In-app billing is not available on this device yet.',
        );
        return;
      }
      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: (Object e) =>
            state = state.copyWith(message: 'Purchase error: $e'),
      );
      final response = await _iap.queryProductDetails(StoreProducts.allIds);
      final map = {for (final p in response.productDetails) p.id: p};
      state = state.copyWith(
        available: true,
        loading: false,
        products: map,
        message: map.isEmpty
            ? 'No products returned — configure product IDs in the stores.'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        available: false,
        loading: false,
        message: 'Store unavailable: $e',
      );
    }
  }

  Future<void> buy(String productId) async {
    final product = state.products[productId];
    if (product == null) {
      state = state.copyWith(
        message: 'This product is not configured in the store yet.',
      );
      return;
    }
    final param = PurchaseParam(productDetails: product);
    final isConsumable =
        StoreProducts.crystalsForProduct(productId) > 0;
    if (isConsumable) {
      await _iap.buyConsumable(purchaseParam: param);
    } else {
      await _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  void _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(message: 'Purchase pending…');
        case PurchaseStatus.error:
          state = state.copyWith(
              message: 'Purchase failed: ${purchase.error?.message ?? ''}');
        case PurchaseStatus.canceled:
          state = state.copyWith(message: 'Purchase canceled.');
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // NOTE: on Blaze, verify purchase.verificationData server-side here.
          _deliver(purchase.productID);
          state = state.copyWith(message: 'Purchase successful. Thank you!');
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _deliver(String productId) {
    final crystals = StoreProducts.crystalsForProduct(productId);
    if (crystals > 0) {
      _ref.read(playerControllerProvider.notifier).addCrystals(crystals);
      return;
    }
    final tier = StoreProducts.tierForProduct(productId);
    if (tier != null) {
      _prefs.setString(_tierKey, tier);
      state = state.copyWith(activeTier: tier);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final storeControllerProvider =
    StateNotifierProvider<StoreController, StoreState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final userId = ref.watch(authControllerProvider).user?.id ?? 'anonymous';
  return StoreController(ref, prefs, userId);
});
