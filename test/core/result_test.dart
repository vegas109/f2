import 'package:codehero/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success carries a value and folds correctly', () {
      const Result<int> r = Success(42);
      expect(r.isSuccess, isTrue);
      expect(r.valueOrNull, 42);
      final folded = r.when(success: (v) => 'v=$v', failure: (m, _) => m);
      expect(folded, 'v=42');
    });

    test('Failure carries a message and folds correctly', () {
      const Result<int> r = Failure('boom');
      expect(r.isFailure, isTrue);
      expect(r.valueOrNull, isNull);
      final folded = r.when(success: (v) => 'ok', failure: (m, _) => m);
      expect(folded, 'boom');
    });
  });
}
