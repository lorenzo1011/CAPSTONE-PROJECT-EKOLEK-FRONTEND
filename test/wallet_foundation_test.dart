import 'package:ekolek_app/features/wallet/models/point_transaction.dart';
import 'package:ekolek_app/features/wallet/models/wallet_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wallet foundation — 50 focused cases', () {
    for (var index = 0; index < 10; index++) {
      test('wallet parses valid integer values case ${index + 1}', () {
        final wallet = WalletSummary.fromJson({
          'id': index + 1,
          'current_balance': index * 10,
          'lifetime_points_earned': index * 20,
          'lifetime_points_redeemed': index * 3,
          'lifetime_points_adjusted': index,
          'updated_at': '2026-07-15T00:00:00Z',
        });
        expect(wallet.id, index + 1);
        expect(wallet.currentBalance, index * 10);
        expect(wallet.updatedAt?.isUtc, isTrue);
      });
    }

    const invalidFields = [
      'id',
      'current_balance',
      'lifetime_points_earned',
      'lifetime_points_redeemed',
      'lifetime_points_adjusted',
    ];
    for (final field in invalidFields) {
      for (var variant = 0; variant < 2; variant++) {
        test('wallet rejects invalid $field variant ${variant + 1}', () {
          final json = <String, Object?>{
            'id': 1,
            'current_balance': 10,
            'lifetime_points_earned': 20,
            'lifetime_points_redeemed': 5,
            'lifetime_points_adjusted': 0,
          };
          json[field] = variant == 0 ? null : '10';
          expect(() => WalletSummary.fromJson(json), throwsFormatException);
        });
      }
    }

    const transactionTypes = <String, PointDirection>{
      'EARN_COLLECTION': PointDirection.earned,
      'EARN_VIDEO': PointDirection.earned,
      'EARN_QUIZ': PointDirection.earned,
      'EARN_GAME': PointDirection.earned,
      'EARN_CHALLENGE': PointDirection.earned,
      'BONUS': PointDirection.earned,
      'REDEEM_REWARD': PointDirection.spent,
      'ADJUSTMENT_ADD': PointDirection.adjustment,
      'ADJUSTMENT_DEDUCT': PointDirection.adjustment,
      'CORRECTION': PointDirection.adjustment,
      'FUTURE_TYPE': PointDirection.unknown,
    };
    for (final entry in transactionTypes.entries) {
      test('transaction maps ${entry.key} safely', () {
        final transaction = _transaction(entry.key);
        expect(transaction.direction, entry.value);
        expect(transaction.label, isNotEmpty);
      });
    }

    for (var index = 0; index < 9; index++) {
      test('transaction preserves safe response values case ${index + 1}', () {
        final transaction = PointTransaction.fromJson({
          'id': index + 1,
          'transaction_type': 'BONUS',
          'points': index,
          'balance_after': 100 + index,
          'source_type': 'SYSTEM',
          'description': 'Activity $index',
          'created_at':
              '2026-07-${(index + 1).toString().padLeft(2, '0')}T00:00:00Z',
        });
        expect(transaction.id, index + 1);
        expect(transaction.description, 'Activity $index');
        expect(transaction.createdAt?.isUtc, isTrue);
      });
    }

    const invalidTransactionFields = ['id', 'points', 'balance_after'];
    for (final field in invalidTransactionFields) {
      for (var variant = 0; variant < 3; variant++) {
        test('transaction rejects invalid $field variant ${variant + 1}', () {
          final json = <String, Object?>{
            'id': 1,
            'transaction_type': 'BONUS',
            'points': 5,
            'balance_after': 10,
          };
          json[field] = switch (variant) {
            0 => null,
            1 => '1',
            _ => 1.5,
          };
          expect(() => PointTransaction.fromJson(json), throwsFormatException);
        });
      }
    }

    test('wallet reports points only for a positive balance', () {
      expect(_wallet(1).hasPoints, isTrue);
      expect(_wallet(0).hasPoints, isFalse);
    });
  });
}

PointTransaction _transaction(String type) => PointTransaction.fromJson({
  'id': 1,
  'transaction_type': type,
  'points': 5,
  'balance_after': 10,
  'source_type': 'SYSTEM',
  'description': '',
  'created_at': '2026-07-15T00:00:00Z',
});

WalletSummary _wallet(int balance) => WalletSummary.fromJson({
  'id': 1,
  'current_balance': balance,
  'lifetime_points_earned': balance,
  'lifetime_points_redeemed': 0,
  'lifetime_points_adjusted': 0,
});
