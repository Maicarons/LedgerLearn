import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/models/entry.dart';
import 'package:ledgerlearn/data/models/voucher.dart';
import 'package:ledgerlearn/shared/utils/helpers.dart';

void main() {
  group('Entry money cents', () {
    test('stores yuan as integer cents', () {
      final e = Entry(
        accountId: '1001',
        accountName: 'Cash',
        isDebit: true,
        amount: 12.34,
      );
      expect(e.amountCents, 1234);
      expect(e.amount, closeTo(12.34, 0.0001));
    });

    test('fromYuan rounds to cents', () {
      final e = Entry.fromYuan(
        accountId: '1001',
        accountName: 'Cash',
        isDebit: false,
        amount: 0.1 + 0.2, // classic float noise
      );
      expect(e.amountCents, 30);
    });

    test('accepts amountCents directly', () {
      final e = Entry(
        accountId: '1001',
        accountName: 'Cash',
        isDebit: true,
        amountCents: 999,
      );
      expect(e.amount, 9.99);
    });

    test('round-trips JSON with amountCents', () {
      final e = Entry.fromYuan(
        accountId: '1002',
        accountName: 'Bank',
        isDebit: true,
        amount: 100.5,
      );
      final restored = Entry.fromJson(e.toJson());
      expect(restored.amountCents, 10050);
      expect(restored.accountId, '1002');
    });

    test('migrates legacy double amount JSON to cents', () {
      final restored = Entry.fromJson({
        'accountId': '1001',
        'accountName': 'Cash',
        'isDebit': true,
        'amount': 25.75,
      });
      expect(restored.amountCents, 2575);
      expect(restored.amount, 25.75);
    });
  });

  group('Voucher balance in cents', () {
    Voucher make(List<Entry> entries) => Voucher(
          id: '2026010001',
          date: DateTime(2026, 1, 15),
          summary: 'test',
          entries: entries,
        );

    test('balanced when debit cents equal credit cents', () {
      final v = make([
        Entry.fromYuan(
            accountId: '1001', accountName: 'C', isDebit: true, amount: 1.1),
        Entry.fromYuan(
            accountId: '1002', accountName: 'B', isDebit: false, amount: 1.1),
      ]);
      expect(v.isBalanced, isTrue);
      expect(v.totalDebitCents, 110);
      expect(v.totalCreditCents, 110);
    });

    test('detects one-cent imbalance', () {
      final v = make([
        Entry(
            accountId: '1001', accountName: 'C', isDebit: true, amountCents: 101),
        Entry(
            accountId: '1002', accountName: 'B', isDebit: false, amountCents: 100),
      ]);
      expect(v.isBalanced, isFalse);
    });

    test('float-looking amounts stay exact', () {
      // 0.1 + 0.2 style entries that would fail with double compare
      final v = make([
        Entry.fromYuan(
            accountId: '1001', accountName: 'C', isDebit: true, amount: 0.1),
        Entry.fromYuan(
            accountId: '1001', accountName: 'C', isDebit: true, amount: 0.2),
        Entry.fromYuan(
            accountId: '1002', accountName: 'B', isDebit: false, amount: 0.3),
      ]);
      expect(v.isBalanced, isTrue);
    });
  });

  group('helpers', () {
    test('yuanToCents / centsToYuan', () {
      expect(yuanToCents(12.34), 1234);
      expect(centsToYuan(1234), 12.34);
    });

    test('formatCurrency groups thousands and 2 decimals', () {
      expect(formatCurrency(1234.5, 'zh_CN'), '1,234.50');
      expect(formatCurrency(-12.3, 'en_US'), '-12.30');
      expect(formatCurrency(0, 'zh_CN'), '0.00');
    });

    test('formatCurrency hides float noise', () {
      expect(formatCurrency(0.1 + 0.2, 'zh_CN'), '0.30');
    });

    test('isNormallyDebit by account type', () {
      expect(isNormallyDebit(1), isTrue);
      expect(isNormallyDebit(4), isTrue);
      expect(isNormallyDebit(6), isTrue);
      expect(isNormallyDebit(2), isFalse);
      expect(isNormallyDebit(3), isFalse);
      expect(isNormallyDebit(5), isFalse);
    });

    test('calculateEndingBalance debit-normal account', () {
      expect(
        calculateEndingBalance(
          opening: 100,
          totalDebit: 50,
          totalCredit: 30,
          normallyDebit: true,
        ),
        120,
      );
    });

    test('calculateEndingBalance credit-normal account', () {
      expect(
        calculateEndingBalance(
          opening: 100,
          totalDebit: 40,
          totalCredit: 70,
          normallyDebit: false,
        ),
        130,
      );
    });

    test('calculateEndingBalanceCents exact', () {
      expect(
        calculateEndingBalanceCents(
          openingCents: 10001,
          totalDebitCents: 1,
          totalCreditCents: 0,
          normallyDebit: true,
        ),
        10002,
      );
    });
  });
}
