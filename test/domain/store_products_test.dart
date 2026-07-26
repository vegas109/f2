import 'package:codehero/features/store/domain/store_products.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreProducts', () {
    test('crystalsForProduct maps known packs and 0 otherwise', () {
      expect(StoreProducts.crystalsForProduct('crystals_small'), 100);
      expect(StoreProducts.crystalsForProduct('crystals_large'), 1200);
      expect(StoreProducts.crystalsForProduct('sub_pro'), 0);
      expect(StoreProducts.crystalsForProduct('nope'), 0);
    });

    test('tierForProduct maps subscriptions and null otherwise', () {
      expect(StoreProducts.tierForProduct('sub_plus'), 'plus');
      expect(StoreProducts.tierForProduct('sub_ultimate'), 'ultimate');
      expect(StoreProducts.tierForProduct('crystals_small'), isNull);
    });

    test('allIds contains every pack and subscription id', () {
      expect(StoreProducts.allIds, contains('crystals_medium'));
      expect(StoreProducts.allIds, contains('sub_pro'));
      expect(
        StoreProducts.allIds.length,
        StoreProducts.crystalPacks.length + StoreProducts.subscriptions.length,
      );
    });
  });
}
