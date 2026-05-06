import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../voucher/views/voucher_form_view.dart';
import '../../accounts/views/accounts_view.dart';
import '../../knowledge/views/knowledge_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(HomeController());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('home_title'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  Obx(() => Card(
                        child: ListTile(
                          leading:
                              Icon(Icons.calendar_month, color: colorScheme.primary),
                          title: Text('home_period'.tr),
                          trailing: DropdownButton<String>(
                            value: controller.currentPeriod.value,
                            underline: const SizedBox(),
                            items: controller.availablePeriods
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) controller.setPeriod(v);
                            },
                          ),
                        ),
                      )),

                  const SizedBox(height: 16),

                  // Summary cards
                  Obx(() {
                    final summary = controller.summary.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.receipt_long,
                            label: 'home_voucher_count'.tr,
                            value: '${summary.voucherCount}',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_upward,
                            label: 'home_debit_total'.tr,
                            value: controller.formatAmount(summary.totalDebit),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),

                  Obx(() {
                    final summary = controller.summary.value;
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.arrow_downward,
                            label: 'home_credit_total'.tr,
                            value: controller.formatAmount(summary.totalCredit),
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            icon: summary.isBalanced
                                ? Icons.check_circle
                                : Icons.warning,
                            label: 'home_balance_status'.tr,
                            value: summary.isBalanced
                                ? 'home_balanced'.tr
                                : 'home_unbalanced'.tr,
                            color: summary.isBalanced
                                ? Colors.green
                                : Colors.orange,
                            valueColor: summary.isBalanced
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    );
                  }),

                  // Unbalanced warning
                  Obx(() {
                    final s = controller.summary.value;
                    if (s.voucherCount > 0 &&
                        !s.isBalanced) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber,
                                    color: Colors.orange.shade800),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('home_check_unbalanced'.tr,
                                      style: TextStyle(
                                          color: Colors.orange.shade800)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 24),

                  // Quick actions
                  Text('快捷操作',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_circle,
                          label: 'home_quick_voucher'.tr,
                          color: colorScheme.primary,
                          onTap: () => Get.to(() => const VoucherFormView()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.account_balance,
                          label: 'home_quick_accounts'.tr,
                          color: Colors.teal,
                          onTap: () => Get.to(() => const AccountsView()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.library_books,
                          label: 'home_quick_knowledge'.tr,
                          color: Colors.deepPurple,
                          onTap: () => Get.to(() => const KnowledgeView()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? color,
                )),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
