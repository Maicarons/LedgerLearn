import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/cash_flow_service.dart';
import '../../../shared/utils/helpers.dart';
import '../controllers/cash_flow_controller.dart';

class CashFlowView extends GetView<CashFlowController> {
  const CashFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CashFlowController());
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';

    return Scaffold(
      appBar: AppBar(
        title: Text('reports_cash_flow'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.defaultDialog(
                title: 'reports_how_to_read'.tr,
                middleText: 'reports_cash_flow_hint'.tr,
                textConfirm: 'ok'.tr,
              );
            },
          ),
        ],
      ),
      body: GetBuilder<CashFlowController>(
        builder: (controller) {
          final s = controller.statement;

          int line(CashFlowCategory cat, String key, bool isInflow) =>
              s.lineCents(cat, key, isInflow: isInflow);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PeriodChip(year: controller.year, month: controller.month),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text('reports_cash_flow'.tr,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const Divider(),
                        _section(context, 'cf_operating'),
                        _row(context, 'cf_sales_receipts',
                            line(CashFlowCategory.operating, 'salesReceipts', true)),
                        _row(context, 'cf_other_op_in',
                            line(CashFlowCategory.operating, 'otherOpIn', true)),
                        _subtotal(context, 'cf_op_in_subtotal', s.operatingInflowCents),
                        _row(context, 'cf_purchase_paid',
                            line(CashFlowCategory.operating, 'purchasePaid', false)),
                        _row(context, 'cf_wages_paid',
                            line(CashFlowCategory.operating, 'wagesPaid', false)),
                        _row(context, 'cf_tax_paid',
                            line(CashFlowCategory.operating, 'taxPaid', false)),
                        _row(context, 'cf_other_op_out',
                            line(CashFlowCategory.operating, 'otherOpOut', false)),
                        _subtotal(context, 'cf_op_out_subtotal', s.operatingOutflowCents),
                        _net(context, 'cf_op_net', s.operatingNetCents),
                        const Divider(),
                        _section(context, 'cf_investing'),
                        _row(context, 'cf_invest_asset',
                            line(CashFlowCategory.investing, 'investAsset', true)),
                        _row(context, 'cf_invest_income',
                            line(CashFlowCategory.investing, 'investIncome', true)),
                        _subtotal(context, 'cf_inv_in_subtotal', s.investingInflowCents),
                        _row(context, 'cf_invest_asset',
                            line(CashFlowCategory.investing, 'investAsset', false)),
                        _row(context, 'cf_invest_income',
                            line(CashFlowCategory.investing, 'investIncome', false)),
                        _subtotal(context, 'cf_inv_out_subtotal', s.investingOutflowCents),
                        _net(context, 'cf_inv_net', s.investingNetCents),
                        const Divider(),
                        _section(context, 'cf_financing'),
                        _row(context, 'cf_borrowing',
                            line(CashFlowCategory.financing, 'borrowing', true)),
                        _row(context, 'cf_capital',
                            line(CashFlowCategory.financing, 'capital', true)),
                        _subtotal(context, 'cf_fin_in_subtotal', s.financingInflowCents),
                        _row(context, 'cf_borrowing',
                            line(CashFlowCategory.financing, 'borrowing', false)),
                        _row(context, 'cf_interest_paid',
                            line(CashFlowCategory.financing, 'interestPaid', false)),
                        _row(context, 'cf_dividend_paid',
                            line(CashFlowCategory.financing, 'dividendPaid', false)),
                        _subtotal(context, 'cf_fin_out_subtotal', s.financingOutflowCents),
                        _net(context, 'cf_fin_net', s.financingNetCents),
                        const Divider(thickness: 2),
                        _net(context, 'cf_net_increase', s.netIncreaseCents),
                        _row(context, 'cf_opening_cash', s.openingCashCents),
                        _net(context, 'cf_closing_cash', s.closingCashCents, big: true),
                        if (s.reconcileDiffCents.abs() > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${'cf_reconcile_hint'.tr}: '
                              '${formatCents(s.reconcileDiffCents, locale)}',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String key) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(key.tr,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );

  Widget _row(BuildContext context, String key, int cents) {
    if (cents == 0) return const SizedBox.shrink();
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(key.tr)),
          Text(formatCents(cents, locale)),
        ],
      ),
    );
  }

  Widget _subtotal(BuildContext context, String key, int cents) {
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(key.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(formatCents(cents, locale),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _net(BuildContext context, String key, int cents, {bool big = false}) {
    final locale =
        Get.locale?.toLanguageTag().replaceAll('-', '_') ?? 'zh_CN';
    final color = cents >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(key.tr,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: big ? 16 : 14))),
          Text(formatCents(cents, locale),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: big ? 16 : 14,
                  color: color)),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final int year;
  final int month;
  const _PeriodChip({required this.year, required this.month});

  @override
  Widget build(BuildContext context) {
    final label =
        '$year-${month.toString().padLeft(2, '0')}  ${'month_selector'.tr}';
    return Center(
      child: Chip(
        avatar: const Icon(Icons.calendar_month, size: 18),
        label: Text(label),
      ),
    );
  }
}
