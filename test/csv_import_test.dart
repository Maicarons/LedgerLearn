import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerlearn/data/services/csv_import_service.dart';
import 'package:ledgerlearn/data/models/account.dart';
import 'package:ledgerlearn/data/models/voucher.dart';
import 'package:ledgerlearn/data/repositories/account_repository.dart';
import 'package:ledgerlearn/data/repositories/voucher_repository.dart';
import 'package:ledgerlearn/data/services/database_service.dart';

class _FakeDb implements DatabaseService {
  final accounts = <Account>[
    Account(
        id: '1001',
        nameZh: '库存现金',
        nameEn: 'Cash',
        nameKo: '현금',
        category: 'asset',
        type: 1),
    Account(
        id: '1002',
        nameZh: '银行存款',
        nameEn: 'Bank',
        nameKo: '은행',
        category: 'asset',
        type: 1),
    Account(
        id: '5502',
        nameZh: '管理费用',
        nameEn: 'Admin',
        nameKo: '관리비',
        category: 'pl',
        type: 6),
  ];
  final vouchers = <Voucher>[];

  @override
  List<Account> getAccounts() => accounts;

  @override
  Account? getAccount(String id) {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Voucher> getVouchers({int? year, int? month}) => vouchers;

  @override
  Voucher? getVoucher(String id) {
    try {
      return vouchers.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveVoucher(Voucher voucher) async {
    vouchers.add(voucher);
  }

  @override
  String generateVoucherId(int year, int month) =>
      '$year${month.toString().padLeft(2, '0')}0001';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CsvImportService.parse', () {
    late _FakeDb db;
    late CsvImportService svc;

    setUp(() {
      db = _FakeDb();
      svc = CsvImportService(
        accountRepo: AccountRepository(db),
        voucherRepo: VoucherRepository(db),
      );
    });

    test('rejects empty input', () {
      final r = svc.parse('');
      expect(r.errors, contains('csv_empty'));
    });

    test('rejects bad header', () {
      final r = svc.parse('foo,bar\n1,2');
      expect(r.errors, contains('csv_bad_header'));
    });

    test('parses simple two-line form', () {
      final r = svc.parse('''
date,summary,debit_account,credit_account,amount
2026-09-30,提现,1001,1002,5000
''');
      expect(r.errors, isEmpty);
      expect(r.vouchers.length, 1);
      final v = r.vouchers.first;
      expect(v.entries.length, 2);
      expect(v.entries[0].accountId, '1001');
      expect(v.entries[0].isDebit, isTrue);
      expect(v.entries[1].accountId, '1002');
      expect(v.isBalanced, isTrue);
    });

    test('parses detailed multi-line form', () {
      final r = svc.parse('''
voucher_id,date,summary,account_id,direction,amount
V1,2026-09-30,报销,5502,D,1200
V1,2026-09-30,报销,1001,C,1200
''');
      expect(r.errors, isEmpty);
      expect(r.vouchers.length, 1);
      expect(r.vouchers.first.entries.length, 2);
      expect(r.vouchers.first.isBalanced, isTrue);
    });

    test('reports bad date', () {
      final r = svc.parse('''
date,summary,debit_account,credit_account,amount
not-a-date,提现,1001,1002,5000
''');
      expect(r.errors, isNotEmpty);
    });

    test('reports bad amount', () {
      final r = svc.parse('''
date,summary,debit_account,credit_account,amount
2026-09-30,提现,1001,1002,abc
''');
      expect(r.errors, isNotEmpty);
    });

    test('import persists balanced vouchers', () async {
      final r = await svc.import('''
date,summary,debit_account,credit_account,amount
2026-09-30,提现,1001,1002,5000
''');
      expect(r.created.length, 1);
      expect(db.vouchers.length, 1);
    });
  });
}
