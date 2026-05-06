import 'package:get/get.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/voucher/views/voucher_list_view.dart';
import '../../modules/voucher/views/voucher_form_view.dart';
import '../../modules/voucher/views/voucher_detail_view.dart';
import '../../modules/accounts/views/accounts_view.dart';
import '../../modules/accounts/views/account_detail_view.dart';
import '../../modules/ledger/views/ledger_view.dart';
import '../../modules/ledger/views/ledger_detail_view.dart';
import '../../modules/reports/views/reports_view.dart';
import '../../modules/reports/views/trial_balance_view.dart';
import '../../modules/reports/views/income_statement_view.dart';
import '../../modules/reports/views/balance_sheet_view.dart';
import '../../modules/knowledge/views/knowledge_view.dart';
import '../../modules/knowledge/views/knowledge_detail_view.dart';
import '../../modules/settings/views/settings_view.dart';

class AppPages {
  static const String initial = '/home';

  static final List<GetPage> routes = [
    GetPage(name: '/home', page: () => const HomeView()),
    GetPage(name: '/vouchers', page: () => const VoucherListView()),
    GetPage(name: '/vouchers/new', page: () => const VoucherFormView()),
    GetPage(name: '/vouchers/edit/:id', page: () => const VoucherFormView(isEdit: true)),
    GetPage(name: '/vouchers/detail/:id', page: () => const VoucherDetailView()),
    GetPage(name: '/accounts', page: () => const AccountsView()),
    GetPage(name: '/accounts/detail/:id', page: () => const AccountDetailView()),
    GetPage(name: '/ledger', page: () => const LedgerView()),
    GetPage(name: '/ledger/detail/:id', page: () => const LedgerDetailView()),
    GetPage(name: '/reports', page: () => const ReportsView()),
    GetPage(name: '/reports/trial-balance', page: () => const TrialBalanceView()),
    GetPage(name: '/reports/income-statement', page: () => const IncomeStatementView()),
    GetPage(name: '/reports/balance-sheet', page: () => const BalanceSheetView()),
    GetPage(name: '/knowledge', page: () => const KnowledgeView()),
    GetPage(name: '/knowledge/detail/:id', page: () => const KnowledgeDetailView()),
    GetPage(name: '/settings', page: () => const SettingsView()),
  ];
}
