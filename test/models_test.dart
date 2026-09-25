import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/models/account.dart';
import 'package:ledgerlearn/data/models/voucher.dart';
import 'package:ledgerlearn/data/models/entry.dart';
import 'package:ledgerlearn/data/models/knowledge_card.dart';
import 'package:ledgerlearn/app/config/preset_data.dart';

void main() {
  group('Account model', () {
    test('openingBalance migrates from legacy double JSON', () {
      final a = Account.fromJson({
        'id': '1001',
        'nameZh': '库存现金',
        'nameEn': 'Cash',
        'nameKo': '현금',
        'category': 'asset',
        'type': 1,
        'openingBalance': 100.5,
        'isSystem': true,
      });
      expect(a.openingBalanceCents, 10050);
      expect(a.openingBalance, 100.5);
    });

    test('getName falls back to English for ja/vi/th', () {
      final a = Account(
        id: '1001',
        nameZh: '库存现金',
        nameEn: 'Cash on Hand',
        nameKo: '현금',
        category: 'asset',
        type: 1,
      );
      expect(a.getName('zh_CN'), '库存现金');
      expect(a.getName('en_US'), 'Cash on Hand');
      expect(a.getName('ko_KR'), '현금');
      expect(a.getName('ja_JP'), 'Cash on Hand');
      expect(a.getName('vi_VN'), 'Cash on Hand');
      expect(a.getName('th_TH'), 'Cash on Hand');
    });

    test('normallyDebit follows accounting equation', () {
      Account make(int type) => Account(
            id: 'x',
            nameZh: 'x',
            nameEn: 'x',
            nameKo: 'x',
            category: 'asset',
            type: type,
          );
      expect(make(1).normallyDebit, isTrue); // asset
      expect(make(2).normallyDebit, isFalse); // liability
      expect(make(3).normallyDebit, isFalse); // equity
      expect(make(4).normallyDebit, isTrue); // cost
      expect(make(5).normallyDebit, isFalse); // income
      expect(make(6).normallyDebit, isTrue); // expense
    });
  });

  group('Preset accounts', () {
    test('has at least 60 system accounts', () {
      expect(presetAccounts.length, greaterThanOrEqualTo(60));
    });

    test('ids are unique', () {
      final ids = presetAccounts.map((a) => a.id).toSet();
      expect(ids.length, presetAccounts.length);
    });

    test('every account has trilingual names', () {
      for (final a in presetAccounts) {
        expect(a.nameZh.isNotEmpty, isTrue, reason: a.id);
        expect(a.nameEn.isNotEmpty, isTrue, reason: a.id);
        expect(a.nameKo.isNotEmpty, isTrue, reason: a.id);
      }
    });

    test('includes core ASBE accounts', () {
      final ids = presetAccounts.map((a) => a.id).toSet();
      for (final id in [
        '1001',
        '1002',
        '1122',
        '1403',
        '1405',
        '1601',
        '1602',
        '2001',
        '2202',
        '2211',
        '2221',
        '3001',
        '3103',
        '3104',
        '5001',
        '5401',
        '5502',
      ]) {
        expect(ids.contains(id), isTrue, reason: 'missing $id');
      }
    });
  });

  group('Voucher JSON', () {
    test('round-trips with entries', () {
      final v = Voucher(
        id: '2026090001',
        date: DateTime(2026, 9, 1),
        summary: '提现',
        entries: [
          Entry.fromYuan(
              accountId: '1001', accountName: '库存现金', isDebit: true, amount: 5000),
          Entry.fromYuan(
              accountId: '1002', accountName: '银行存款', isDebit: false, amount: 5000),
        ],
      );
      final restored = Voucher.fromJson(v.toJson());
      expect(restored.id, v.id);
      expect(restored.entries.length, 2);
      expect(restored.isBalanced, isTrue);
      expect(restored.totalDebit, 5000);
    });
  });

  group('KnowledgeCard JSON', () {
    test('parses multilingual fields', () {
      final k = KnowledgeCard.fromJson({
        'id': 'k1',
        'category': 'accounting_practice',
        'title': '借贷记账法',
        'content': '## 借贷',
        'relatedAccountId': '1001',
      });
      expect(k.id, 'k1');
      expect(k.category, 'accounting_practice');
    });
  });
}
